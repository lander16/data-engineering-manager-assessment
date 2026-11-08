# AI Evaluation Harness

This folder reruns the experiments in sections 1 to 4 of [docs/06-ai-evaluation.md](../../docs/06-ai-evaluation.md). The code review in section 4 and the classical methods in section 5 have no script here. The harness never writes to `felix.duckdb`. Every script opens it read-only or works on a copy.

## Setup

Run `dbt run-operation load_raw` and `dbt build` first, so `felix.duckdb` holds the raw tables and the marts. Then:

```bash
source .venv/bin/activate
pip install -r requirements-semantic.txt
```

Mutation testing needs only `requirements.txt`. The interface arm needs MetricFlow from `requirements-semantic.txt`. The agent experiments need the `claude` CLI (Claude Code), signed in.

## Contents

| Folder | Section of doc 06 | What it tests | Needs `claude` | Cost of a full run |
|---|---|---|---|---|
| `mutation/` | 1 | Whether the dbt tests catch realistic logic bugs | No | Free, about 20 minutes for the 35 former survivors |
| `agent_eval/` | 2 | Whether an agent answers business questions correctly, by what it can see | Yes | About $2.50 for both rounds |
| `incident/` | 3 | Whether an agent finds a seeded data incident from a symptom alone | Yes | About $5 for both rounds |
| `status_triage/` | 4 | Whether a model classifies new payout status values safely | Yes | Under $0.20 |

Each folder writes to its own `work/`, which git ignores. Golden values for the business questions are computed from the marts at scoring time and never written to disk. The incident answer key is drawn into `work/`. The status key is `status_triage/key.json`, because it only restates the status mapping in the models.

## Mutation testing

`mutation/mutants.json` holds 83 mutants: 63 from the first batch and 20 held out. Each has an id, the file, the edits, the defect, and whether it survived the build before the test fixes. Each mutant runs in a fresh project copy with `dbt run-operation load_raw` and `dbt build --full-refresh`, then `dbt run --full-refresh` and `dbt test`, so a test that an upstream failure skips in the build still runs. A mutant is caught when any test fails or warns. An unmodified copy runs first and must pass every test.

```bash
python analysis/ai/mutation/run_mutants.py              # the 35 former survivors
python analysis/ai/mutation/run_mutants.py --all        # all 83
python analysis/ai/mutation/run_mutants.py A05 B02      # chosen mutants
```

`--jobs 3` runs three at a time. Each mutant takes about 30 seconds and 1 GB of disk while it runs. K02 and K03 change the semantic YAML, which the dbt tests don't cover, so they survive here. `analysis/check_semantic.py` catches them.

## Blind agents

Each agent run gets a new folder in the system temp directory, holding only its data and wrappers. `./q` runs read-only SQL on that folder's database, and on the interface arm `./mf` runs MetricFlow. The `claude` CLI runs with no settings files, no MCP servers, no web access, and no Task or Agent tools. Bash is limited to `./q` and `./mf`, and Read to the run folder. The folder is deleted after the run, and the transcript goes to `work/`.

Arms:

- `raw`: the raw source tables, all text, with no documentation.
- `defs`: the raw tables plus written definitions (business questions only).
- `iface`: the public marts, the semantic layer through MetricFlow, and the catalog YAML.

The first run exports each arm from `felix.duckdb` into `work/`, which takes about 1 GB.

### Business questions

Round 1 has 14 questions and round 2 has 11 harder ones, each with its own definitions file.

```bash
python analysis/ai/agent_eval/run.py --round 1              # raw, defs, and iface; haiku and sonnet; 2 repeats
python analysis/ai/agent_eval/run.py --round 2              # defs and iface
python analysis/ai/agent_eval/score.py
```

`score.py` computes each golden value from the marts at scoring time. An answer is exact within 0.006 points on a percentage, or within 0.01% otherwise.

### Incident investigation

```bash
python analysis/ai/incident/draw.py --round 1               # seed 20261107
python analysis/ai/incident/build.py --round 1
python analysis/ai/incident/run.py --round 1 --reps 2
python analysis/ai/incident/score.py --round 1
```

Round 2, the independent rerun on a new draw, uses `--round 2` (seed 20261108) and `--reps 1`. The exploratory round of subtler incidents has no script here. `draw.py` picks the targets from the seed, and `build.py` seeds the damage into a project copy and rebuilds it with `dbt run`, so no failing test can stop the damage reaching the marts. It records the tests that would have caught it in `work/round<N>/build_tests.json`. Each scenario takes about 600 MB. The symptoms in `symptoms.json` were written by hand for each round's draw before any run.

### Status triage

```bash
python analysis/ai/status_triage/run.py
python analysis/ai/status_triage/score.py
```

The model gets `prompt.txt` with no tools and no data. `key.json` holds the class of each value and the 6 values that need a human.

## Models

The runs used `claude-haiku-5-5` and `claude-sonnet-5-5`. `--models haiku sonnet` maps to those versions, and any other value goes to `claude --model` unchanged. Results depend on the model version, and agent runs vary from one repeat to the next.
