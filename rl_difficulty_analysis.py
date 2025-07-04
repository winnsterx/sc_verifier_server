import json
import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict
import os

def load_gamedata():
    """Load gamedata.json to get difficulty mappings"""
    gamedata = {
        "levels": [
            {"name": "Hello Ethernaut", "difficulty": "0", "deployId": "0"},
            {"name": "Fallback", "difficulty": "1", "deployId": "1"},
            {"name": "Fallout", "difficulty": "2", "deployId": "2"},
            {"name": "Coin Flip", "difficulty": "3", "deployId": "3"},
            {"name": "Telephone", "difficulty": "1", "deployId": "4"},
            {"name": "Token", "difficulty": "3", "deployId": "5"},
            {"name": "Delegation", "difficulty": "4", "deployId": "6"},
            {"name": "Force", "difficulty": "5", "deployId": "7"},
            {"name": "Vault", "difficulty": "3", "deployId": "8"},
            {"name": "King", "difficulty": "6", "deployId": "9"},
            {"name": "Re-entrancy", "difficulty": "6", "deployId": "10"},
            {"name": "Elevator", "difficulty": "4", "deployId": "11"},
            {"name": "Privacy", "difficulty": "6", "deployId": "12"},
            {"name": "Gatekeeper One", "difficulty": "8", "deployId": "13"},
            {"name": "Gatekeeper Two", "difficulty": "6", "deployId": "14"},
            {"name": "Naught Coin", "difficulty": "5", "deployId": "15"},
            {"name": "Preservation", "difficulty": "8", "deployId": "16"},
            {"name": "Recovery", "difficulty": "6", "deployId": "17"},
            {"name": "MagicNumber", "difficulty": "6", "deployId": "18"},
            {"name": "Alien Codex", "difficulty": "7", "deployId": "19"},
            {"name": "Denial", "difficulty": "5", "deployId": "20"},
            {"name": "Shop", "difficulty": "4", "deployId": "21"},
            {"name": "Dex", "difficulty": "3", "deployId": "22"},
            {"name": "Dex Two", "difficulty": "4", "deployId": "23"},
            {"name": "Puzzle Wallet", "difficulty": "7", "deployId": "24"},
            {"name": "Motorbike", "difficulty": "6", "deployId": "25"},
            {"name": "DoubleEntryPoint", "difficulty": "4", "deployId": "26"},
            {"name": "Good Samaritan", "difficulty": "5", "deployId": "27"},
            {"name": "Gatekeeper Three", "difficulty": "6", "deployId": "28"},
            {"name": "Switch", "difficulty": "8", "deployId": "29"},
            {"name": "HigherOrder", "difficulty": "8", "deployId": "30"},
            {"name": "Stake", "difficulty": "6", "deployId": "31"},
            {"name": "Impersonator", "difficulty": "8", "deployId": "32"},
            {"name": "Magic Animal Carousel", "difficulty": "6", "deployId": "33"}
        ]
    }
    
    # Create mapping from level_id to difficulty
    difficulty_map = {}
    for level in gamedata["levels"]:
        difficulty_map[int(level["deployId"])] = int(level["difficulty"])
    
    return difficulty_map

def categorize_by_difficulty(difficulty_map):
    """Categorize levels into 5 difficulty groups"""
    # Define difficulty categories
    categories = {
        "Very Easy (0-1)": [],
        "Easy (2-3)": [],
        "Medium (4-5)": [],
        "Hard (6-7)": [],
        "Very Hard (8)": []
    }
    
    for level_id, difficulty in difficulty_map.items():
        if difficulty <= 1:
            categories["Very Easy (0-1)"].append(level_id)
        elif difficulty <= 3:
            categories["Easy (2-3)"].append(level_id)
        elif difficulty <= 5:
            categories["Medium (4-5)"].append(level_id)
        elif difficulty <= 7:
            categories["Hard (6-7)"].append(level_id)
        else:
            categories["Very Hard (8)"].append(level_id)
    
    return categories

