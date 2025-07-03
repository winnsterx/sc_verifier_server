import json
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from pathlib import Path
from typing import Dict, List, Tuple
import pandas as pd
from collections import defaultdict, Counter
import argparse
import os

# Set style for better-looking plots
plt.style.use("seaborn-v0_8-darkgrid")
sns.set_palette("husl")


def load_benchmark_data(filepath: str) -> Dict:
    """Load benchmark data from JSON file"""
    with open(filepath, "r") as f:
        return json.load(f)


def calculate_bon_success_rates(
    level_results: List[Dict], n_values: List[int]
) -> Dict[int, float]:
    """Calculate Best-of-N success rates for different n values"""
    bon_success_rates = {}

    for n in n_values:
        level_success_rates = []
        for level in level_results:
            if "success_rate" in level:
                failure_rate = 1 - level["success_rate"]
                bon_success_rate = 1 - (failure_rate**n)
                level_success_rates.append(bon_success_rate)

        if level_success_rates:
            bon_success_rates[n] = np.mean(level_success_rates)

    return bon_success_rates


def calculate_level_bon_success(level_data: Dict, n_values: List[int]) -> Dict[int, float]:
    """Calculate Best-of-N success rates for a single level"""
    success_rate = level_data.get("success_rate", 0)
    bon_rates = {}
    
    for n in n_values:
        failure_rate = 1 - success_rate
        bon_rates[n] = 1 - (failure_rate ** n)
    
    return bon_rates


def analyze_performance_by_difficulty(data: Dict) -> pd.DataFrame:
    """Analyze how performance deteriorates over level difficulty"""
    results = []

    for level in data["detailed_results"]:
        results.append(
            {
                "level": level["task_id"],
                "level_name": level.get("level_name", f"Level {level['task_id']}"),
                "success_rate": level.get("success_rate", 0),
                "avg_tool_calls": level.get("avg_tool_calls", 0),
                "avg_execution_time": level.get("avg_execution_time", 0),
            }
        )

    df = pd.DataFrame(results)
    df = df.sort_values("level")
    return df


def analyze_first_success_distribution(data: Dict, max_n: int = 64) -> np.ndarray:
    """Analyze distribution of first success attempts (simulating RL convergence)"""
    first_success_attempts = []

    for level in data["detailed_results"]:
        success_rate = level.get("success_rate", 0)
        if success_rate > 0:
            # Calculate expected number of attempts until first success
            # Using geometric distribution: E[X] = 1/p
            expected_attempts = 1 / success_rate if success_rate > 0 else max_n
            first_success_attempts.append(min(expected_attempts, max_n))

    return np.array(first_success_attempts)


def analyze_iteration_efficiency(data: Dict) -> Dict:
    """Analyze min/avg/max number of turns to success"""
    efficiency_metrics = {
        "min_iterations": [],
        "avg_iterations": [],
        "max_iterations": [],
        "failed_iterations": [],
        "all_successful_iterations": []  # Added for clearer visualization
    }

    for level in data["detailed_results"]:
        if "individual_runs" in level:
            successful_runs = [
                r for r in level["individual_runs"] if r.get("solved", False)
            ]
            failed_runs = [
                r for r in level["individual_runs"] if not r.get("solved", False)
            ]

            if successful_runs:
                iterations = [r.get("iterations", 0) for r in successful_runs]
                if iterations:
                    efficiency_metrics["min_iterations"].append(min(iterations))
                    efficiency_metrics["avg_iterations"].append(np.mean(iterations))
                    efficiency_metrics["max_iterations"].append(max(iterations))
                    efficiency_metrics["all_successful_iterations"].extend(iterations)

            if failed_runs:
                failed_iterations = [r.get("iterations", 0) for r in failed_runs]
                if failed_iterations:
                    efficiency_metrics["failed_iterations"].extend(failed_iterations)

    return efficiency_metrics


