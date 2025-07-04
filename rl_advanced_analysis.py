import json
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path
from typing import Dict, List, Tuple
import pandas as pd
from scipy import stats
from scipy.optimize import curve_fit
import argparse

# Set style
plt.style.use("seaborn-v0_8-darkgrid")
sns.set_palette("husl")


def load_benchmark_data(filepath: str) -> Dict:
    """Load benchmark data from JSON file"""
    with open(filepath, "r") as f:
        return json.load(f)


def simulate_rl_trajectories(
    level_data: Dict, n_simulations: int = 1000, max_attempts: int = 64
) -> Dict:
    """Simulate RL trajectories based on success rates"""
    success_rate = level_data.get("success_rate", 0)

    if success_rate == 0:
        return {
            "converged": False,
            "avg_convergence_step": max_attempts,
            "convergence_distribution": [0] * max_attempts,
        }

    convergence_steps = []

    for _ in range(n_simulations):
        for step in range(1, max_attempts + 1):
            if np.random.random() < success_rate:
                convergence_steps.append(step)
                break
        else:
            convergence_steps.append(max_attempts)

    # Create distribution
    convergence_dist = [0] * max_attempts
    for step in convergence_steps:
        if step <= max_attempts:
            convergence_dist[step - 1] += 1

    return {
        "converged": np.mean([s < max_attempts for s in convergence_steps]) > 0.5,
        "avg_convergence_step": np.mean(convergence_steps),
        "convergence_distribution": convergence_dist,
        "convergence_steps": convergence_steps,
    }


def calculate_rl_potential_score(data: Dict) -> float:
    """Calculate a composite RL potential score (0-100)"""
    scores = []

    # Factor 1: Improvement from N=1 to N=64
    n_values = [1, 64]
    bon_rates = {}
    for n in n_values:
        success_rates = []
        for level in data["detailed_results"]:
            if "success_rate" in level:
                failure_rate = 1 - level["success_rate"]
                bon_success = 1 - (failure_rate**n)
                success_rates.append(bon_success)
        bon_rates[n] = np.mean(success_rates) if success_rates else 0

    improvement_score = (bon_rates[64] - bon_rates[1]) * 100
    scores.append(improvement_score)

    # Factor 2: Variance in success rates (higher variance = more potential)
    success_rates = [l.get("success_rate", 0) for l in data["detailed_results"]]
    if success_rates:
        variance_score = np.std(success_rates) * 100
        scores.append(variance_score)

    # Factor 3: Existence of "near-miss" levels (0 < success_rate < 0.5)
    near_miss_ratio = (
        sum(1 for sr in success_rates if 0 < sr < 0.5) / len(success_rates)
        if success_rates
        else 0
    )
    near_miss_score = near_miss_ratio * 100
    scores.append(near_miss_score)

    return np.mean(scores)


def analyze_convergence_patterns(data: Dict) -> pd.DataFrame:
    """Analyze convergence patterns across all levels"""
    convergence_data = []

    for level in data["detailed_results"]:
        trajectory = simulate_rl_trajectories(level)

        convergence_data.append(
            {
                "level": level["task_id"],
                "level_name": level.get("level_name", f"Level {level['task_id']}"),
                "success_rate": level.get("success_rate", 0),
                "converged": trajectory["converged"],
                "avg_convergence_step": trajectory["avg_convergence_step"],
                "convergence_rate": (
                    1 / trajectory["avg_convergence_step"]
                    if trajectory["avg_convergence_step"] > 0
                    else 0
                ),
            }
        )

    return pd.DataFrame(convergence_data)


def fit_learning_curve(
    n_values: List[int], success_rates: List[float]
) -> Tuple[np.ndarray, Dict]:
    """Fit an exponential learning curve to Best-of-N data"""

    def exponential_curve(x, a, b, c):
        return a * (1 - np.exp(-b * x)) + c

    try:
        # Initial guess
        p0 = [max(success_rates) - min(success_rates), 0.1, min(success_rates)]

        # Fit curve
        with np.errstate(all='ignore'):
            popt, pcov = curve_fit(
                exponential_curve, n_values, success_rates, p0=p0, maxfev=5000
            )

        # Generate smooth curve
        x_smooth = np.linspace(1, max(n_values), 100)
        y_smooth = exponential_curve(x_smooth, *popt)

        # Calculate R-squared
        residuals = np.array(success_rates) - exponential_curve(
            np.array(n_values), *popt
        )
        ss_res = np.sum(residuals**2)
        ss_tot = np.sum((np.array(success_rates) - np.mean(success_rates)) ** 2)
        r_squared = 1 - (ss_res / ss_tot) if ss_tot != 0 else 0

        return x_smooth, {
            "y_smooth": y_smooth,
            "params": popt,
            "r_squared": r_squared,
            "asymptote": popt[0] + popt[2],
        }
    except Exception:
        return np.array(n_values), {
            "y_smooth": success_rates,
            "params": None,
            "r_squared": 0,
            "asymptote": max(success_rates) if success_rates else 0,
        }


