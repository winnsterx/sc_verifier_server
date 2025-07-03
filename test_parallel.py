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

from analysis import analyze_best_of_n_for_rl
from rl_analysis_updated import run_analysis as run_rl_analysis
from rl_advanced_analysis_updated import (
    run_advanced_analysis as run_rl_advanced_analysis,
)
from concurrent.futures import ProcessPoolExecutor, as_completed
import threading
from typing import Dict, List, Tuple

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
                print(f"✅ Server is ready on port {port}!")
                return True
        except requests.exceptions.ConnectionError:
            pass
        print(f"⏳ Waiting for server to start on port {port}...")
        time.sleep(1)
    return False


@weave.op
def test_single_level(task_id, level_info, provider, model, port, run_id=0):
    print(f"[Port {port}] Testing level {task_id}: {level_info.get('name')}")
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
            print(f"[Port {port}] Calling agent.run...")
            start_time = time.time()
            solved, messages, metrics = agent.run(provider, model, port)
            execution_time = time.time() - start_time
            print(
                f"[Port {port}] Agent.run returned: solved={solved}, messages_count={len(messages)}"
            )

            if solved == True:
                print(f"[Port {port}] Level {task_id} SOLVED!")
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
                print(f"[Port {port}] Level {task_id} FAILED...")
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
            print(f"[Port {port}] Outer exception: {type(e).__name__}: {e}")
            return {
                "task_id": task_id,
                "level_name": level_info.get("name"),
                "run_id": run_id,
                "solved": False,
                "error": str(e),
                "execution_time": time.time() - start_time,
            }
    finally:
        print(f"[Port {port}] Entering finally block...")
        if handler_process:
            # Check if process is still alive
            if handler_process.poll() is None:
                print(f"[Port {port}] Handler still running, terminating...")
                handler_process.terminate()
                try:
                    handler_process.wait(timeout=5)
                except subprocess.TimeoutExpired:
                    handler_process.kill()
                    handler_process.wait()
            else:
                print(
                    f"[Port {port}] Handler already exited with code: {handler_process.returncode}"
                )
            print(f"[Port {port}] Handler shut down")


def run_level_n_times_wrapper(args: Tuple) -> Dict:
    """Wrapper function for ProcessPoolExecutor"""
    task_id, level_info, provider, model, port, n_runs = args
    return run_level_n_times(task_id, level_info, provider, model, port, n_runs)


@weave.op
def run_level_n_times(task_id, level_info, provider, model, port, n_runs=1):
    results = []
    for run_id in range(n_runs):
        print(f"\n{'='*60}")
        print(f"[Port {port}] Starting run {run_id + 1}/{n_runs} for level {task_id}")
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
            for tool, count in r["tool_usage"].items():
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


class PortManager:
    """Thread-safe port allocation manager"""

    def __init__(self, base_port: int = 15000, port_range: int = 10000):
        self.base_port = base_port
        self.port_range = port_range
        self.used_ports = set()
        self.lock = threading.Lock()

    def get_port(self) -> int:
        """Get an available port thread-safely"""
        with self.lock:
            tries = 100
            for _ in range(tries):
                port = random.randint(self.base_port, self.base_port + self.port_range)
                if port in self.used_ports:
                    continue

                with contextlib.closing(
                    socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                ) as s:
                    try:
                        s.bind(("127.0.0.1", port))
                        self.used_ports.add(port)
                        return port
                    except OSError as e:
                        if e.errno != errno.EADDRINUSE:
                            raise
            raise RuntimeError(f"No free port found after {tries} attempts")

    def release_port(self, port: int):
        """Release a port back to the pool"""
        with self.lock:
            self.used_ports.discard(port)


