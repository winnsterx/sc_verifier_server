import weave


@weave.op
def analyze_best_of_n_for_rl(benchmark_results, n_values=[1, 3, 5, 10]):
    """Analyze best-of-N with metrics relevant for RL simulation"""
    analysis = {}

    for n in n_values:
        level_analyses = []

        for level_result in benchmark_results["detailed_results"]:
            runs = level_result["individual_runs"]

            # Skip if not enough data
            if len(runs) < 2:
                continue

            # Extract run metrics
            run_metrics = []
            for run in runs:
                if "total_tool_calls" in run:
                    run_metrics.append(
                        {
                            "solved": run.get("solved", False),
                            "tool_calls": run["total_tool_calls"],
                            "execution_time": run.get("execution_time", float("inf")),
                            "iterations": run.get("iterations", 0),
                            "tool_usage": run.get("tool_usage", {}),
                            "errors": len(run.get("errors", [])),
                        }
                    )

            if not run_metrics:
                continue

            # Calculate performance scores (lower is better)
            # This scoring function can be customized based on what you value
            for metric in run_metrics:
                if metric["solved"]:
                    # Reward efficiency for successful runs
                    metric["score"] = (
                        metric["tool_calls"] * 1.0  # Tool call cost
                        + metric["execution_time"] * 0.1  # Time cost
                        + metric["errors"] * 5.0  # Error penalty
                    )
                else:
                    # Heavy penalty for failure
                    metric["score"] = 1000 + metric["tool_calls"]

            # Sort by score (best first)
            sorted_metrics = sorted(run_metrics, key=lambda x: x["score"])

            # Simulate best-of-N selection
            best_n_metrics = sorted_metrics[: min(n, len(sorted_metrics))]
            best_run = best_n_metrics[0]

            # Calculate diversity metrics
            if len(sorted_metrics) >= 2:
                # Tool usage diversity (how different are the approaches?)
                tool_patterns = []
                for m in sorted_metrics[:n]:
                    pattern = tuple(sorted(m["tool_usage"].items()))
                    tool_patterns.append(pattern)

                unique_patterns = len(set(tool_patterns))
                diversity_score = unique_patterns / min(n, len(tool_patterns))
            else:
                diversity_score = 0

            # Calculate improvement potential
            if len([m for m in run_metrics if m["solved"]]) > 0:
                successful_scores = [m["score"] for m in run_metrics if m["solved"]]
                best_possible = min(successful_scores)
                avg_successful = sum(successful_scores) / len(successful_scores)
                improvement_ratio = (
                    (avg_successful - best_possible) / avg_successful
                    if avg_successful > 0
                    else 0
                )
            else:
                improvement_ratio = 0

            # Value of additional samples (diminishing returns)
            success_by_n = []
            for i in range(1, min(n + 1, len(sorted_metrics) + 1)):
                success_by_n.append(any(m["solved"] for m in sorted_metrics[:i]))

            marginal_value = []
            for i in range(1, len(success_by_n)):
                marginal_value.append(int(success_by_n[i]) - int(success_by_n[i - 1]))

            level_analysis = {
                "level_id": level_result["task_id"],
                "level_name": level_result["level_name"],
                "best_score": best_run["score"] if run_metrics else float("inf"),
                "best_solved": best_run["solved"] if run_metrics else False,
                "best_tool_calls": best_run["tool_calls"] if run_metrics else 0,
                "avg_score_successful": (
                    avg_successful if "avg_successful" in locals() else float("inf")
                ),
                "improvement_ratio": improvement_ratio,
                "solution_diversity": diversity_score,
                "success_by_sample": success_by_n,
                "marginal_value": marginal_value,
                "tool_usage_variance": calculate_tool_variance(run_metrics),
                "failure_modes": analyze_failure_modes(run_metrics),
            }

            level_analyses.append(level_analysis)

        # Aggregate statistics for this N
        if level_analyses:
            analysis[f"best_of_{n}"] = {
                "avg_best_score": sum(la["best_score"] for la in level_analyses)
                / len(level_analyses),
                "success_rate": sum(1 for la in level_analyses if la["best_solved"])
                / len(level_analyses),
                "avg_improvement_ratio": sum(
                    la["improvement_ratio"] for la in level_analyses
                )
                / len(level_analyses),
                "avg_diversity": sum(la["solution_diversity"] for la in level_analyses)
                / len(level_analyses),
                "levels_needing_n_samples": count_samples_needed(level_analyses, n),
                "expected_tool_calls": sum(
                    la["best_tool_calls"] for la in level_analyses
                )
                / len(level_analyses),
                "high_variance_levels": [
                    la for la in level_analyses if la["tool_usage_variance"] > 0.5
                ],
                "detailed_levels": level_analyses,
            }

    # Add RL-specific insights
    analysis["rl_insights"] = generate_rl_insights(analysis, benchmark_results)

    return analysis


