{{ config(severity='warn') }}

-- Any change warns, not only growth: a drop can also mean a definition broke.
select issue, rows_affected, baseline_rows
from {{ ref('mart_known_issues') }}
where rows_affected <> baseline_rows
