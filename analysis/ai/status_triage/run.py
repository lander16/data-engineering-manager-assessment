"""Ask a model to classify payout status values, with no tools and no data.

usage: python analysis/ai/status_triage/run.py [--models haiku sonnet] [--reps 2]

Answers go to work/<model>_<rep>.json. Score them with score.py.
"""
import argparse
import subprocess
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from common import MODELS  # noqa: E402


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--models", nargs="+", default=["haiku", "sonnet"])
    parser.add_argument("--reps", type=int, default=2)
    args = parser.parse_args()
    (HERE / "work").mkdir(exist_ok=True)
    for model in args.models:
        for rep in range(1, args.reps + 1):
            out = HERE / "work" / f"{model}_{rep}.json"
            command = ["claude", "-p", "--model", MODELS.get(model, model), "--output-format", "json",
                       "--no-session-persistence", "--strict-mcp-config", "--setting-sources", "", "--tools", ""]
            with tempfile.TemporaryDirectory() as cwd, open(out, "w") as handle:
                code = subprocess.run(command, cwd=cwd, input=(HERE / "prompt.txt").read_text(), text=True,
                                      stdout=handle, timeout=600).returncode
            print(f"{out.name} exit {code}", flush=True)


if __name__ == "__main__":
    main()
