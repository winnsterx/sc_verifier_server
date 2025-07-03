# Benchmark Analysis Guide

This guide explains how to use the analysis scripts to evaluate RL potential from benchmark data.

## Prerequisites

Make sure you have the required dependencies:
```bash
pip install numpy matplotlib seaborn pandas scipy
```

## Running the Analyses

### 1. Basic RL Analysis

```bash
python rl_analysis.py path/to/benchmark.json --output_dir analysis_results
```

This generates:
- **performance_deterioration.png**: Shows how model performance changes with increasing level difficulty
- **success_over_n.png**: Best-of-N success rates (steep curve indicates high RL potential)
- **first_success_histogram.png**: Distribution of expected attempts until first success
- **iteration_efficiency.png**: Analysis of turns/iterations needed for success
- **tool_patterns.png**: Comparison of tool usage in successful vs failed attempts
- **optimal_turns.png**: Histogram showing relationship between turn count and success
- **rl_insights_report.md**: Text report with key findings

### 2. Advanced RL Analysis

```bash
python rl_advanced_analysis.py path/to/benchmark.json --output_dir advanced_results
```

This generates:
- **rl_learning_curves.png**: Learning curves categorized by difficulty level
- **convergence_heatmap.png**: Heatmap showing when RL is likely to converge for each level
- **rl_potential_dashboard.png**: Comprehensive dashboard with RL potential score and key metrics
- **advanced_rl_analysis.md**: Detailed analysis with recommendations

## Understanding the Results

### RL Potential Score (0-100)
- **70-100**: Excellent RL potential - significant improvements expected
- **40-70**: Good RL potential - moderate improvements likely
- **20-40**: Limited RL potential - some improvements possible
- **0-20**: Low RL potential - model may already be near-optimal

### Key Indicators of High RL Potential

1. **Steep Best-of-N Curve**: Rapid improvement from N=1 to N=64 indicates the model has good solutions but needs help finding them consistently

2. **Fast Convergence**: Levels that converge within 10-20 attempts suggest RL can quickly learn optimal strategies

3. **Consistent Tool Patterns**: If successful attempts use similar tool sequences, RL can learn these patterns

4. **Performance Variance**: High variance in success rates across levels indicates room for improvement on harder tasks

### Example Interpretation

If your analysis shows:
- RL Potential Score: 65/100
- Average convergence: 15 steps
- Improvement from N=1 to N=64: 45%

This suggests:
- Strong potential for RL to improve performance
- RL would converge relatively quickly (15 steps on average)
- You could expect ~45% improvement in success rate with proper RL training

## Recommendations Based on Results

### High RL Potential (Score > 50)
- Proceed with RL implementation
- Focus on levels with 10-50% base success rate
- Use successful tool sequences as reward signals

### Medium RL Potential (Score 25-50)
- RL may help on specific difficult levels
- Consider targeted RL for levels with near-miss attempts
- Analyze tool patterns for optimization opportunities

### Low RL Potential (Score < 25)
- Model may already be near-optimal
- Consider other approaches (prompt engineering, tool improvements)
- Focus on completely failed levels that may need different strategies

## Next Steps

1. Run both analysis scripts on your benchmark data
2. Review the generated visualizations and reports
3. Identify levels with highest RL potential
4. Design reward functions based on successful tool patterns
5. Implement RL training focusing on high-potential levels