"""Check each semantic-layer metric against the mart that publishes it.

Run after `dbt build`, from the project root, with requirements-semantic.txt
installed. Exits non-zero on any difference.
"""
import csv
import math
import subprocess
import sys
import tempfile
from pathlib import Path

import duckdb

MONTH = "metric_time__month"
CHECKS = [
    ("transacted_usd", MONTH, "select payment_month, transacted_usd from main.mart_monthly_volume"),
    ("delivered_remittances", MONTH, "select payment_month, delivered_remittances from main.mart_monthly_volume"),
    ("chargeback_count_rate", MONTH, "select payment_month, count_rate from main.mart_chargeback_rate"),
    ("chargeback_value_rate", MONTH, "select payment_month, value_rate from main.mart_chargeback_rate"),
    ("provider_failed_rate", "attempt__provider", "select provider, failed_rate from main.mart_provider_failures"),
    ("recurring_users", MONTH, "select first_delivered_month, recurring_users from main.mart_recurring_cohorts"),
    (
        "top_volume_users",
        None,
        "select 'total', users from main.mart_user_segments where segment = 'top_50_pct_volume'",
    ),
    (
        "transacted_usd",
        "user__volume_class",
        "select segment, transacted_usd from main.mart_user_segments where segment_type = 'volume_class'",
    ),
]


def nonzero(pairs):
    """Compare only real values: the two sides show an empty group as 0, NULL, or no row."""
    values = {str(name)[:10] if str(name)[:4].isdigit() else str(name): float(value or 0) for name, value in pairs}
    return {name: value for name, value in values.items() if value}


def query_metric(metric, group_by, folder):
    path = Path(folder) / f"{metric}.csv"
    command = ["mf", "query", "--metrics", metric, "--csv", str(path)]
    if group_by:
        command += ["--group-by", group_by]
    subprocess.run(command, check=True, capture_output=True)
    with path.open() as handle:
        rows = list(csv.DictReader(handle))
    return nonzero((row[group_by] if group_by else "total", row[metric]) for row in rows)


def query_mart(connection, sql):
    return nonzero(connection.execute(sql).fetchall())


def differs(expected, actual):
    if expected.keys() != actual.keys():
        return True
    return any(not math.isclose(expected[k], actual[k], rel_tol=1e-12) for k in expected)


def main():
    failures = 0
    with tempfile.TemporaryDirectory() as folder:
        for metric, group_by, sql in CHECKS:
            actual = query_metric(metric, group_by, folder)
            with duckdb.connect("felix.duckdb", read_only=True) as connection:
                expected = query_mart(connection, sql)
            failed = differs(expected, actual)
            failures += failed
            print(f"{'FAIL' if failed else 'PASS'} {metric} by {group_by or 'total'}: {len(expected)} values")
    print(f"{len(CHECKS) - failures} of {len(CHECKS)} checks match the marts")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
