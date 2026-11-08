"""Build each scenario's two blind arms for a round. Run draw.py first.

usage: python analysis/ai/incident/build.py --round 1 [SCENARIOS ...]

For each incident, a project copy in a temporary folder gets the raw tables from felix.duckdb,
read-only, then the seeded damage, then `dbt run --full-refresh`. Marts always carry the
damage, because no failing test can skip them. `dbt test` runs afterwards and its failures and
warnings go to work/round<N>/build_tests.json. Controls share one unseeded baseline. Each
scenario takes about 600 MB in work/.
"""
import argparse
import json
import sys
import tempfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from common import PROJECT_DB, copy_project, dbt, export_arms, export_raw, problems  # noqa: E402
from seed import seed  # noqa: E402

WORK = HERE / "work"


def build(round_dir, name, sc):
    out = round_dir / "scen" / sc["id"]
    if (out / "iface" / "felix.duckdb").exists():
        return f"{name} built before"
    with tempfile.TemporaryDirectory() as tmp:
        project = copy_project(Path(tmp) / "project")
        db = project / "felix.duckdb"
        export_raw(PROJECT_DB, db)
        counts = seed(db, name, sc)
        log = round_dir / "logs" / f"{name}.log"
        code, _ = dbt(project, "run", "--full-refresh", log=log)
        if code:
            sys.exit(f"{name}: dbt run failed, see {log}")
        _, tests = dbt(project, "test", log=log)
        export_arms(db, out)
    report = round_dir / "build_tests.json"
    found = json.loads(report.read_text()) if report.exists() else {}
    found[name] = dict(seeded=counts, tests=problems(tests))
    report.write_text(json.dumps(found, indent=1) + "\n")
    return f"{name} built: seeded {counts}, {len(found[name]['tests'])} tests failed or warned"


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--round", type=int, required=True)
    parser.add_argument("scenarios", nargs="*", help="scenario letters, default all")
    args = parser.parse_args()
    round_dir = WORK / f"round{args.round}"
    draw = json.loads((round_dir / "draw.json").read_text())["scen"]
    (round_dir / "logs").mkdir(parents=True, exist_ok=True)
    if not (WORK / "baseline" / "iface" / "felix.duckdb").exists():
        print("Exporting the unseeded baseline for the controls")
        export_arms(PROJECT_DB, WORK / "baseline")
    for name in args.scenarios or sorted(draw):
        if draw[name]["kind"] != "control":
            print(build(round_dir, name, draw[name]), flush=True)


if __name__ == "__main__":
    main()
