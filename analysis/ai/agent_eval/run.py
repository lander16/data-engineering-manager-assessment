"""Ask blind agents the stakeholder questions, one run per round, arm, model, and repeat.

usage: python analysis/ai/agent_eval/run.py --round 1 [--arms raw defs iface] [--models haiku sonnet] [--reps 2] [--jobs 4]

Arms:
  raw    the raw source tables as text, and no documentation
  defs   the raw tables plus the written definitions
  iface  the published marts, the semantic layer through MetricFlow, and the catalog YAML

The first run exports the arms from felix.duckdb, read-only, into work/. Transcripts go to
work/transcripts/. Score them with score.py.
"""
import argparse
import json
import random
import sys
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from common import PROJECT_DB, export_arms, interface_files, result_event, run_agent, run_folder, tool  # noqa: E402

WORK = HERE / "work"
DEFAULT_ARMS = {"round1": ["raw", "defs", "iface"], "round2": ["defs", "iface"]}


def prompt(question_set, arm):
    questions = json.loads((HERE / f"questions_{question_set}.json").read_text())
    common = (HERE / "prompt_common.txt").read_text().format(
        n=len(questions), questions="\n".join(f"{k}: {v}" for k, v in questions.items()))
    return common + (HERE / f"prompt_{arm}.txt").read_text()


def prepare(arms):
    if not (WORK / "arms" / "iface" / "felix.duckdb").exists():
        print("Exporting the arms from felix.duckdb")
        export_arms(PROJECT_DB, WORK / "arms")
    if "iface" in arms:
        tool("mf")
        interface_files(WORK / "static")


def run(cell):
    question_set, arm, model, rep = cell
    tag = f"{question_set}_{arm}_{model}_{rep}"
    transcript = WORK / "transcripts" / f"{tag}.jsonl"
    if result_event(transcript):
        return f"{tag} done before"
    if arm == "iface":
        folder, tools = run_folder(WORK / "arms" / "iface", iface_files=WORK / "static")
    else:
        extra = {"definitions.md": HERE / f"definitions_{question_set}.md"} if arm == "defs" else None
        folder, tools = run_folder(WORK / "arms" / "raw", extra=extra)
    code = run_agent(folder, prompt(question_set, arm), model, transcript, tools)
    return f"{tag} exit {code}"


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--round", type=int, choices=[1, 2], required=True)
    parser.add_argument("--arms", nargs="+", choices=["raw", "defs", "iface"])
    parser.add_argument("--models", nargs="+", default=["haiku", "sonnet"])
    parser.add_argument("--reps", type=int, default=2)
    parser.add_argument("--jobs", type=int, default=4)
    args = parser.parse_args()
    question_set = f"round{args.round}"
    arms = args.arms or DEFAULT_ARMS[question_set]
    prepare(arms)
    cells = [(question_set, a, m, r) for r in range(1, args.reps + 1) for m in args.models for a in arms]
    random.Random(7).shuffle(cells)
    with ThreadPoolExecutor(args.jobs) as pool:
        for line in pool.map(run, cells):
            print(line, flush=True)


if __name__ == "__main__":
    main()
