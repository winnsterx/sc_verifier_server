import os
import sys
import json
import time
import errno
import weave
import random
import contextlib
import socket
import requests
import argparse
import subprocess
from dotenv import load_dotenv
from pathlib import Path
import agent
from charts import generate_analysis_graphs
from analysis import analyze_best_of_n_for_rl

load_dotenv()
weave.init("smart-contract-auditor")


def wait_for_server(port, url="http://localhost", timeout=30):
    port
    """Wait for the server to be ready"""
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            # Use /level-context endpoint instead of root
            response = requests.get(f"{url}:{port}/level-context")
            if response.status_code == 200:
                print("✅ Server is ready!")
                return True
        except requests.exceptions.ConnectionError:
            pass
        print("⏳ Waiting for server to start...")
        time.sleep(1)
    return False


@weave.op
def test_single_level(task_id, level_info, provider, model, port, run_id=0):
    print(f"Testing level {task_id}: {level_info.get('name')}")
    handler_process = None
    try:
        handler_process = subprocess.Popen(
            [
                sys.executable,
                "handler.py",
                "--task_id",
                str(task_id),
                "--port",
                str(port),
            ],
            stdin=subprocess.DEVNULL,
            text=True,
            start_new_session=True,
        )

        time.sleep(2)

        if not wait_for_server(port):
            return {"task_id": task_id, "error": "Server is not up."}

        # Add try-except around agent.run to catch any errors
        try:
            print("Calling agent.run...")
            start_time = time.time()
            solved, messages, metrics = agent.run(provider, model, port)
            execution_time = time.time() - start_time
            print(
                f"Agent.run returned: solved={solved}, messages_count={len(messages)}"
            )

            if solved == True:
                print(f"Level {task_id} SOLVED!")
                return {
                    "task_id": task_id,
                    "level_name": level_info.get("name"),
                    "run_id": run_id,
                    "solved": solved,
                    "execution_time": execution_time,
                    "total_tool_calls": sum(metrics["tool_usage"].values()),
                    "tool_usage": metrics["tool_usage"],
                    "iterations": metrics["total_iterations"],
                    "conversation_length": metrics["conversation_length"],
                    "errors": metrics.get("errors", []),
                    "messages": messages,  # Optional: can be large
                }
            else:
                print(f"Level {task_id} FAILED...")
                return {
                    "task_id": task_id,
                    "level_name": level_info.get("name"),
                    "run_id": run_id,
                    "solved": solved,
                    "execution_time": execution_time,
                    "total_tool_calls": sum(metrics["tool_usage"].values()),
                    "tool_usage": metrics["tool_usage"],
                    "iterations": metrics["total_iterations"],
                    "conversation_length": metrics["conversation_length"],
                    "errors": metrics.get("errors", []),
                    "messages": messages,  # Optional: can be large
                }

        except Exception as e:
            print(f"Outer exception: {type(e).__name__}: {e}")
            return {
                "task_id": task_id,
                "level_name": level_info.get("name"),
                "run_id": run_id,
                "solved": False,
                "error": str(e),
                "execution_time": time.time() - start_time,
            }
    finally:
        print("Entering finally block...")
        if handler_process:
            # Check if process is still alive
            if handler_process.poll() is None:
                print("Handler still running, terminating...")
                handler_process.terminate()
                try:
                    handler_process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    handler_process.kill()
                    handler_process.wait()
            else:
                print(f"Handler already exited with code: {handler_process.returncode}")
            print("Handler shut down")


@weave.op
def run_level_n_times(task_id, level_info, provider, model, port, n_runs=1):
    results = []
    for run_id in range(n_runs):
        print(f"\n{'='*60}")
        print(f"Starting run {run_id + 1}/{n_runs} for level {task_id}")
        print(f"{'='*60}")

        result = test_single_level(task_id, level_info, provider, model, port, run_id)
        results.append(result)

        time.sleep(2)

    successful_runs = [r for r in results if r.get("solved") == True]
    failed_runs = [r for r in results if r.get("solved") == False]

    tool_call_counts = [
        r.get("total_tool_calls", 0) for r in results if "total_tool_calls" in r
    ]

    aggregated_tool_usage = {}
    for r in results:
        if "tool_usage" in r:
            for tool, count in result["tool_usage"].items():
                aggregated_tool_usage[tool] = aggregated_tool_usage.get(tool, 0) + count

    metrics = {
        "task_id": task_id,
        "level_name": level_info.get("name"),
        "total_runs": n_runs,
        "successful_runs": len(successful_runs),
        "success_rate": len(successful_runs) / n_runs,
        "avg_tool_calls": (
            sum(tool_call_counts) / len(tool_call_counts) if tool_call_counts else 0
        ),
        "max_tool_calls": max(tool_call_counts) if tool_call_counts else 0,
        "min_tool_calls": min(tool_call_counts) if tool_call_counts else 0,
        "avg_execution_time": sum(r.get("execution_time", 0) for r in results)
        / len(results),
        "tool_usage_total": aggregated_tool_usage,
        "tool_usage_avg": {k: v / n_runs for k, v in aggregated_tool_usage.items()},
        "individual_runs": results,
    }

    return metrics