def analyze_tool_patterns(data: Dict) -> Dict:
    """Analyze tool usage patterns in successful vs failed attempts"""
    tool_patterns = {
        "successful": defaultdict(list),
        "failed": defaultdict(list),
        "tool_sequences": {"successful": [], "failed": []},
    }

    for level in data["detailed_results"]:
        if "individual_runs" in level:
            for run in level["individual_runs"]:
                status = "successful" if run.get("solved", False) else "failed"

                # Analyze tool usage counts
                tool_usage = run.get("tool_usage", {})
                for tool, count in tool_usage.items():
                    tool_patterns[status][tool].append(count)

                # Store total tool calls for sequence analysis
                total_calls = run.get("total_tool_calls", 0)
                tool_patterns["tool_sequences"][status].append(total_calls)

    return tool_patterns


def analyze_optimal_turns(data: Dict) -> Dict:
    """Analyze relationship between number of turns and success/failure"""
    turn_data = defaultdict(lambda: {"success": 0, "failure": 0})

    for level in data["detailed_results"]:
        if "individual_runs" in level:
            for run in level["individual_runs"]:
                iterations = run.get("iterations", 0)
                if run.get("solved", False):
                    turn_data[iterations]["success"] += 1
                else:
                    turn_data[iterations]["failure"] += 1

    return turn_data


def plot_success_over_n(data: Dict, output_dir: Path):
    """Plot success rate over different Best-of-N values"""
    n_values = list(range(1, 65, 2))  # 1 to 64 with step 2
    bon_rates = calculate_bon_success_rates(data["detailed_results"], n_values)

    plt.figure(figsize=(10, 6))
    
    # Plot success rate
    ax1 = plt.gca()
    line1 = ax1.plot(
        list(bon_rates.keys()),
        list(bon_rates.values()),
        "b-",
        linewidth=2,
        marker="o",
        markersize=4,
        label="Success Rate"
    )

    # Calculate and show slope at different points
    n_list = list(bon_rates.keys())
    rates_list = list(bon_rates.values())

    if len(n_list) > 1:
        # Calculate derivative
        slopes = np.gradient(rates_list, n_list)

        # Add secondary y-axis for slope
        ax2 = ax1.twinx()
        line2 = ax2.plot(n_list[1:-1], slopes[1:-1], "r--", alpha=0.6, label="Rate of Improvement")
        ax2.set_ylabel("Rate of Improvement", color="r")
        ax2.tick_params(axis="y", labelcolor="r")
        
        # Combine legends
        lines = line1 + line2
        labels = [l.get_label() for l in lines]
        ax1.legend(lines, labels, loc='lower right')

    ax1.set_xlabel("Best-of-N")
    ax1.set_ylabel("Expected Success Rate", color="b")
    ax1.tick_params(axis="y", labelcolor="b")
    ax1.set_title("Success Rate vs Best-of-N Sampling\n(Steep curve indicates model has good solutions)")
    ax1.grid(True, alpha=0.3)
    
    # Add annotation box explaining the lines
    textstr = 'Blue line: Expected success rate\nRed line: Rate of improvement (derivative)'
    props = dict(boxstyle='round', facecolor='wheat', alpha=0.5)
    ax1.text(0.05, 0.95, textstr, transform=ax1.transAxes, fontsize=10,
            verticalalignment='top', bbox=props)
    
    plt.tight_layout()
    plt.savefig(output_dir / "success_over_n.png", dpi=300, bbox_inches="tight")
    plt.close()


def plot_level_success_over_n(level_data: Dict, output_dir: Path):
    """Plot success rate over N for a single level"""
    n_values = list(range(1, 65, 2))
    bon_rates = calculate_level_bon_success(level_data, n_values)
    
    plt.figure(figsize=(8, 6))
    plt.plot(list(bon_rates.keys()), list(bon_rates.values()), 'b-', linewidth=2, marker='o', markersize=4)
    
    # Add annotations
    base_rate = level_data.get("success_rate", 0)
    plt.axhline(y=base_rate, color='gray', linestyle=':', alpha=0.7, label=f'Base rate: {base_rate:.2%}')
    
    # Calculate BoN-64 rate (might not be in our n_values if step is 2)
    bon_64_rate = 1 - ((1 - base_rate) ** 64)
    plt.axhline(y=bon_64_rate, color='green', linestyle='--', alpha=0.7, label=f'BoN-64: {bon_64_rate:.2%}')
    
    plt.xlabel("Best-of-N")
    plt.ylabel("Success Rate")
    plt.title(f"Level {level_data['task_id']}: {level_data.get('level_name', '')}\nSuccess Rate vs Best-of-N")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.ylim(-0.05, 1.05)
    plt.tight_layout()
    
    # Save to subfolder
    level_dir = output_dir / "success_over_n"
    level_dir.mkdir(exist_ok=True)
    plt.savefig(level_dir / f"level_{level_data['task_id']}.png", dpi=300, bbox_inches="tight")
    plt.close()