@weave.op
def test_all_ethernaut_n_runs_parallel(
    provider, model, results_folder, n_runs=1, start_level=0, end_level=1, max_workers=4
):
    contract_root = os.getenv("CONTRACT_ROOT", "")
    ethernaut_info_path = Path(contract_root) / "gamedata.json"

    with open(ethernaut_info_path) as f:
        info = json.load(f)["levels"]

    if start_level < 0:
        start_level = 0

    info = info[start_level : end_level + 1]

    # Initialize port manager
    port_manager = PortManager()

    # Prepare tasks for parallel execution
    tasks = []
    for i, level_info in enumerate(info):
        task_id = start_level + i
        port = port_manager.get_port()
        tasks.append((task_id, level_info, provider, model, port, n_runs))

    all_results = []
    completed_tasks = 0
    total_tasks = len(tasks)

    print(
        f"\nStarting parallel execution with {max_workers} workers for {total_tasks} levels..."
    )

    # Execute tasks in parallel
    with ProcessPoolExecutor(max_workers=max_workers) as executor:
        # Submit all tasks
        future_to_task = {
            executor.submit(run_level_n_times_wrapper, task): task for task in tasks
        }

        # Process completed tasks
        for future in as_completed(future_to_task):
            task = future_to_task[future]
            task_id, _, _, _, port, _ = task

            try:
                level_metrics = future.result()
                all_results.append(level_metrics)
                completed_tasks += 1

                print(
                    f"\n✅ Completed level {task_id} ({completed_tasks}/{total_tasks})"
                )

                # Save intermediate results
                metrics_dir = results_folder / "metrics"
                metrics_dir.mkdir(parents=True, exist_ok=True)

                # Sort results by task_id before saving
                sorted_results = sorted(all_results, key=lambda x: x["task_id"])
                with open(metrics_dir / f"checkpoint_{completed_tasks}.json", "w") as f:
                    json.dump(sorted_results, f, indent=2)

            except Exception as exc:
                print(f"❌ Level {task_id} generated an exception: {exc}")
                all_results.append(
                    {"task_id": task_id, "error": str(exc), "success_rate": 0}
                )
            finally:
                # Release the port
                port_manager.release_port(port)

    # Sort results by task_id
    all_results = sorted(all_results, key=lambda x: x["task_id"])

    # Calculate overall statistics
    overall_stats = {
        "provider": provider,
        "model": model,
        "n_runs_per_level": n_runs,
        "total_levels": len(all_results),
        "max_workers": max_workers,
        "avg_success_rate": (
            sum(r.get("success_rate", 0) for r in all_results) / len(all_results)
            if len(all_results) > 0
            else 0
        ),
        "levels_with_100_success": sum(
            1 for r in all_results if r.get("success_rate", 0) == 1.0
        ),
        "levels_with_0_success": sum(
            1 for r in all_results if r.get("success_rate", 0) == 0.0
        ),
        "avg_tool_calls_across_levels": (
            sum(r.get("avg_tool_calls", 0) for r in all_results) / len(all_results)
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
            failure_rate = 1 - level_result.get("success_rate", 0)
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
    Parallel version of test.py that runs multiple levels concurrently
    """
    parser = argparse.ArgumentParser(description="LLM agent parallel testing")
    parser.add_argument(
        "--provider", type=str, default="openrouter", help="LLM provider"
    )
    parser.add_argument("--model", type=str, default="gemini", help="LLM model")
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
    parser.add_argument(
        "--max_workers",
        type=int,
        default=4,
        help="Maximum number of parallel workers",
    )

    args = parser.parse_args()

    # Set the task ID for the agent
    provider = args.provider
    model = args.model
    n_runs = args.n_runs
    start_level = args.start_level
    end_level = args.end_level
    max_workers = args.max_workers

    if provider == "openrouter":
        if model == "opus":
            model = "anthropic/claude-opus-4"
        elif model == "qwen":
            model = "qwen/qwen3-32b:nitro"
        elif model == "gemini":
            model = "google/gemini-2.5-flash"

    file_timestamp = int(time.time())

    results_folder = Path(
        f"{args.model.replace("/","-")}_{args.provider}_level{start_level}-{end_level}_{args.n_runs}runs_{max_workers}workers_{file_timestamp}"
    )
    results_folder.mkdir(exist_ok=True)

    start_time = time.time()
    results = test_all_ethernaut_n_runs_parallel(
        provider, model, results_folder, n_runs, start_level, end_level, max_workers
    )
    total_time = time.time() - start_time

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
    print(f"Parallel workers: {args.max_workers}")
    print(f"Total execution time: {total_time:.2f} seconds")
    print(f"Average success rate: {results['avg_success_rate']:.2%}")
    print(f"Levels with 100% success: {results['levels_with_100_success']}")
    print(f"Levels with 0% success: {results['levels_with_0_success']}")
    print(f"Average tool calls: {results['avg_tool_calls_across_levels']:.1f}")
    print(f"\nDetailed results saved to: {results_folder}")

    analysis = analyze_best_of_n_for_rl(results)
    # Save comprehensive results
    with open(results_folder / "analysis.json", "w") as f:
        json.dump(analysis, f, indent=2)

    # Run RL analyses
    print("\nRunning RL analysis...")
    run_rl_analysis(str(results_folder / "benchmark.json"))

    print("\nRunning advanced RL analysis...")
    run_rl_advanced_analysis(str(results_folder / "benchmark.json"))