def calculate_tool_variance(run_metrics):
    """Calculate variance in tool usage patterns"""
    if len(run_metrics) < 2:
        return 0

    tool_vectors = []
    all_tools = set()

    for metric in run_metrics:
        for tool in metric["tool_usage"]:
            all_tools.add(tool)

    for metric in run_metrics:
        vector = [metric["tool_usage"].get(tool, 0) for tool in sorted(all_tools)]
        tool_vectors.append(vector)

    # Calculate variance across dimensions
    if not tool_vectors or not tool_vectors[0]:
        return 0

    variances = []
    for i in range(len(tool_vectors[0])):
        values = [v[i] for v in tool_vectors]
        if values:
            mean = sum(values) / len(values)
            variance = sum((x - mean) ** 2 for x in values) / len(values)
            variances.append(variance)

    return sum(variances) / len(variances) if variances else 0


def analyze_failure_modes(run_metrics):
    """Identify common failure patterns"""
    failures = [m for m in run_metrics if not m["solved"]]
    if not failures:
        return {}

    failure_patterns = {
        "high_tool_usage": len([f for f in failures if f["tool_calls"] > 15]),
        "early_failure": len([f for f in failures if f["iterations"] < 3]),
        "error_related": len([f for f in failures if f["errors"] > 0]),
        "timeout": len([f for f in failures if f["iterations"] >= 20]),
    }

    return failure_patterns


def count_samples_needed(level_analyses, max_n):
    """Count how many samples each level needs for success"""
    distribution = {i: 0 for i in range(1, max_n + 1)}

    for la in level_analyses:
        for i, success in enumerate(la["success_by_sample"], 1):
            if success:
                distribution[i] += 1
                break

    return distribution


def generate_rl_insights(analysis, benchmark_results):
    """Generate insights specifically useful for RL training"""
    insights = {
        "action_space_complexity": estimate_action_space(benchmark_results),
        "exploration_value": calculate_exploration_value(analysis),
        "optimal_n_by_level": determine_optimal_n(analysis),
        "reward_shaping_suggestions": suggest_reward_shaping(analysis),
        "curriculum_learning_order": suggest_curriculum(analysis),
    }

    return insights


def estimate_action_space(benchmark_results):
    """Estimate the complexity of the action space"""
    total_unique_actions = set()
    avg_actions_per_level = []

    for level in benchmark_results["detailed_results"]:
        level_actions = set()
        for run in level["individual_runs"]:
            if "tool_usage" in run:
                for tool, count in run["tool_usage"].items():
                    total_unique_actions.add(tool)
                    level_actions.add(tool)

        if level_actions:
            avg_actions_per_level.append(len(level_actions))

    return {
        "total_unique_actions": len(total_unique_actions),
        "avg_actions_per_level": (
            sum(avg_actions_per_level) / len(avg_actions_per_level)
            if avg_actions_per_level
            else 0
        ),
        "action_distribution": benchmark_results.get("tool_usage_total", {}),
    }