def plot_first_success_histogram(first_success_attempts: np.ndarray, output_dir: Path):
    """Plot histogram of attempts until first success"""
    plt.figure(figsize=(10, 6))

    # Create bins for the histogram
    max_attempts = (
        int(np.ceil(np.max(first_success_attempts)))
        if len(first_success_attempts) > 0
        else 64
    )
    bins = np.linspace(1, min(max_attempts, 64), 20)

    plt.hist(
        first_success_attempts, bins=bins, alpha=0.7, color="blue", edgecolor="black"
    )

    # Add statistics
    if len(first_success_attempts) > 0:
        mean_attempts = np.mean(first_success_attempts)
        median_attempts = np.median(first_success_attempts)

        plt.axvline(
            mean_attempts,
            color="red",
            linestyle="--",
            linewidth=2,
            label=f"Mean: {mean_attempts:.1f}",
        )
        plt.axvline(
            median_attempts,
            color="green",
            linestyle="--",
            linewidth=2,
            label=f"Median: {median_attempts:.1f}",
        )

    plt.xlabel("Expected Attempts Until First Success")
    plt.ylabel("Number of Levels")
    plt.title("Distribution of Expected First Success\n(Lower values indicate faster RL convergence)")
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(
        output_dir / "first_success_histogram.png", dpi=300, bbox_inches="tight"
    )
    plt.close()


def plot_iteration_efficiency(efficiency_metrics: Dict, output_dir: Path):
    """Plot iteration efficiency metrics"""
    fig, (ax1, ax2, ax3) = plt.subplots(1, 3, figsize=(20, 6))

    # Left plot: Box plot showing distribution of iterations for successful attempts
    # This shows the spread of iteration counts across different levels
    successful_data = []
    labels = []
    
    if efficiency_metrics["min_iterations"]:
        successful_data.append(efficiency_metrics["min_iterations"])
        labels.append("Minimum\n(Best case)")
    
    if efficiency_metrics["avg_iterations"]:
        successful_data.append(efficiency_metrics["avg_iterations"])
        labels.append("Average\n(Typical case)")
        
    if efficiency_metrics["max_iterations"]:
        successful_data.append(efficiency_metrics["max_iterations"])
        labels.append("Maximum\n(Worst case)")

    if successful_data:
        bp = ax1.boxplot(successful_data, labels=labels, patch_artist=True)
        
        # Color the boxes
        colors = ['lightgreen', 'lightblue', 'lightcoral']
        for patch, color in zip(bp['boxes'], colors[:len(bp['boxes'])]):
            patch.set_facecolor(color)
        
        ax1.set_ylabel("Number of Iterations")
        ax1.set_title("Iteration Distribution for Successful Attempts\n(Shows variability in solution paths)")
        ax1.grid(True, alpha=0.3)
        
        # Add explanation
        ax1.text(0.02, 0.98, 
                "Each box shows the distribution across levels:\n" +
                "• Box = 25th-75th percentile\n" +
                "• Line = median\n" +
                "• Whiskers = min/max (excluding outliers)",
                transform=ax1.transAxes, 
                verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5),
                fontsize=9)

    # Middle plot: Histogram for successful iterations
    if efficiency_metrics["all_successful_iterations"]:
        all_successful = efficiency_metrics["all_successful_iterations"]
        
        ax2.hist(all_successful, bins=20, alpha=0.7, color="green", edgecolor="darkgreen")
        ax2.set_xlabel("Number of Iterations")
        ax2.set_ylabel("Frequency")
        ax2.set_title("Successful Attempts - Iteration Distribution")
        ax2.grid(True, alpha=0.3)
        
        # Add statistics
        mean_success = np.mean(all_successful)
        median_success = np.median(all_successful)
        ax2.axvline(mean_success, color='darkgreen', linestyle='--', linewidth=2, label=f'Mean: {mean_success:.1f}')
        ax2.axvline(median_success, color='darkgreen', linestyle=':', linewidth=2, label=f'Median: {median_success:.1f}')
        ax2.legend()

    # Right plot: Histogram for failed iterations
    if efficiency_metrics["failed_iterations"]:
        all_failed = efficiency_metrics["failed_iterations"]
        
        ax3.hist(all_failed, bins=20, alpha=0.7, color="red", edgecolor="darkred")
        ax3.set_xlabel("Number of Iterations")
        ax3.set_ylabel("Frequency")
        ax3.set_title("Failed Attempts - Iteration Distribution")
        ax3.grid(True, alpha=0.3)
        
        # Add statistics
        mean_failed = np.mean(all_failed)
        median_failed = np.median(all_failed)
        ax3.axvline(mean_failed, color='darkred', linestyle='--', linewidth=2, label=f'Mean: {mean_failed:.1f}')
        ax3.axvline(median_failed, color='darkred', linestyle=':', linewidth=2, label=f'Median: {median_failed:.1f}')
        ax3.legend()

    plt.tight_layout()
    plt.savefig(output_dir / "iteration_efficiency.png", dpi=300, bbox_inches="tight")
    plt.close()


