import json
from charts import generate_analysis_graphs

if __name__ == "__main__":
    with open(
        "analysis_openrouter_gpt-4o_2runs_1751433041.json",
        "r",
    ) as f:
        analysis = json.load(f)
    with open(
        "benchmark_openrouter_gpt-4o_2runs_1751433041.json",
        "r",
    ) as f:
        results = json.load(f)
    generate_analysis_graphs(
        analysis, results, output_dir=f"./charts_openrouter_gpt-4o_3runs_1751432429"
    )