def calculate_exploration_value(analysis):
    """Calculate the value of exploration (trying multiple approaches)"""
    exploration_benefits = []

    for n_key in analysis:
        if n_key.startswith("best_of_") and "detailed_levels" in analysis[n_key]:
            n = int(n_key.split("_")[-1])
            for level in analysis[n_key]["detailed_levels"]:
                if level["improvement_ratio"] > 0:
                    exploration_benefits.append(
                        {
                            "level": level["level_name"],
                            "n": n,
                            "improvement": level["improvement_ratio"],
                            "diversity": level["solution_diversity"],
                        }
                    )

    return exploration_benefits


def determine_optimal_n(analysis):
    """Determine optimal N for each level based on cost-benefit"""
    optimal_n = {}

    # Compare different N values for each level
    level_data = {}
    for n_key in analysis:
        if n_key.startswith("best_of_") and "detailed_levels" in analysis[n_key]:
            n = int(n_key.split("_")[-1])
            for level in analysis[n_key]["detailed_levels"]:
                if level["level_name"] not in level_data:
                    level_data[level["level_name"]] = []
                level_data[level["level_name"]].append(
                    {
                        "n": n,
                        "success": level["best_solved"],
                        "cost": level["best_tool_calls"] * n,
                        "marginal_value": level["marginal_value"],
                    }
                )

    # Find optimal N for each level
    for level_name, data in level_data.items():
        # Find minimum N that achieves success
        successful_n = [d["n"] for d in data if d["success"]]
        if successful_n:
            optimal_n[level_name] = {
                "optimal_n": min(successful_n),
                "expected_cost": min(d["cost"] for d in data if d["success"]),
            }
        else:
            optimal_n[level_name] = {
                "optimal_n": "unsolved",
                "expected_cost": float("inf"),
            }

    return optimal_n


def suggest_reward_shaping(analysis):
    """Suggest reward shaping based on the analysis"""
    suggestions = {
        "efficiency_weight": 0.3,  # How much to weight efficiency vs success
        "exploration_bonus": 0.1,  # Bonus for trying diverse approaches
        "penalty_structure": {
            "per_tool_call": -0.1,
            "per_error": -0.5,
            "timeout": -10.0,
            "success": 10.0,
        },
        "level_specific_adjustments": {},
    }

    # Adjust based on level difficulty
    for n_key in analysis:
        if n_key == "best_of_1" and "detailed_levels" in analysis[n_key]:
            for level in analysis[n_key]["detailed_levels"]:
                if level["best_solved"]:
                    # Easy level - emphasize efficiency
                    suggestions["level_specific_adjustments"][level["level_name"]] = {
                        "efficiency_multiplier": 1.5
                    }
                else:
                    # Hard level - emphasize exploration
                    suggestions["level_specific_adjustments"][level["level_name"]] = {
                        "exploration_multiplier": 2.0
                    }

    return suggestions


def suggest_curriculum(analysis):
    """Suggest curriculum learning order based on difficulty and learning value"""
    levels = []

    # Collect level statistics
    if "best_of_1" in analysis and "detailed_levels" in analysis["best_of_1"]:
        for level in analysis["best_of_1"]["detailed_levels"]:
            levels.append(
                {
                    "name": level["level_name"],
                    "difficulty": 1 - (1 if level["best_solved"] else 0),
                    "learning_value": level["solution_diversity"],
                    "avg_tools": level["best_tool_calls"],
                }
            )

    # Sort by difficulty then by learning value
    curriculum = sorted(levels, key=lambda x: (x["difficulty"], -x["learning_value"]))

    return {
        "suggested_order": [l["name"] for l in curriculum],
        "difficulty_progression": [l["difficulty"] for l in curriculum],
        "rationale": "Start with easier levels to build foundation, prioritize high learning value",
    }
