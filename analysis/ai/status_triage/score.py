"""Score the status triage answers in work/ against key.json.

usage: python analysis/ai/status_triage/score.py

key.json holds the class of 30 values: the 20 the project maps, then 10 unseen ones. A miss is
flagged when the model set needs_human, and silent otherwise. The 6 ambiguous values have no
safe class, so the right answer is to flag them.
"""
import json
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from common import last_json  # noqa: E402

KEY = json.loads((HERE / "key.json").read_text())


def main():
    print("| Run | Correct | Flagged misses | Silent misses | Ambiguous flagged | Cost |\n|---|---:|---:|---:|---:|---:|")
    for path in sorted((HERE / "work").glob("*.json")):
        result = json.loads(path.read_text() or "{}")
        answer = last_json(result.get("result", ""), KEY["keys"][0]) or {}
        got = {v: answer.get(v) if isinstance(answer.get(v), dict) else {} for v in KEY["keys"]}
        misses = [v for v, c in KEY["truth"].items() if got[v].get("class") != c]
        flagged = [v for v in misses if got[v].get("needs_human") is True]
        silent = [v for v in misses if v not in flagged]
        amb = sum(got[v].get("needs_human") is True for v in KEY["amb"])
        print(f"| {path.stem} | {len(KEY['truth']) - len(misses)}/{len(KEY['truth'])} | {len(flagged)} "
              f"| {len(silent)} {' '.join(silent)} | {amb}/{len(KEY['amb'])} | ${result.get('total_cost_usd', 0):.3f} |")


if __name__ == "__main__":
    main()
