"""Give blind agents a stakeholder's symptom and ask them to find the incident. Run build.py first.

usage: python analysis/ai/incident/run.py --round 1 [--scenarios a b] [--arms raw iface]
                                          [--models haiku sonnet] [--reps 2] [--jobs 3]

The main round used 2 repeats and the rerun 1. Transcripts go to work/round<N>/transcripts/,
named by the scenario's opaque id. Finished runs are skipped, so a batch can be restarted.
"""
import argparse
import json
import random
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from common import interface_files, result_event, run_agent, run_folder, tool  # noqa: E402

WORK = HERE / "work"


def run(job):
    round_dir, k, arm, model, rep = job
    tag = f"{k['id']}_{arm}_{model}_{rep}"
    transcript = round_dir / "transcripts" / f"{tag}.jsonl"
    if result_event(transcript):
        return f"{tag} done before"
    data = WORK / "baseline" if k["kind"] == "control" else round_dir / "scen" / k["id"]
    if not (data / arm).exists():
        return f"{tag} skipped: scenario {k['scenario']} is not built"
    folder, tools = run_folder(data / arm, iface_files=WORK / "static" if arm == "iface" else None)
    prompt = (HERE / "prompts" / "common.txt").read_text().replace("{SYMPTOM}", k["symptom"])
    prompt += (HERE / "prompts" / f"arm_{arm}.txt").read_text() + "\n"
    return f"{tag} exit {run_agent(folder, prompt, model, transcript, tools)}"


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--round", type=int, required=True)
    parser.add_argument("--scenarios", nargs="+", help="scenario letters, default all")
    parser.add_argument("--arms", nargs="+", choices=["raw", "iface"], default=["raw", "iface"])
    parser.add_argument("--models", nargs="+", default=["haiku", "sonnet"])
    parser.add_argument("--reps", type=int, default=2)
    parser.add_argument("--jobs", type=int, default=3)
    args = parser.parse_args()
    round_dir = WORK / f"round{args.round}"
    key = json.loads((round_dir / "key.json").read_text())
    if "iface" in args.arms:
        tool("mf")
        interface_files(WORK / "static")
    chosen = sorted(i for i, k in key.items() if not args.scenarios or k["scenario"] in args.scenarios)
    jobs = [(round_dir, key[i], a, m, r) for i in chosen for a in args.arms for m in args.models
            for r in range(1, args.reps + 1)]
    random.Random(7).shuffle(jobs)
    with ThreadPoolExecutor(args.jobs) as pool:
        for line in pool.map(run, jobs):
            print(line, flush=True)


if __name__ == "__main__":
    main()
