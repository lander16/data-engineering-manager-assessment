# Data Profiling

This folder is the evidence behind the project's modeling decisions. It reads the source CSVs without changing them.

## Run

Requires DuckDB. The CSVs must be in `data/`.

```bash
bash analysis/run_profile.sh
```

The script:

1. Verifies the SHA-256 checksums of the source files.
2. Loads every column as text into a temporary DuckDB database, which is deleted afterward.
3. Writes results to `analysis/results/`.
4. Verifies the checksums again.

## Contents

| Path | Purpose |
|---|---|
| [findings.md](findings.md) | Observations, hypotheses, and implications, kept separate |
| `sql/00_setup.sql` | Text-only load and helper tables |
| `sql/01_completeness.sql` | Row counts, nulls, cardinality, and text hygiene |
| `sql/02_keys_and_relationships.sql` | Keys, joins, cardinality, and retry chains |
| `sql/03_categoricals.sql` | Statuses, types, countries, and currencies |
| `sql/04_numeric_precision.sql` | Numeric text shape, precision, ranges, and identities |
| `sql/05_timestamps.sql` | Timestamp formats, coverage, chronology, and time zones |
| `sql/06_business_baselines.sql` | Reference values for the metric definitions |
| `sql/07_followups.sql` | Questions raised by the earlier scripts |
| `sql/08_review_checks.sql` | Payment outcomes, precision, fan-out, and retention checks |
| `sql/09_source_checks.sql` | Fan-out, sub-cent amounts, timestamps, currency conflicts, and ACH |
| `sql/10_research_setup.sql` | Helper tables for attempts and remittances |
| `sql/11_users_beneficiaries.sql` | Beneficiary identity, recurring rules, and top-user stability |
| `sql/12_money_definition.sql` | Promotions, headline amount, and no-receipt payments |
| `sql/13_providers_cancellations.sql` | Cancellations, status conflicts, and provider classes |
| `sql/14_chargebacks.sql` | Chargeback meaning, maturity, and denominators |
| `sql/15_review_checks.sql` | Figures under the adopted status rule, plus later checks |
| `sql/16_recurring_definitions.sql` | Calendar months against day windows for recurring customers |
| `sql/17_provider_mix.sql` | Provider failures by destination and payout type, and each provider against its peers |
| `check_semantic.py` | Compares the semantic-layer metrics to the marts. Needs `requirements-semantic.txt` and a finished `dbt build` |
| `ai/` | Harness for the AI experiments in `docs/06-ai-evaluation.md`: mutation testing, agent accuracy, incident investigation, and status triage |
| `results/` | Output of each script, plus source checksums |
| `verification/` | Independent re-derivation of 137 profiling figures in Python, with no DuckDB. All match. It uses the earlier provider rates and counts beneficiaries on all attempts, so it doesn't cover the adopted status rule or the beneficiary segments. Run with `python3 -I analysis/verification/independent_check.py` |

Query titles in scripts 11 to 14 use labels from when those questions were open, such as `Q5` and `Y6`. Assumptions now live in [docs/02-assumptions-and-rules.md](../docs/02-assumptions-and-rules.md).

A rerun can differ from the committed results in the order of tied rows and in floating-point noise far below a cent. Counts and conclusions don't change.

Every script sets the session time zone to UTC. Without this, month grouping follows the machine's time zone.