def compute_rl_curves(benchmark_data, categories):
    """Compute RL learning curves for each difficulty category"""
    curves = {}
    
    for category, level_ids in categories.items():
        if not level_ids:
            continue
            
        # Collect all runs for this difficulty category
        all_runs = []
        for result in benchmark_data["detailed_results"]:
            if result["task_id"] in level_ids:
                for run in result["individual_runs"]:
                    all_runs.append({
                        "run_index": run.get("run_id", 0),  # Use run_id if available
                        "solved": run.get("solved", False),
                        "level_id": result["task_id"]
                    })
        
        if not all_runs:
            continue
            
        # Sort runs by run_index to simulate RL progression
        all_runs.sort(key=lambda x: (x["run_index"], x["level_id"]))
        
        # Compute cumulative success rate for Best-of-N
        n_values = [1, 2, 4, 8, 16, 32, 64]
        success_rates = []
        
        for n in n_values:
            if n > 64:  # We only have 64 runs per level
                break
                
            # For each level, check if ANY of the first N runs solved it
            successes = 0
            for level_id in level_ids:
                level_runs = [r for r in all_runs if r["level_id"] == level_id and r["run_index"] < n]
                if any(r["solved"] for r in level_runs):
                    successes += 1
            
            success_rate = successes / len(level_ids) if level_ids else 0
            success_rates.append(success_rate)
        
        curves[category] = {
            "n_values": n_values[:len(success_rates)],
            "success_rates": success_rates,
            "n_levels": len(level_ids)
        }
    
    return curves

def plot_rl_curves_by_difficulty(curves, output_path):
    """Create a figure with 5 subplots for each difficulty category"""
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('RL Learning Curves by Difficulty Category', fontsize=16)
    
    # Flatten axes for easier iteration
    axes_flat = axes.flatten()
    
    # Order categories from easiest to hardest
    category_order = ["Very Easy (0-1)", "Easy (2-3)", "Medium (4-5)", "Hard (6-7)", "Very Hard (8)"]
    
    for idx, category in enumerate(category_order):
        ax = axes_flat[idx]
        
        if category in curves:
            data = curves[category]
            n_values = data["n_values"]
            success_rates = data["success_rates"]
            n_levels = data["n_levels"]
            
            # Plot actual performance
            ax.plot(n_values, success_rates, 'b-o', linewidth=2, markersize=8, label='Actual')
            
            # Plot fitted curve (logarithmic fit)
            if len(n_values) > 1:
                log_n = np.log(n_values)
                coeffs = np.polyfit(log_n, success_rates, 1)
                fitted_n = np.logspace(0, np.log10(max(n_values)), 100)
                fitted_rates = coeffs[0] * np.log(fitted_n) + coeffs[1]
                fitted_rates = np.clip(fitted_rates, 0, 1)
                ax.plot(fitted_n, fitted_rates, 'r--', linewidth=2, alpha=0.7, label=f'Fitted (R²={np.corrcoef(log_n, success_rates)[0,1]**2:.3f})')
            
            # Add asymptote line
            ax.axhline(y=1.0, color='gray', linestyle=':', alpha=0.5, label='Asymptote: 1.00')
            
            ax.set_xlabel('Best-of-N')
            ax.set_ylabel('Success Rate')
            ax.set_title(f'{category} (n={n_levels})')
            ax.set_xscale('log')
            ax.set_ylim(-0.05, 1.05)
            ax.grid(True, alpha=0.3)
            ax.legend(fontsize=8)
            
        else:
            ax.text(0.5, 0.5, 'No levels in this category', 
                   ha='center', va='center', transform=ax.transAxes)
            ax.set_title(f'{category} (n=0)')
            ax.axis('off')
    
    # Remove the extra subplot
    axes_flat[-1].axis('off')
    
    plt.tight_layout()
    plt.savefig(output_path, dpi=300, bbox_inches='tight')
    plt.close()

