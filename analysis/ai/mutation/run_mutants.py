"""Apply each mutant to a copy of the project and report the tests that catch it.

usage: python analysis/ai/mutation/run_mutants.py [--all] [--jobs N] [IDS ...]

Each mutant gets a fresh copy of the project in a temporary folder, with a copy of a
database that already holds the raw tables. It runs `dbt run-operation load_raw` and
`dbt build --full-refresh`, then `dbt run --full-refresh` and `dbt test`, so a test that a
failing upstream test would skip in the build still runs. A mutant is caught when any test
fails or warns. A clean copy runs first and must pass every test.
"""
import argparse
import json
import sys
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from common import clone, copy_project, dbt, problems  # noqa: E402

WORK = HERE / "work"
MUTANTS = {m["id"]: m for m in json.loads((HERE / "mutants.json").read_text())}


def loaded_database():
    """Load the raw CSVs once into work/loaded.duckdb, which every mutant copies."""
    db = WORK / "loaded.duckdb"
    if not db.exists():
        with tempfile.TemporaryDirectory() as tmp:
            project = copy_project(Path(tmp) / "project")
            code, _ = dbt(project, "run-operation", "load_raw", log=WORK / "load.log")
            if code:
                sys.exit(f"load_raw failed, see {WORK / 'load.log'}")
            clone(project / "felix.duckdb", db)
    return db


def run(mutant_id):
    mutant = MUTANTS.get(mutant_id, {"id": mutant_id, "file": None, "edits": []})
    start, log = time.time(), WORK / "logs" / f"{mutant_id}.log"
    log.unlink(missing_ok=True)
    with tempfile.TemporaryDirectory() as tmp:
        project = copy_project(Path(tmp) / "project")
        for edit in mutant["edits"]:
            path = project / mutant["file"]
            text = path.read_text()
            if text.count(edit["old"]) != edit["count"]:
                return {"id": mutant_id, "status": "does not apply", "tests": {}}
            path.write_text(text.replace(edit["old"], edit["new"]))
        clone(loaded_database(), project / "felix.duckdb")
        load, _ = dbt(project, "run-operation", "load_raw", log=log)
        build_code, build = dbt(project, "build", "--full-refresh", log=log)
        run_code, run_results = dbt(project, "run", "--full-refresh", log=log)
        test_code, test = dbt(project, "test", log=log)
    found = {"build": problems(build), "run": problems(run_results), "test": problems(test)}
    tests = {}
    for step, nodes in found.items():
        for node, status in nodes.items():
            tests.setdefault(node, set()).add(f"{status} in {step}")
    if load or build is None or test is None:
        status = "dbt error"
    else:
        status = "caught" if tests else "survived"
    return {"id": mutant_id, "status": status, "secs": round(time.time() - start),
            "tests": {node: sorted(steps) for node, steps in sorted(tests.items())},
            "exit_codes": {"load": load, "build": build_code, "run": run_code, "test": test_code}}


def show(result):
    print(f"{result['id']:9} {result['status']}", flush=True)
    for node, steps in result["tests"].items():
        print(f"          {node} ({', '.join(steps)})", flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("ids", nargs="*", help="mutant ids; default: the 35 that survived before the test fixes")
    parser.add_argument("--all", action="store_true", help="run all mutants in mutants.json")
    parser.add_argument("--jobs", type=int, default=1, help="mutants to run at once (each takes about 1 GB of disk)")
    args = parser.parse_args()
    ids = args.ids or [m for m, v in MUTANTS.items() if args.all or v["survived_before_fix"]]
    unknown = [m for m in ids if m not in MUTANTS]
    if unknown:
        sys.exit(f"unknown mutant ids: {' '.join(unknown)}")
    (WORK / "logs").mkdir(parents=True, exist_ok=True)
    loaded_database()

    baseline = run("baseline")
    show(dict(baseline, status="clean" if baseline["status"] == "survived" else "NOT clean"))
    if baseline["status"] != "survived":
        sys.exit(f"The unmodified project must pass every test first. See {WORK / 'logs' / 'baseline.log'}")

    results = []
    with ThreadPoolExecutor(args.jobs) as pool:
        for result in pool.map(run, ids):
            show(result)
            results.append(result)
    (WORK / "results.json").write_text(json.dumps(results, indent=1) + "\n")
    counts = {s: sum(r["status"] == s for r in results) for s in ("caught", "survived", "dbt error", "does not apply")}
    print(", ".join(f"{n} {s}" for s, n in counts.items() if n), f"of {len(results)}. Details in {WORK / 'results.json'}")
    return 0 if counts["caught"] == len(results) else 1


if __name__ == "__main__":
    sys.exit(main())
