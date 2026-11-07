{{ config(severity='warn') }}

select issue, rows_affected, baseline_rows
from {{ ref('mart_known_issues') }}
where rows_affected > baseline_rows
