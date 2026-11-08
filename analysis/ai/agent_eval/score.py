"""Score agent answers against golden values computed from the marts at run time.

usage: python analysis/ai/agent_eval/score.py [--db felix.duckdb]

Exact means within 0.006 points on a percentage and within 0.01% otherwise. Loose means
within 1%. Golden values are never written to disk.
"""
import argparse
import collections
import sys
from pathlib import Path

import duckdb

HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE.parent))
from common import PROJECT_DB, last_json, result_event  # noqa: E402

FAILED_RATE = ("select 100.0 * count(*) filter (attempt_status = 'failed')"
               " / count(*) filter (attempt_status in ('delivered', 'failed')) from int_payout_attempts where ")
GOLD = {
    "round1": {
        "Q1": "select transacted_usd from mart_monthly_volume where payment_month = '2026-03-01'",
        "Q2": "select delivered_remittances from mart_monthly_volume where payment_month = '2026-06-01'",
        "Q3": "select sum(transacted_usd) from mart_monthly_volume",
        "Q4": "select users from mart_user_segments where segment = 'top_50_pct_volume'",
        "Q5": "select count(*) from dim_users where is_recurring",
        "Q6": "select 100 * failed_rate from mart_provider_failures where provider = 'PROVIDER 3'",
        "Q7": "select 100 * failed_rate from mart_provider_failures where provider = 'PROVIDER 8'",
        "Q8": "select 100.0 * sum(flagged_payments) / sum(settled_payments) from mart_chargeback_rate",
        "Q9": "select count(*) from mart_shared_beneficiaries where users >= 2",
        "Q10": "select active_senders from mart_monthly_volume where payment_month = '2026-08-01'",
        "Q11": FAILED_RATE + "provider = 'PROVIDER 12' and attempt_at >= '2026-08-01' and attempt_at < '2026-09-01'",
        "Q12": FAILED_RATE + "country_code = 'GT' and payout_type = 'BANK'",
        "Q13": "select sum(promotion_usd) from mart_monthly_volume",
        "Q14": "select 100.0 * sum(flagged_payments) / sum(settled_payments) from mart_chargeback_rate where is_mature",
    },
    "round2": {
        "Q1": """select sum(f.transacted_usd) from fct_remittances f join int_payout_attempts a
                 on a.payment_id = f.payment_id and a.is_primary_attempt where f.is_delivered_remittance and a.country_code = 'GT'""",
        "Q2": "select sum(value_sent_usd) from mart_monthly_volume",
        "Q3": "select 100 * unsuccessful_terminal_rate from mart_provider_failures where provider = 'PROVIDER 8'",
        "Q4": "select 100 * first_attempt_failed_rate from mart_provider_failures where provider = 'PROVIDER 3'",
        "Q5": "select 100 * repeat_rate from mart_recurring_cohorts where first_delivered_month = '2026-03-01'",
        "Q6": "select users from mart_user_segments where segment_type = 'beneficiary_segment' and segment = '4-9'",
        "Q7": "select count(*) from fct_remittances where payment_status = 'SUCCESSFUL' and payout_outcome = 'not_delivered'",
        "Q8": "select 100 * top_50_pct_user_share from mart_monthly_volume where payment_month = '2026-06-01'",
        "Q9": "select first_seen_senders from mart_monthly_volume where payment_month = '2026-05-01'",
        "Q10": """select 100.0 * sum(flagged_payment_value_usd) / sum(settled_value_usd)
                  from mart_chargeback_rate where is_mature""",
        "Q11": "select count(*) from dim_users where is_recurring and volume_class = 'top_50_pct_volume'",
    },
}
PERCENT = {"round1": {"Q6", "Q7", "Q8", "Q11", "Q12", "Q14"}, "round2": {"Q3", "Q4", "Q5", "Q8", "Q10"}}


def gold(db):
    with duckdb.connect(str(db), read_only=True, config={"TimeZone": "UTC"}) as con:
        return {s: {q: float(con.execute(sql).fetchone()[0]) for q, sql in qs.items()} for s, qs in GOLD.items()}


def grade(question_set, q, answer, expected):
    try:
        x = float(answer)
    except (TypeError, ValueError):
        return False, False
    if q in PERCENT[question_set]:
        exact = abs(x - expected) <= 0.006
    else:
        exact = x == 0 if expected == 0 else abs(x - expected) / abs(expected) <= 0.0001
    loose = x == 0 if expected == 0 else abs(x - expected) / abs(expected) <= 0.01
    return exact, loose


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--db", default=PROJECT_DB, help="a built felix.duckdb, opened read-only")
    args = parser.parse_args()
    golds = gold(args.db)
    rows, per_question = [], collections.defaultdict(lambda: collections.defaultdict(int))
    for path in sorted((HERE / "work" / "transcripts").glob("*.jsonl")):
        question_set, arm, model, rep = path.stem.split("_")
        result = result_event(path)
        answers = last_json(result.get("result", ""), "Q1") or {}
        exact = loose = 0
        for q, expected in golds[question_set].items():
            e, l = grade(question_set, q, answers.get(q), expected)
            exact, loose = exact + e, loose + l
            per_question[(question_set, arm, model)][q] += e
        rows.append(dict(cell=(question_set, arm, model), rep=rep, exact=exact, loose=loose, n=len(golds[question_set]),
                         cost=result.get("total_cost_usd", 0), turns=result.get("num_turns") or 0,
                         parsed=bool(answers)))
    print("| Round | Arm | Model | Rep | Exact | Loose | Cost | Turns | Parsed |\n|---|---|---|---:|---:|---:|---:|---:|---|")
    for r in rows:
        print(f"| {' | '.join(r['cell'])} | {r['rep']} | {r['exact']}/{r['n']} | {r['loose']}/{r['n']} "
              f"| ${r['cost']:.3f} | {r['turns']} | {'yes' if r['parsed'] else 'no'} |")
    print("\nExact answers by question, summed over repeats:")
    for cell, counts in sorted(per_question.items()):
        print(f"  {' '.join(cell)}: " + " ".join(f"{q}={n}" for q, n in counts.items()))
    print(f"\nRuns {len(rows)}, total cost ${sum(r['cost'] for r in rows):.2f}")


if __name__ == "__main__":
    main()