@weave.op
def test_all_ethernaut_n_runs(
    provider, model, port, results_folder, n_runs=1, start_level=0, end_level=1
):
    contract_root = os.getenv("CONTRACT_ROOT", "")
    ethernaut_info_path = Path(contract_root) / "gamedata.json"

    with open(ethernaut_info_path) as f:
        info = json.load(f)["levels"]

    if start_level < 0:
        start_level = 0

    info = info[start_level : end_level + 1]
    all_results = []

    for i, level_info in enumerate(info):
        task_id = start_level + i
        level_metrics = run_level_n_times(
            task_id, level_info, provider, model, port, n_runs
        )
        all_results.append(level_metrics)

        # Save intermediate results
        # Ensure the metrics directory exists
        metrics_dir = results_folder / "metrics"
        metrics_dir.mkdir(parents=True, exist_ok=True)

        with open(metrics_dir / f"checkpoint_{task_id}.json", "w") as f:
            json.dump(all_results, f, indent=2)

    # Calculate overall statistics
    overall_stats = {
        "provider": provider,
        "model": model,
        "n_runs_per_level": n_runs,
        "total_levels": len(all_results),
        "avg_success_rate": (
            sum(r["success_rate"] for r in all_results) / len(all_results)
            if len(all_results) > 0
            else 0
        ),
        "levels_with_100_success": sum(
            1 for r in all_results if r["success_rate"] == 1.0
        ),
        "levels_with_0_success": sum(
            1 for r in all_results if r["success_rate"] == 0.0
        ),
        "avg_tool_calls_across_levels": (
            sum(r["avg_tool_calls"] for r in all_results) / len(all_results)
            if len(all_results) > 0
            else 0
        ),
        "timestamp": time.time(),
        "detailed_results": all_results,
    }

    return overall_stats


@weave.op
def analyze_best_of_n(benchmark_results, n_values=[1, 3, 5]):
    """Analyze what success rates would be with best-of-N sampling"""
    analysis = {}

    for n in n_values:
        level_success_rates = []

        for level_result in benchmark_results["detailed_results"]:
            # Calculate probability of at least one success in N attempts
            failure_rate = 1 - level_result["success_rate"]
            best_of_n_success_rate = 1 - (failure_rate**n)
            level_success_rates.append(best_of_n_success_rate)

        analysis[f"best_of_{n}"] = {
            "avg_success_rate": sum(level_success_rates) / len(level_success_rates),
            "levels_with_100_success": sum(1 for r in level_success_rates if r >= 0.99),
            "expected_tool_calls": n
            * benchmark_results["avg_tool_calls_across_levels"],
        }

    return analysis


def get_port(low: int = 15000, high: int = 65000, tries: int = 100) -> int:
    for _ in range(tries):
        port = random.randint(low, high)
        with contextlib.closing(socket.socket(socket.AF_INET, socket.SOCK_STREAM)) as s:
            try:
                s.bind(("127.0.0.1", port))
                # binding succeeded → port free
                return port
            except OSError as e:
                if e.errno != errno.EADDRINUSE:
                    # unexpected error, re-raise
                    raise
                # otherwise, loop and try another port
    raise RuntimeError(f"No free port found after {tries} attempts")


if __name__ == "__main__":
    """
    1. iterate through all ethernaut tasks. for every task:
    2. spin up handler instance at localhost:8000 using `python handler.py --task_id [NUMBER]`
        anvil's port is random, but the server is always at 800
    3. spin up agent to solve task
    4. kill current handler instance
    """
    parser = argparse.ArgumentParser(description="LLM agent")
    parser.add_argument("--provider", type=str, default="openai", help="LLM provider")
    parser.add_argument("--model", type=str, default="gpt-4o", help="LLM model")
    parser.add_argument(
        "--n_runs", type=int, default=1, help="Number of runs per level"
    )
    parser.add_argument(
        "--start_level", type=int, default=0, help="Start at what level (from 0)"
    )
    parser.add_argument(
        "--end_level",
        type=int,
        default=1,
        help="Run up to what level (up to 33, inclusive)",
    )

    args = parser.parse_args()

    # Set the task ID for the agent
    provider = args.provider
    model = args.model
    n_runs = args.n_runs
    start_level = args.start_level
    end_level = args.end_level

    if provider == "openrouter":
        if model == "opus":
            model = "anthropic/claude-opus-4"
        elif model == "qwen":
            model = "qwen/qwen3-32b:nitro"
        elif model == "gemini":
            model = "google/gemini-2.5-flash"

    port = get_port()
    file_timestamp = int(time.time())

    results_folder = Path(
        f"{args.model.replace("/","-")}_{args.provider}_level{start_level}-{end_level}_{args.n_runs}runs_{file_timestamp}"
    )
    results_folder.mkdir(exist_ok=True)

    results = test_all_ethernaut_n_runs(
        provider, model, port, results_folder, n_runs, start_level, end_level
    )

    # Save comprehensive results

    with open(results_folder / "benchmark.json", "w") as f:
        json.dump(results, f, indent=2)

    # Print summary
    print(f"\n{'='*60}")
    print("BENCHMARK COMPLETE")
    print(f"{'='*60}")
    print(f"Levels: {start_level} to {end_level}")
    print(f"Provider: {args.provider}")
    print(f"Model: {args.model}")
    print(f"Runs per level: {args.n_runs}")
    print(f"Average success rate: {results['avg_success_rate']:.2%}")
    print(f"Levels with 100% success: {results['levels_with_100_success']}")
    print(f"Levels with 0% success: {results['levels_with_0_success']}")
    print(f"Average tool calls: {results['avg_tool_calls_across_levels']:.1f}")
    print(f"\nDetailed results saved to: {results_folder}")

    analysis = analyze_best_of_n_for_rl(results)
    # Save comprehensive results
    with open(results_folder / "analysis.json", "w") as f:
        json.dump(analysis, f, indent=2)

    generate_analysis_graphs(analysis, results, output_dir=results_folder / "charts")
