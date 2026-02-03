import subprocess
import os
import matplotlib.pyplot as plt
from collections import Counter


def get_random_arr(iterations: int, min_val: int, max_val: int) -> list[int]:
    script_dir = os.path.dirname(os.path.abspath(__file__))
    build_script = os.path.join(script_dir, "..", "build.sh")
    binary_path = os.path.join(script_dir, "..", "bin", "goggles-random")

    subprocess.run([build_script, "build"], capture_output=True, cwd=os.path.dirname(build_script))

    results = []
    for _ in range(iterations):
        result = subprocess.run([binary_path, str(min_val), str(max_val)], capture_output=True, text=True)
        results.append(int(result.stdout.strip()))
    return results


def plot_deviation(data, filename="deviation.png"):
    counts = Counter(data)
    min_val, max_val = min(data), max(data)
    values = range(min_val, max_val + 1)

    expected = len(data) / len(values)
    frequencies = [counts[v] for v in values]
    deviations = [(f - expected) / expected * 100 for f in frequencies]

    plt.figure(figsize=(12, 6))

    colors = ['green' if abs(d) < 5 else 'orange' if abs(d) < 10 else 'red' for d in deviations]
    plt.bar(values, deviations, color=colors, edgecolor='black', alpha=0.7)
    plt.axhline(0, color='black', linestyle='-', linewidth=0.8)
    plt.axhline(5, color='orange', linestyle='--', alpha=0.5, label='±5% threshold')
    plt.axhline(-5, color='orange', linestyle='--', alpha=0.5)
    plt.xlabel('Value')
    plt.ylabel('Deviation (%)')
    plt.title(f'Deviation from Expected Uniform Distribution (n={len(data)})')
    plt.legend()
    plt.grid(axis='y', alpha=0.3)

    plt.tight_layout()
    plt.savefig(filename, dpi=300, bbox_inches='tight')
    plt.close()


results = get_random_arr(iterations=10000, min_val=0, max_val=10)
plot_deviation(results)