def analyze_tool_sequence_patterns(data: Dict) -> Dict:
    """Analyze specific tool sequence patterns that lead to success"""
    sequences = {"successful": [], "failed": []}

    for level in data["detailed_results"]:
        if "individual_runs" in level:
            for run in level["individual_runs"]:
                status = "successful" if run.get("solved", False) else "failed"

                # Create a simplified sequence representation
                tool_usage = run.get("tool_usage", {})
                sequence = []
                for tool, count in sorted(tool_usage.items()):
                    sequence.extend(
                        [tool] * min(count, 3)
                    )  # Cap at 3 to avoid very long sequences

                sequences[status].append(tuple(sequence))

    # Find most common successful patterns
    from collections import Counter

    successful_patterns = Counter(sequences["successful"])
    failed_patterns = Counter(sequences["failed"])

    return {
        "top_successful_patterns": successful_patterns.most_common(10),
        "top_failed_patterns": failed_patterns.most_common(10),
        "unique_successful_patterns": len(set(sequences["successful"])),
        "unique_failed_patterns": len(set(sequences["failed"])),
    }


def plot_rl_learning_curves(data: Dict, output_dir: Path):
    """Plot learning curves for different levels with RL simulation"""
    fig, axes = plt.subplots(2, 2, figsize=(15, 12))
    axes = axes.flatten()

    # Select representative levels
    levels = data["detailed_results"]

    # Categories: Easy (high success), Medium (moderate success), Hard (low success), Impossible (zero success)
    easy_levels = [l for l in levels if l.get("success_rate", 0) > 0.7]
    medium_levels = [l for l in levels if 0.3 < l.get("success_rate", 0) <= 0.7]
    hard_levels = [l for l in levels if 0 < l.get("success_rate", 0) <= 0.3]
    impossible_levels = [l for l in levels if l.get("success_rate", 0) == 0]

    categories = [
        ("Easy Levels (>70% success)", easy_levels),
        ("Medium Levels (30-70% success)", medium_levels),
        ("Hard Levels (<30% success)", hard_levels),
        ("Zero Success Levels", impossible_levels),
    ]

    for idx, (category_name, category_levels) in enumerate(categories):
        ax = axes[idx]

        if category_levels:
            # Calculate average BoN curve for this category
            n_values = list(range(1, 65, 4))
            avg_success_rates = []

            for n in n_values:
                rates = []
                for level in category_levels:
                    failure_rate = 1 - level.get("success_rate", 0)
                    bon_rate = 1 - (failure_rate**n)
                    rates.append(bon_rate)
                avg_success_rates.append(np.mean(rates))

            # Plot actual data
            ax.plot(n_values, avg_success_rates, "bo-", label="Actual", markersize=6)

            # Fit and plot learning curve
            x_smooth, fit_data = fit_learning_curve(n_values, avg_success_rates)
            if fit_data["params"] is not None:
                ax.plot(
                    x_smooth,
                    fit_data["y_smooth"],
                    "r--",
                    label=f'Fitted (R²={fit_data["r_squared"]:.3f})',
                    linewidth=2,
                )
                ax.axhline(
                    y=fit_data["asymptote"],
                    color="green",
                    linestyle=":",
                    label=f'Asymptote: {fit_data["asymptote"]:.2f}',
                )

            ax.set_xlabel("Best-of-N")
            ax.set_ylabel("Success Rate")
            ax.set_title(f"{category_name} (n={len(category_levels)})")
            ax.legend()
            ax.grid(True, alpha=0.3)
            ax.set_ylim(-0.05, 1.05)
        else:
            ax.text(
                0.5,
                0.5,
                f"No levels in category:\n{category_name}",
                ha="center",
                va="center",
                transform=ax.transAxes,
            )
            ax.set_xlim(0, 1)
            ax.set_ylim(0, 1)

    plt.tight_layout()
    plt.savefig(output_dir / "rl_learning_curves.png", dpi=300, bbox_inches="tight")
    plt.close()


