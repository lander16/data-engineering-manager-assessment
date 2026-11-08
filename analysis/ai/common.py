"""Shared helpers for the AI evaluation harness.

Nothing here writes to the project's felix.duckdb. Every database is opened
read-only or is a copy in a work folder.
"""
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

import duckdb

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
PROJECT_DB = ROOT / "felix.duckdb"
MODELS = {"haiku": "claude-haiku-5-5", "sonnet": "claude-sonnet-5-5"}
PUBLIC_TABLES = [
    "dim_users", "fct_remittances", "int_payout_attempts", "mart_chargeback_rate", "mart_known_issues",
    "mart_monthly_volume", "mart_provider_failures", "mart_recurring_cohorts", "mart_shared_beneficiaries",
    "mart_user_segments", "metricflow_time_spine",
]
RAW_TABLES = ["payments", "receipts", "disbursements"]
CATALOG = ["models/marts/_marts.yml", "models/marts/_semantic.yml", "models/intermediate/_intermediate.yml"]


def tool(name):
    """Find a CLI next to the running Python first, then on PATH."""
    local = Path(sys.executable).parent / name
    found = str(local) if local.exists() else shutil.which(name)
    if not found:
        sys.exit(f"{name} not found. Activate the project venv (MetricFlow needs requirements-semantic.txt).")
    return found


def clone(src, dst):
    """Copy a file, using a copy-on-write clone where the file system has one."""
    if subprocess.run(["cp", "-c", str(src), str(dst)], capture_output=True).returncode:
        shutil.copyfile(src, dst)


def copy_project(dst):
    """Copy the dbt project into dst, with data/ linked to the real CSVs."""
    dst = Path(dst)
    for name in ["models", "macros", "tests"]:
        shutil.copytree(ROOT / name, dst / name)
    for name in ["dbt_project.yml", "profiles.yml"]:
        shutil.copy2(ROOT / name, dst / name)
    (dst / "data").symlink_to(ROOT / "data")
    return dst


def dbt(project, *args, log=None):
    """Run dbt in a project copy. Returns the exit code and run_results.json, if any."""
    env = dict(os.environ, DBT_PROFILES_DIR=str(project))
    results = Path(project) / "target" / "run_results.json"
    results.unlink(missing_ok=True)
    proc = subprocess.run([tool("dbt"), *args, "--no-use-colors"], cwd=project, env=env,
                          capture_output=True, text=True, stdin=subprocess.DEVNULL)
    if log:
        with open(log, "a") as handle:
            handle.write(f"$ dbt {' '.join(args)}\n{proc.stdout}{proc.stderr}\n")
    return proc.returncode, json.loads(results.read_text()) if results.exists() else None


def problems(run_results):
    """Map each node that errored, failed, or warned to its status."""
    out = {}
    for result in (run_results or {}).get("results", []):
        if result["status"] in ("error", "fail", "warn"):
            uid = result["unique_id"]
            name = uid.split(".")[-1] if uid.startswith("unit_test") else uid.split(".")[2]
            out[f"{uid.split('.')[0]}:{name}"] = result["status"]
    return out


def export_raw(src, dst):
    """Write the raw source tables of src into a new database at dst."""
    with duckdb.connect(str(dst), config={"TimeZone": "UTC"}) as con:
        con.execute(f"attach '{src}' as s (read_only)")
        con.execute("create schema raw")
        for table in RAW_TABLES:
            con.execute(f"create table raw.{table} as select * from s.raw.{table}")


def export_public(src, dst):
    """Write the public marts of src into a new database at dst. MetricFlow needs the name felix.duckdb."""
    with duckdb.connect(str(dst), config={"TimeZone": "UTC"}) as con:
        con.execute(f"attach '{src}' as s (read_only)")
        for table in PUBLIC_TABLES:
            con.execute(f"create table main.{table} as select * from s.main.{table}")


def export_arms(src, out):
    """Build both blind arms from a built database: out/raw/data.duckdb and out/iface/felix.duckdb."""
    out = Path(out)
    for arm in ["raw", "iface"]:
        (out / arm).mkdir(parents=True, exist_ok=True)
    export_raw(src, out / "raw" / "data.duckdb")
    export_public(src, out / "iface" / "felix.duckdb")