def compute_first_success_distribution(benchmark_data, level_ids):
    """Compute first success attempt distribution for given levels"""
    first_successes = []
    
    for result in benchmark_data["detailed_results"]:
        if result["task_id"] in level_ids:
            # Find first successful run
            for idx, run in enumerate(result["individual_runs"]):
                if run.get("solved", False):
                    first_successes.append(idx + 1)  # 1-indexed
                    break
            else:
                # No success found
                first_successes.append(None)
    
    return first_successes

def plot_first_success_histograms(benchmark_data, categories):
    """Create first success histograms for each difficulty category"""
    os.makedirs('charts/first_success', exist_ok=True)
    
    # Order categories from easiest to hardest
    category_order = ["Very Easy (0-1)", "Easy (2-3)", "Medium (4-5)", "Hard (6-7)", "Very Hard (8)"]
    
    for category in category_order:
        if category not in categories:
            continue
            
        level_ids = categories[category]
        if not level_ids:
            continue
            
        # Get first success distribution
        first_successes = compute_first_success_distribution(benchmark_data, level_ids)
        
        # Separate successful and failed attempts
        successful_attempts = [x for x in first_successes if x is not None]
        failed_count = len([x for x in first_successes if x is None])
        
        # Create figure
        fig, ax = plt.subplots(figsize=(10, 6))
        
        if successful_attempts:
            # Create histogram
            bins = np.arange(1, max(successful_attempts) + 2, 1)
            n, bins, patches = ax.hist(successful_attempts, bins=bins, alpha=0.7, color='blue', edgecolor='black')
            
            # Add statistics
            mean_attempts = np.mean(successful_attempts)
            median_attempts = np.median(successful_attempts)
            
            # Add vertical lines for mean and median
            ax.axvline(mean_attempts, color='red', linestyle='--', linewidth=2, label=f'Mean: {mean_attempts:.1f}')
            ax.axvline(median_attempts, color='green', linestyle='--', linewidth=2, label=f'Median: {median_attempts:.1f}')
        
        # Add failed count as text
        if failed_count > 0:
            ax.text(0.98, 0.98, f'Never succeeded: {failed_count} levels', 
                   transform=ax.transAxes, ha='right', va='top', 
                   bbox=dict(boxstyle='round', facecolor='red', alpha=0.3))
        
        # Customize plot
        ax.set_xlabel('First Success Attempt Number')
        ax.set_ylabel('Number of Levels')
        ax.set_title(f'First Success Distribution - {category}\n(n={len(level_ids)} levels)')
        ax.grid(True, alpha=0.3)
        
        if successful_attempts:
            ax.legend()
            ax.set_xlim(0, min(65, max(successful_attempts) + 2))
        else:
            ax.text(0.5, 0.5, 'No successful attempts', 
                   transform=ax.transAxes, ha='center', va='center', fontsize=20)
        
        # Save plot
        filename = category.lower().replace(' ', '_').replace('(', '').replace(')', '').replace('-', '_')
        output_path = f'charts/first_success/{filename}.png'
        plt.tight_layout()
        plt.savefig(output_path, dpi=300, bbox_inches='tight')
        plt.close()
        
        print(f"Saved: {output_path}")

def main():
    # Load data
    with open('benchmark.json', 'r') as f:
        benchmark_data = json.load(f)
    
    # Get difficulty mapping
    difficulty_map = load_gamedata()
    
    # Categorize levels by difficulty
    categories = categorize_by_difficulty(difficulty_map)
    
    # Print category information
    print("Difficulty Categories:")
    for category, levels in categories.items():
        print(f"{category}: {len(levels)} levels - {levels}")
    
    # Compute RL curves
    curves = compute_rl_curves(benchmark_data, categories)
    
    # Create output directory if it doesn't exist
    os.makedirs('charts', exist_ok=True)
    
    # Plot and save RL curves
    output_path = 'charts/rl_learning_curves_by_difficulty.png'
    plot_rl_curves_by_difficulty(curves, output_path)
    print(f"\nChart saved to: {output_path}")
    
    # Create first success histograms
    print("\nGenerating first success histograms...")
    plot_first_success_histograms(benchmark_data, categories)
    print("\nAll first success histograms generated!")

if __name__ == "__main__":
    main()