def plot_convergence_heatmap(convergence_df: pd.DataFrame, output_dir: Path):
    """Create a heatmap showing convergence patterns"""
    # Create a matrix for the heatmap
    max_steps = 20  # Focus on first 20 steps
    levels = sorted(convergence_df["level"].unique())

    heatmap_data = np.zeros((len(levels), max_steps))

    for idx, level in enumerate(levels):
        level_data = convergence_df[convergence_df["level"] == level].iloc[0]
        trajectory = simulate_rl_trajectories(
            {"success_rate": level_data["success_rate"]}, n_simulations=1000
        )

        # Normalize distribution
        dist = trajectory["convergence_distribution"][:max_steps]
        if sum(dist) > 0:
            dist = [d / sum(dist) for d in dist]
        heatmap_data[idx, :] = dist

    plt.figure(figsize=(12, 8))
    sns.heatmap(
        heatmap_data,
        xticklabels=range(1, max_steps + 1),
        yticklabels=[f"L{l}" for l in levels],
        cmap="YlOrRd",
        cbar_kws={"label": "Convergence Probability"},
    )

    plt.xlabel("RL Training Step")
    plt.ylabel("Level")
    plt.title("RL Convergence Probability Heatmap\n(Darker = Higher probability of first success)")
    plt.tight_layout()
    plt.savefig(output_dir / "convergence_heatmap.png", dpi=300, bbox_inches="tight")
    plt.close()