def plot_tool_patterns(tool_patterns: Dict, output_dir: Path):
    """Plot tool usage patterns for successful vs failed attempts"""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))

    # Average tool usage comparison
    tools = set(tool_patterns["successful"].keys()) | set(
        tool_patterns["failed"].keys()
    )

    avg_successful = {}
    avg_failed = {}

    for tool in tools:
        if tool in tool_patterns["successful"] and tool_patterns["successful"][tool]:
            avg_successful[tool] = np.mean(tool_patterns["successful"][tool])
        if tool in tool_patterns["failed"] and tool_patterns["failed"][tool]:
            avg_failed[tool] = np.mean(tool_patterns["failed"][tool])

    # Sort tools by usage in successful attempts
    sorted_tools = sorted(
        avg_successful.keys(), key=lambda x: avg_successful.get(x, 0), reverse=True
    )

    x = np.arange(len(sorted_tools))
    width = 0.35

    successful_values = [avg_successful.get(tool, 0) for tool in sorted_tools]
    failed_values = [avg_failed.get(tool, 0) for tool in sorted_tools]

    ax1.bar(
        x - width / 2,
        successful_values,
        width,
        label="Successful",
        color="green",
        alpha=0.7,
    )
    ax1.bar(x + width / 2, failed_values, width, label="Failed", color="red", alpha=0.7)

    ax1.set_xlabel("Tools")
    ax1.set_ylabel("Average Usage Count")
    ax1.set_title("Tool Usage Patterns: Success vs Failure")
    ax1.set_xticks(x)
    ax1.set_xticklabels(sorted_tools, rotation=45, ha="right")
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Total tool calls distribution
    successful_total = tool_patterns["tool_sequences"]["successful"]
    failed_total = tool_patterns["tool_sequences"]["failed"]

    if successful_total and failed_total:
        bins = np.linspace(0, max(max(successful_total), max(failed_total)), 20)

        ax2.hist(
            successful_total,
            bins=bins,
            alpha=0.6,
            label="Successful",
            color="green",
            density=True,
        )
        ax2.hist(
            failed_total,
            bins=bins,
            alpha=0.6,
            label="Failed",
            color="red",
            density=True,
        )
        ax2.set_xlabel("Total Tool Calls")
        ax2.set_ylabel("Density")
        ax2.set_title("Distribution of Total Tool Calls")
        ax2.legend()
        ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(output_dir / "tool_patterns.png", dpi=300, bbox_inches="tight")
    plt.close()