def interface_files(out):
    """Write what the interface arm reads besides the data: the catalog YAML, dbt_project.yml, and the manifests."""
    out = Path(out).resolve()
    if (out / "target" / "semantic_manifest.json").exists():
        return out
    with tempfile.TemporaryDirectory() as tmp:
        project = copy_project(Path(tmp) / "project")
        code, _ = dbt(project, "parse", "--target-path", str(out / "target"))
        if code:
            sys.exit("dbt parse failed")
    for path in (out / "target").iterdir():
        if path.name not in ("manifest.json", "semantic_manifest.json"):
            shutil.rmtree(path) if path.is_dir() else path.unlink()
    (out / "catalog").mkdir(exist_ok=True)
    for path in CATALOG:
        shutil.copy2(ROOT / path, out / "catalog" / Path(path).name)
    shutil.copy2(ROOT / "dbt_project.yml", out / "dbt_project.yml")
    return out


def run_folder(arm_dir, iface_files=None, extra=None):
    """Make a fresh run folder in the system temp directory with the arm's data and the ./q and ./mf wrappers.

    Returns the folder and the tools the agent may use. The interface arm gets the public marts,
    the catalog, and MetricFlow. Any other arm gets the raw tables only. extra maps
    a file name in the run folder to a source file.
    """
    run = Path(tempfile.mkdtemp(prefix="run-"))
    shutil.copy2(HERE / "q.py", run / "q.py")
    q = run / "q"
    q.write_text(f'#!/bin/bash\nexec "{sys.executable}" "{run}/q.py" "$@"\n')
    q.chmod(0o755)
    for name, path in (extra or {}).items():
        shutil.copy2(path, run / name)
    if iface_files:
        clone(Path(arm_dir) / "felix.duckdb", run / "felix.duckdb")
        for name in ["catalog", "target"]:
            shutil.copytree(Path(iface_files) / name, run / name)
        shutil.copy2(Path(iface_files) / "dbt_project.yml", run / "dbt_project.yml")
        (run / "profiles.yml").write_text(
            "remittances:\n  target: dev\n  outputs:\n    dev:\n      type: duckdb\n"
            f"      path: {run}/felix.duckdb\n      threads: 4\n      settings:\n        TimeZone: UTC\n")
        mf = run / "mf"
        mf.write_text(f'#!/bin/bash\ncd "{run}" && DBT_PROFILES_DIR="{run}" exec "{tool("mf")}" "$@"\n')
        mf.chmod(0o755)
        return run, ["Bash(./q:*)", "Bash(./mf:*)", "Read(./**)"]
    clone(Path(arm_dir) / "data.duckdb", run / "data.duckdb")
    return run, ["Bash(./q:*)", "Read(./**)"]


def run_agent(run, prompt, model, transcript, tools):
    """Run one blind agent in its run folder, then delete the folder.

    The agent sees no project settings, no MCP servers, no web access, and no Task or Agent tools. Bash is
    limited to ./q and ./mf, and Read to the run folder.
    """
    command = [
        "claude", "-p", "--model", MODELS.get(model, model), "--output-format", "stream-json", "--verbose",
        "--no-session-persistence", "--strict-mcp-config", "--setting-sources", "", "--max-budget-usd", "5",
        "--tools", "Bash", "Read", "--allowedTools", *tools,
        "--disallowedTools", "WebSearch", "WebFetch", "Task", "Agent",
    ]
    Path(transcript).parent.mkdir(parents=True, exist_ok=True)
    try:
        with open(transcript, "w") as out, open(str(transcript) + ".err", "w") as err:
            proc = subprocess.run(command, cwd=run, input=prompt, text=True, stdout=out, stderr=err, timeout=1500)
        return proc.returncode
    except subprocess.TimeoutExpired:
        return "timeout"
    finally:
        shutil.rmtree(run, ignore_errors=True)


def result_event(transcript):
    """The final result event of a stream-json transcript, or an empty dict."""
    result = {}
    if Path(transcript).exists():
        for line in open(transcript):
            try:
                event = json.loads(line)
            except ValueError:
                continue
            if event.get("type") == "result":
                result = event
    return result


def last_json(text, required_key):
    """The last JSON object in text that has required_key."""
    decoder, best = json.JSONDecoder(), None
    for start in (i for i, ch in enumerate(text or "") if ch == "{"):
        try:
            obj, _ = decoder.raw_decode(text[start:])
        except ValueError:
            continue
        if isinstance(obj, dict) and required_key in obj:
            best = obj
    return best