def plot_rl_potential_dashboard(data: Dict, output_dir: Path):
    """Create a comprehensive RL potential dashboard"""
    fig = plt.figure(figsize=(16, 10))

    # Calculate metrics
    rl_score = calculate_rl_potential_score(data)
    convergence_df = analyze_convergence_patterns(data)

    # Layout: 2x3 grid
    gs = fig.add_gridspec(2, 3, hspace=0.3, wspace=0.3)

    # 1. RL Potential Score (top-left)
    ax1 = fig.add_subplot(gs[0, 0])
    ax1.text(
        0.5,
        0.5,
        f"{rl_score:.1f}",
        fontsize=72,
        ha="center",
        va="center",
        color="green" if rl_score > 50 else "orange" if rl_score > 25 else "red",
    )
    ax1.text(0.5, 0.2, "RL Potential Score", fontsize=16, ha="center", va="center")
    ax1.text(
        0.5, 0.8, "(0-100 scale)", fontsize=12, ha="center", va="center", alpha=0.7
    )
    ax1.set_xlim(0, 1)
    ax1.set_ylim(0, 1)
    ax1.axis("off")

    # 2. Success Rate Distribution (top-middle)
    ax2 = fig.add_subplot(gs[0, 1])
    success_rates = [l.get("success_rate", 0) for l in data["detailed_results"]]
    ax2.hist(success_rates, bins=20, alpha=0.7, color="blue", edgecolor="black")
    ax2.axvline(np.mean(success_rates), color="red", linestyle="--", linewidth=2)
    ax2.set_xlabel("Base Success Rate")
    ax2.set_ylabel("Number of Levels")
    ax2.set_title("Success Rate Distribution")
    ax2.grid(True, alpha=0.3)

    # 3. Convergence Speed (top-right)
    ax3 = fig.add_subplot(gs[0, 2])
    convergence_speeds = convergence_df["convergence_rate"].values
    ax3.hist(convergence_speeds, bins=20, alpha=0.7, color="green", edgecolor="black")
    ax3.set_xlabel("Convergence Rate (1/steps)")
    ax3.set_ylabel("Number of Levels")
    ax3.set_title("RL Convergence Speed Distribution")
    ax3.grid(True, alpha=0.3)

    # 4. Best-of-N Improvement (bottom-left)
    ax4 = fig.add_subplot(gs[1, 0])
    n_values = [1, 2, 4, 8, 16, 32, 64]
    improvements = []

    for n in n_values:
        rates = []
        for level in data["detailed_results"]:
            if "success_rate" in level:
                failure_rate = 1 - level["success_rate"]
                bon_rate = 1 - (failure_rate**n)
                rates.append(bon_rate)
        improvements.append(np.mean(rates) if rates else 0)

    ax4.plot(n_values, improvements, "bo-", linewidth=2, markersize=8)
    ax4.set_xlabel("Best-of-N")
    ax4.set_ylabel("Average Success Rate")
    ax4.set_title("RL Simulation (Best-of-N)")
    ax4.set_xscale("log")
    ax4.grid(True, alpha=0.3)

    # 5. Level Difficulty vs Convergence (bottom-middle)
    ax5 = fig.add_subplot(gs[1, 1])
    ax5.scatter(
        convergence_df["level"],
        convergence_df["avg_convergence_step"],
        c=convergence_df["success_rate"],
        cmap="coolwarm",
        s=100,
        alpha=0.7,
    )
    ax5.set_xlabel("Level")
    ax5.set_ylabel("Avg Steps to Convergence")
    ax5.set_title("Convergence by Level Difficulty")
    cbar = plt.colorbar(ax5.collections[0], ax=ax5)
    cbar.set_label("Success Rate")
    ax5.grid(True, alpha=0.3)

    # 6. Key Statistics (bottom-right)
    ax6 = fig.add_subplot(gs[1, 2])
    ax6.axis("off")

    # Calculate statistics
    total_levels = len(data["detailed_results"])
    solvable_levels = sum(
        1 for l in data["detailed_results"] if l.get("success_rate", 0) > 0
    )
    avg_base_success = np.mean(
        [l.get("success_rate", 0) for l in data["detailed_results"]]
    )

    # BoN=64 stats
    bon64_rates = []
    for level in data["detailed_results"]:
        if "success_rate" in level:
            failure_rate = 1 - level["success_rate"]
            bon64_rate = 1 - (failure_rate**64)
            bon64_rates.append(bon64_rate)
    avg_bon64_success = np.mean(bon64_rates) if bon64_rates else 0

    stats_text = f"""Key Statistics:
    
    Total Levels: {total_levels}
    Solvable Levels: {solvable_levels} ({solvable_levels/total_levels*100:.1f}%)
    
    Base Success Rate: {avg_base_success:.1%}
    BoN-64 Success Rate: {avg_bon64_success:.1%}
    Improvement: {(avg_bon64_success - avg_base_success):.1%}
    
    Levels with >90% BoN-64: {sum(1 for r in bon64_rates if r > 0.9)}
    Levels with <10% BoN-64: {sum(1 for r in bon64_rates if r < 0.1)}
    
    Avg Convergence: {convergence_df['avg_convergence_step'].mean():.1f} steps
    """

    ax6.text(
        0.1,
        0.9,
        stats_text,
        fontsize=12,
        va="top",
        ha="left",
        transform=ax6.transAxes,
        family="monospace",
    )

    plt.suptitle("RL Potential Analysis Dashboard", fontsize=16, y=0.98)
    plt.tight_layout(rect=[0, 0.03, 1, 0.95])
    plt.savefig(output_dir / "rl_potential_dashboard.png", dpi=300, bbox_inches="tight")
    plt.close()


