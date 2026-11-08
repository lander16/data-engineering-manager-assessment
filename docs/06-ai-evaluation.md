# AI Evaluation

This document tests where AI helps a data team on this project, and where it doesn't. Each experiment had a written pass bar before it ran. AI agents worked blind, in isolated folders, with only the tools named for them, and scripts scored their answers. Failed experiments are reported too.

The models were `claude-haiku-5-5` and `claude-sonnet-5-5`, run through Claude Code. `analysis/ai/` holds the harness, and its README has the commands and costs.

| # | Question | Verdict | Result |
|---|---|---|---|
| 1 | Do the tests catch realistic logic bugs? | Gaps found and closed | The build caught 41 of 78 seeded bugs. New tests now catch all 35 targeted survivors |
| 2 | Does an AI agent answer business questions correctly? | Depends on definitions | 36% to 43% from raw tables, 100% with written definitions or the published interface |
| 3 | Can an AI agent find the cause of a data incident? | Passed | 17 or 18 of 18 seeded incidents found, and 24 of 24 quiet periods correctly called quiet |
| 4 | Can AI triage a new payout status? | Passed, small set | Sonnet matched 29 of 30 values and flagged its one miss for a human |
| 5 | Can AI review model changes for logic bugs? | Inconclusive | Caught 7 of 7 hidden bugs with the right reason, but 7 is too few to clear the bar |
| 6 | Do classical machine learning methods add value here? | Mostly no | 1 of 9 passed: calibrated forecast ranges |

## 1. Mutation testing found test gaps, now closed

A mutant is a small, plausible logic bug, such as a wrong sort order or a wrong denominator. 83 mutants were written in two batches, one of them blind by a separate model. 5 changed no output and were set aside. The build ran on each of the other 78.

The build caught 41 of them. Every mutant that moved a headline number was caught, but quieter ones passed. One reversed the monthly ranking, so `top_50_pct_user_share` was wrong in every month. Others broke the retry rate, the repeat rate's denominator, or the status mapping.

The unit test for sub-cent amounts couldn't fail. dbt casts the expected value to the column's own type, so a rounding cast passed it.

The tests added afterward catch all 35 targeted survivors: 27 fail the build and 8 warn. The other 2 sit in the semantic layer, and `analysis/check_semantic.py` catches them. Section 3.8 of the design lists the new tests.

**Why it matters.** Passing tests said little about whether the logic was right. Mutation testing measures that directly, and it needs no AI to rerun.

## 2. Definitions decide whether an AI agent gets the answer right

Blind agents answered 14 business questions, such as March's amount transacted or Provider 8's failed rate. Each worked in one of three setups:

| Setup | Haiku | Sonnet | Sonnet turns |
|---|---:|---:|---:|
| Raw tables only | 36% and 43% | 36% and 43% | 21 to 25 |
| Raw tables and written definitions | 100% | 100% | 11 to 16 |
| Published interface: marts, semantic layer, and catalog | 100% | 100% | 6 to 7 |

Scores are exact matches, for 2 runs each. On raw tables, agents counted undelivered payments as volume, treated cancellations as failures, and used the wrong months for final chargebacks.

The pass bar was that the interface beats written definitions by 20 points. It failed. A second round with 11 harder questions failed the same way, with both setups at 100%. The interface didn't add accuracy. It cut Sonnet's steps by more than half and its cost by about a fifth, and needed no access to raw tables.

**Why it matters.** Agreed definitions do the work. Self-service through AI is only as good as the definitions behind it. A governed interface makes it cheaper and keeps raw records closed.

## 3. An AI agent finds clear incidents

Incidents were seeded into copies of the data, and the marts were rebuilt. They covered a provider's failures rising on one route, a status relabel, two lost days of receipts, inflated promotion amounts, and lost chargeback flags. An agent got only a stakeholder's complaint, such as "payout quality looked worse in late June". It had to name the kind of defect, where it hit, such as the provider and route, and when it started. The results pool a main round and an independent rerun on a new draw.

| Setup | Haiku | Sonnet |
|---|---:|---:|
| Published interface | 17 of 18 | 18 of 18 |
| Raw tables | 16 of 18 | 16 of 18 |

All 24 runs on quiet periods correctly reported no incident. The difference between setups wasn't significant. On subtler incidents, such as a small rise in one route's failures, success fell to 25% to 62%. That round was exploratory, with no pass bar.

The status relabel and the inflated promotions passed every dbt test at the time. The agents found both.

**Why it matters.** Tests check rules someone wrote down. An agent can follow a vague complaint to its cause, including defects nobody wrote a rule for. It works best on clear incidents.

## 4. Smaller results

**Status triage.** A new payout status must be mapped before it reaches a metric, and an unknown one fails the build. Models with no tools or data classified 30 values, including 10 they hadn't seen, plus 6 that are ambiguous. Sonnet matched 29 of 30 in both runs and flagged its one miss for a human. Haiku made one silent error per run. The set is small, and I wrote the unseen values.

**Code review.** Agents reviewed diffs of model changes against the definitions. In the first batch, the commit messages gave the bugs away, so it doesn't count. In a held-out batch with the same message on every change, Sonnet caught all 7 surviving bugs with the right reason, and raised a false alarm in 3 of 22 reviews of harmless changes. Seven bugs is too few to clear the bar.

## 5. Classical methods

| Method | Verdict | Result |
|---|---|---|
| Conformal ranges on the daily forecast | Passed, not yet rerun | 80% ranges covered 81.9% of later days, at about plus or minus 9%. ETS ranges covered 90%, at about plus or minus 15% |
| Change-point detection on each provider's status mix | Failed on false alarms | Found Provider 12's change on 2026-08-09 and 38 of 42 seeded relabels, but up to 2 false changes per provider-quarter, against a limit of 1 |
| ETS, SARIMAX, and boosting forecasts | Failed | None beat trend times weekday, at 6.8% daily error |
| Seasonal and CUSUM anomaly monitors | Failed | The seasonal monitor won only on volume, and its lead depended on calibration |
| Fraud declines as stand-in labels for chargebacks | Failed | AUC 0.63, no better than a 4-flag rule, on 139 test chargebacks |
| k-means segments | Failed | Stable, but the segments are bank senders, cash senders, and promotion users |
| Survival model for the next send | Failed | Barely better than the number of sends so far |
| Isolation forest on users | Failed | The top 1% held about twice its share of users with chargebacks or fraud declines, against a bar of 3 times |
| Empirical Bayes provider rates by route | Failed | No better than raw rates on later months |

One business pattern held under adjustment. First-time senders with a promotion repeat within 90 days about 9.5 points less than comparable senders without one. Promoted users may differ in ways the data can't see, so this isn't a measured effect of promotions.

**Why it matters.** Most of these methods add nothing on 9 months of one company's data. Simple baselines held up. Only the calibrated ranges cleared their bar, and the status-mix scan caught relabels but raised too many false alarms.

## Limits

- Small samples: 18 main incidents, 30 status values, and 7 surviving bugs in the clean review batch.
- Seeded incidents and mutants are cleaner than real ones. I wrote most of them, and the agents and the mutant author come from one model family.
- Results depend on the model version.
- The shipped harness is slightly stricter than the original runs, and it fixes a timestamp bug in the query tool, so a rerun can differ a little.
- Agents ran through Claude's API, so the rows they queried were sent to the model.

## Reproduce

`analysis/ai/README.md` has the commands for sections 1 to 3 and the status triage. The code review, the exploratory round of subtler incidents, and the methods in section 5 have no script there. Mutation testing needs only the project's dbt environment. The agent experiments need the `claude` CLI, and a full rerun costs about $7.
