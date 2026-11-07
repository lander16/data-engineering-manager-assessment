# Data Quality Policy

This policy says which data problems stop the build, which ones only warn, who acts, and how a threshold changes. The build enforces it through the tests in `docs/03-project-design.md` section 3.8.

## Principles

- **Separate our defects from source defects.** A broken grain is our bug, and it stops the build. A bad source row is a fact about the source, so it stays visible and nothing corrects it silently.
- **Measure exposure.** Each known issue carries rows and USD, so a person can rank it.
- **Never hide a row.** Exclusions happen through flags on `fct_remittances`, so every payment stays traceable.
- **A warning must mean something changed.** Issues at baseline stay quiet in the log and visible in `mart_known_issues`.

## Severity

| Class | Meaning | Examples | Result |
|---|---|---|---|
| Structural | A grain, key, or definition is broken | Duplicate keys, a lost disbursement, a mart that doesn't reconcile, an unknown status | The build fails |
| Ambiguous source | The data can't support one answer | Two different rows tied on ID, file, and timestamp | The build fails, and staging is skipped |
| Known source issue | Accepted, with a baseline | Orphan receipts, status conflicts, no-receipt payments | Quiet at baseline, and warns when it grows |
| Pinned number | A headline moved | Delivered volume, top users, recurring users | Warns |

An unknown status fails on purpose. A new provider value must get a mapping before it reaches a metric.

## Checks by layer

| Layer | What it checks | How |
|---|---|---|
| `raw` | No conflicting versions of a record | `no_conflicting_versions` on each source |
| Staging | Unique keys, required values, relationships, casts | Generic tests, and a cast that fails in its own model |
| Intermediate | Every status is known, and each pair is unique | `accepted_values`, `unique` |
| Facts and marts | Totals reconcile, and the 50% rule holds | `marts_reconcile_to_facts`, `top_users_cross_half` |
| Known issues | No issue grows past its baseline | `known_issues_within_baseline` |
| Headlines | Pinned numbers hold | `extract_golden_numbers` |
| Logic | Rules hold on synthetic edge cases | 19 unit tests |
| Semantic layer | Metrics match the marts | `analysis/check_semantic.py`, run by hand because MetricFlow is optional |

## Known issues by owner

These owners are proposals. The right names depend on the team.

| Group | Issues | Suggested owner | First action |
|---|---|---|---|
| Money at risk | `charged_undelivered_unrefunded`, `delivered_on_failed_payment`, `delivered_on_refunded_payment`, `multiple_delivered`, `cancelled_then_delivered`, `cancelled_with_paid_raw_status` | Finance and payment operations | Compare with provider statements |
| Open payouts | `in_flight_over_30_days`, `ach_settlement_pending` | Payment operations | Close or explain each one |
| Source integrity | `missing_disbursement`, `status_conflict`, `currency_conflict`, `chronology_reversal`, `disbursement_before_receipt`, `duplicate_ids_removed` | Backend engineering | Find the write path |
| Amount accuracy | `payment_primary_attempt_gap`, `non_positive_payment_amount`, `negative_amount_charged` | Backend engineering and finance | Confirm the fee rule |
| Unknown product | `no_receipt_scheduled_amount`, `no_receipt_one_dollar`, `no_receipt_other` | Product and finance | Name the product, then decide its reporting |
| Risk | `chargeback_on_ineligible_payment` | Risk | Review any row that appears |

## Responding to a warning

1. Read `mart_known_issues` to see what grew, and by how much.
2. Decide whether it's a new batch of the same issue or a new cause.
3. If it's expected, update the baseline in the same PR, and state why.
4. If it isn't, open an issue with its owner, and leave the baseline alone.

Baselines and pinned numbers change only with a stated reason. New data is expected to warn until someone reviews it.

## What a production version would add

- Freshness checks on each source, with an agreed delivery time.
- Alerts routed to each group's owner, and a target time to respond.
- A contract with the backend for statuses, so a new value is announced first.
- A hard ceiling on each issue, so sustained growth fails the build.
- Issue counts stored per run, to show trends.