def generate_advanced_rl_report(data: Dict, output_dir: Path):
    """Generate an advanced RL analysis report"""
    report = []
    report.append("# Advanced RL Simulation Analysis\n")

    # RL Potential Score
    rl_score = calculate_rl_potential_score(data)
    report.append(f"## Overall RL Potential Score: {rl_score:.1f}/100\n")

    if rl_score > 50:
        report.append(
            "**Verdict**: High potential for RL improvement. The model shows significant room for improvement through reinforcement learning.\n"
        )
    elif rl_score > 25:
        report.append(
            "**Verdict**: Moderate potential for RL improvement. Some levels would benefit from RL training.\n"
        )
    else:
        report.append(
            "**Verdict**: Low potential for RL improvement. The model may already be near optimal or the tasks are too difficult.\n"
        )

    # Convergence Analysis
    convergence_df = analyze_convergence_patterns(data)
    report.append("\n## Convergence Analysis\n")

    fast_convergers = convergence_df[convergence_df["avg_convergence_step"] < 10]
    slow_convergers = convergence_df[convergence_df["avg_convergence_step"] > 30]

    report.append(
        f"- Fast converging levels (<10 steps): {len(fast_convergers)} levels\n"
    )
    report.append(
        f"- Slow converging levels (>30 steps): {len(slow_convergers)} levels\n"
    )
    report.append(
        f"- Average convergence across all levels: {convergence_df['avg_convergence_step'].mean():.1f} steps\n"
    )

    # Tool Sequence Analysis
    tool_patterns = analyze_tool_sequence_patterns(data)
    report.append("\n## Tool Sequence Patterns\n")
    report.append(
        f"- Unique successful patterns: {tool_patterns['unique_successful_patterns']}\n"
    )
    report.append(
        f"- Unique failed patterns: {tool_patterns['unique_failed_patterns']}\n"
    )

    if tool_patterns["top_successful_patterns"]:
        report.append("\nTop 3 successful tool sequences:\n")
        for i, (pattern, count) in enumerate(
            tool_patterns["top_successful_patterns"][:3]
        ):
            if pattern:
                report.append(
                    f"{i+1}. {' → '.join(pattern[:5])}{'...' if len(pattern) > 5 else ''} (used {count} times)\n"
                )

    # Learning Curve Analysis
    report.append("\n## Learning Curve Insights\n")

    # Calculate learning rates for different difficulty levels
    n_values = [1, 4, 16, 64]
    for threshold, name in [(0.7, "Easy"), (0.3, "Medium"), (0.0001, "Hard")]:
        levels = [
            l for l in data["detailed_results"] if l.get("success_rate", 0) > threshold
        ]
        if levels:
            improvements = []
            for n_idx in range(len(n_values) - 1):
                n1, n2 = n_values[n_idx], n_values[n_idx + 1]
                rates1, rates2 = [], []
                for level in levels:
                    sr = level.get("success_rate", 0)
                    rates1.append(1 - (1 - sr) ** n1)
                    rates2.append(1 - (1 - sr) ** n2)
                improvement = np.mean(rates2) - np.mean(rates1)
                improvements.append(improvement)

            report.append(f"\n{name} levels ({len(levels)} total):\n")
            for i, imp in enumerate(improvements):
                report.append(
                    f"  - N={n_values[i]} to N={n_values[i+1]}: +{imp:.1%} improvement\n"
                )

    # Save report
    with open(output_dir / "advanced_rl_analysis.md", "w") as f:
        f.writelines(report)


def run_advanced_analysis(benchmark_file: str, output_dir: str = None):
    """Run the advanced RL analysis"""
    # Determine output directory
    if output_dir is None:
        benchmark_path = Path(benchmark_file)
        output_dir = benchmark_path.parent / "charts"
    else:
        output_dir = Path(output_dir)
    
    output_dir.mkdir(exist_ok=True)

    # Load data
    print("Loading benchmark data...")
    data = load_benchmark_data(benchmark_file)

    # Perform advanced analyses
    print("Generating RL learning curves...")
    plot_rl_learning_curves(data, output_dir)

    print("Creating convergence heatmap...")
    convergence_df = analyze_convergence_patterns(data)
    plot_convergence_heatmap(convergence_df, output_dir)

    print("Building RL potential dashboard...")
    plot_rl_potential_dashboard(data, output_dir)

    print("Generating advanced RL report...")
    generate_advanced_rl_report(data, output_dir)
    
    return output_dir


def main():
    parser = argparse.ArgumentParser(
        description="Advanced RL analysis for benchmark results"
    )
    parser.add_argument("benchmark_file", type=str, help="Path to benchmark.json file")
    parser.add_argument(
        "--output_dir",
        type=str,
        default=None,
        help="Directory to save analysis results (default: same as benchmark.json)",
    )

    args = parser.parse_args()
    
    output_dir = run_advanced_analysis(args.benchmark_file, args.output_dir)
    
    print(f"\nAdvanced analysis complete! Results saved to {output_dir}/")
    print("\nKey files generated:")
    print("- rl_learning_curves.png: Learning curves for different difficulty categories")
    print("- convergence_heatmap.png: Visualization of convergence patterns")
    print("- rl_potential_dashboard.png: Comprehensive RL potential overview")
    print("- advanced_rl_analysis.md: Detailed insights and recommendations")


if __name__ == "__main__":
    main()