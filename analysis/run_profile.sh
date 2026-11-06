#!/usr/bin/env bash
# Rebuilds the profiling results from the source CSVs.
# Run from anywhere: bash analysis/run_profile.sh
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_root"

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT
db="$work_dir/profile.duckdb"

shasum -a 256 -c analysis/results/source_checksums.sha256

duckdb -no-agent "$db" < analysis/sql/00_setup.sql

for sql_file in analysis/sql/0[1-9]_*.sql analysis/sql/1[0-9]_*.sql; do
    name="$(basename "$sql_file" .sql)"
    echo "Running $name"
    duckdb -no-agent -markdown "$db" < "$sql_file" > "analysis/results/$name.md"
done

shasum -a 256 -c analysis/results/source_checksums.sha256
echo "Results are in analysis/results/"