def plot_optimal_turns(turn_data: Dict, output_dir: Path):
    """Plot histogram of successes and failures against number of turns"""
    plt.figure(figsize=(10, 6))
    
    # Sort turns
    turns = sorted(turn_data.keys())
    success_counts = [turn_data[t]["success"] for t in turns]
    failure_counts = [-turn_data[t]["failure"] for t in turns]  # Negative for below axis
    
    # Create stacked bar chart
    width = 0.8
    x = np.arange(len(turns))
    
    # Plot successes above zero
    plt.bar(x, success_counts, width, label="Successes", color="green", alpha=0.7)
    
    # Plot failures below zero
    plt.bar(x, failure_counts, width, label="Failures", color="red", alpha=0.7)
    
    # Add zero line
    plt.axhline(y=0, color='black', linewidth=1)
    
    # Find peak success
    if success_counts:
        peak_idx = np.argmax(success_counts)
        peak_turns = turns[peak_idx]
        plt.axvline(
            x=peak_idx,
            color="darkgreen",
            linestyle="--",
            linewidth=2,
            label=f"Peak success at {peak_turns} turns",
        )
    
    # Set labels
    plt.xlabel("Number of Turns (Iterations)")
    plt.ylabel("Count (Negative = Failures)")
    plt.title("Success and Failure Distribution by Turn Count\n(Shows optimal number of iterations)")
    plt.xticks(x[::2], turns[::2])  # Show every other tick to avoid crowding
    plt.legend()
    plt.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig(output_dir / "optimal_turns.png", dpi=300, bbox_inches="tight")
    plt.close()


def plot_performance_deterioration(df: pd.DataFrame, output_dir: Path):
    """Plot performance deterioration over level difficulty"""
    fig, (ax1, ax2, ax3) = plt.subplots(3, 1, figsize=(12, 10))

    # Success rate over levels
    ax1.plot(df["level"], df["success_rate"], "b-", linewidth=2, marker="o")
    ax1.fill_between(df["level"], df["success_rate"], alpha=0.3)
    ax1.set_ylabel("Success Rate")
    ax1.set_title("Performance Deterioration Over Level Difficulty")
    ax1.grid(True, alpha=0.3)
    ax1.set_ylim(-0.05, 1.05)

    # Average tool calls over levels
    ax2.plot(df["level"], df["avg_tool_calls"], "g-", linewidth=2, marker="s")
    ax2.set_ylabel("Average Tool Calls")
    ax2.set_title("Tool Usage Complexity Over Levels")
    ax2.grid(True, alpha=0.3)

    # Execution time over levels
    ax3.plot(df["level"], df["avg_execution_time"], "r-", linewidth=2, marker="^")
    ax3.set_xlabel("Level")
    ax3.set_ylabel("Average Execution Time (s)")
    ax3.set_title("Execution Time Over Levels")
    ax3.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(
        output_dir / "performance_deterioration.png", dpi=300, bbox_inches="tight"
    )
    plt.close()


