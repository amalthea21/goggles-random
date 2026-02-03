import subprocess
import os
import numpy as np
import matplotlib.pyplot as plt


def run_random(min_val: int, max_val: int) -> int:
    script_dir = os.path.dirname(os.path.abspath(__file__))
    build_script = os.path.join(script_dir, "..", "build.sh")

    result = subprocess.run(
        [build_script, "run", str(min_val), str(max_val)],
        capture_output=True,
        text=True,
        cwd=os.path.dirname(build_script)
    )
    return int(result.stdout.strip())


def get_random_arr(iterations: int, min_val: int, max_val: int) -> list[int]:
    results = []

    for _ in range(iterations):
        result = run_random(min_val, max_val)
        results.append(result)

    return results


def plot_distribution(data, filename="distribution.png"):
    plt.figure(figsize=(10, 6))

    min_val = min(data)
    max_val = max(data)
    bins = np.arange(min_val - 0.5, max_val + 1.5, 1)

    plt.hist(data, bins=bins, edgecolor='black', alpha=0.7, rwidth=0.8)
    plt.xticks(range(min_val, max_val + 1))
    plt.xlabel('Value')
    plt.ylabel('Frequency')
    plt.title(f'Distribution of Random Values (n={len(data)})')
    plt.grid(axis='y', alpha=0.75)

    plt.savefig(filename, dpi=100, bbox_inches='tight')
    plt.close()

results = get_random_arr(iterations=50, min_val=0, max_val=10)
plot_distribution(results)