def generate_rl_insights_report(data: Dict, output_dir: Path):
    """Generate a comprehensive report with RL insights"""
    report = []
    report.append("# RL Simulation Analysis Report\n")

    # Best-of-N analysis
    n_values = [1, 4, 16, 32, 64]
    bon_rates = calculate_bon_success_rates(data["detailed_results"], n_values)

    report.append("## Best-of-N Success Rates\n")
    for n, rate in bon_rates.items():
        report.append(f"- Best-of-{n}: {rate:.2%} success rate\n")

    # Calculate improvement potential
    if 1 in bon_rates and 64 in bon_rates:
        improvement = bon_rates[64] - bon_rates[1]
        report.append(
            f"\n**RL Potential**: {improvement:.2%} improvement from N=1 to N=64\n"
        )

    # First success analysis
    first_success = analyze_first_success_distribution(data)
    if len(first_success) > 0:
        report.append("\n## Expected First Success Distribution\n")
        report.append(
            f"- Mean attempts to first success: {np.mean(first_success):.1f}\n"
        )
        report.append(
            f"- Median attempts to first success: {np.median(first_success):.1f}\n"
        )
        report.append(
            f"- Levels that converge within 10 attempts: {np.sum(first_success <= 10)}\n"
        )

    # Iteration efficiency
    efficiency = analyze_iteration_efficiency(data)
    if efficiency["avg_iterations"]:
        report.append("\n## Iteration Efficiency\n")
        report.append(
            f"- Average iterations for success: {np.mean(efficiency['avg_iterations']):.1f}\n"
        )
        report.append(
            f"- Minimum iterations observed: {np.min(efficiency['min_iterations'])}\n"
        )
        report.append(
            f"- Maximum iterations observed: {np.max(efficiency['max_iterations'])}\n"
        )

    # Tool patterns
    tool_patterns = analyze_tool_patterns(data)
    if tool_patterns["tool_sequences"]["successful"]:
        report.append("\n## Tool Usage Insights\n")
        avg_successful_tools = np.mean(tool_patterns["tool_sequences"]["successful"])
        avg_failed_tools = (
            np.mean(tool_patterns["tool_sequences"]["failed"])
            if tool_patterns["tool_sequences"]["failed"]
            else 0
        )
        report.append(f"- Average tools for success: {avg_successful_tools:.1f}\n")
        report.append(f"- Average tools for failure: {avg_failed_tools:.1f}\n")
        if avg_failed_tools > 0:
            report.append(
                f"- Tool efficiency ratio: {avg_successful_tools/avg_failed_tools:.2f}\n"
            )

    # Save report
    with open(output_dir / "rl_insights_report.md", "w") as f:
        f.writelines(report)


def run_analysis(benchmark_file: str, output_dir: str = None):
    """Run the complete RL analysis"""
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

    # Perform analyses
    print("Analyzing performance deterioration...")
    perf_df = analyze_performance_by_difficulty(data)
    plot_performance_deterioration(perf_df, output_dir)

    print("Analyzing Best-of-N success rates...")
    plot_success_over_n(data, output_dir)
    
    # Generate per-level success_over_n charts
    print("Generating per-level Best-of-N charts...")
    for level in data["detailed_results"]:
        plot_level_success_over_n(level, output_dir)

    print("Analyzing first success distribution...")
    first_success = analyze_first_success_distribution(data)
    plot_first_success_histogram(first_success, output_dir)

    print("Analyzing iteration efficiency...")
    efficiency = analyze_iteration_efficiency(data)
    plot_iteration_efficiency(efficiency, output_dir)

    print("Analyzing tool patterns...")
    tool_patterns = analyze_tool_patterns(data)
    plot_tool_patterns(tool_patterns, output_dir)

    print("Analyzing optimal turn counts...")
    turn_data = analyze_optimal_turns(data)
    plot_optimal_turns(turn_data, output_dir)

    print("Generating RL insights report...")
    generate_rl_insights_report(data, output_dir)

    return output_dir


def main():
    parser = argparse.ArgumentParser(
        description="Analyze benchmark results for RL simulation"
    )
    parser.add_argument("benchmark_file", type=str, help="Path to benchmark.json file")
    parser.add_argument(
        "--output_dir",
        type=str,
        default=None,
        help="Directory to save analysis results (default: same as benchmark.json)",
    )

    args = parser.parse_args()
    
    output_dir = run_analysis(args.benchmark_file, args.output_dir)
    
    print(f"\nAnalysis complete! Results saved to {output_dir}/")
    print("\nKey files generated:")
    print("- performance_deterioration.png: Shows how performance changes with level difficulty")
    print("- success_over_n.png: Best-of-N success rates (steep curve = good RL potential)")
    print("- success_over_n/level_*.png: Individual level Best-of-N curves")
    print("- first_success_histogram.png: Distribution of expected first success attempts")
    print("- iteration_efficiency.png: Analysis of turns needed for success")
    print("- tool_patterns.png: Tool usage patterns in successful vs failed attempts")
    print("- optimal_turns.png: Success/failure distribution by number of turns")
    print("- rl_insights_report.md: Comprehensive text report with key findings")


if __name__ == "__main__":
    main()