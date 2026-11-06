set timezone = 'UTC';

.print ## Row counts
select * from file_rows order by source_file;

.print ## Column completeness, cardinality, and text hygiene
with stats as (
    select source_file, column_name,
        count(*) as non_null,
        count(distinct value) as distinct_values,
        sum((value = '')::int) as empty_strings,
        sum((value <> trim(value))::int) as padded,
        sum((lower(trim(value)) in ('null', 'none', 'nan', 'n/a', 'na', 'undefined', 'unknown', '-'))::int) as null_like,
        min(length(value)) as min_len,
        max(length(value)) as max_len
    from column_values
    group by all
)
select s.source_file, s.column_name, f.row_count, s.non_null,
    f.row_count - s.non_null as nulls,
    round(100.0 * (f.row_count - s.non_null) / f.row_count, 3) as null_pct,
    s.distinct_values, s.empty_strings, s.padded, s.null_like, s.min_len, s.max_len
from stats s join file_rows f using (source_file)
order by s.source_file, s.column_name;

.print ## Columns with no values at all
select c.source_file, c.column_name
from (
    select 'payments' source_file, unnest(['error_code', 'reason']) column_name
) c
left join column_values v using (source_file, column_name)
group by all having count(v.value) = 0;

.print ## Null-like literal values found
select source_file, column_name, value, count(*) as n
from column_values
where lower(trim(value)) in ('null', 'none', 'nan', 'n/a', 'na', 'undefined', 'unknown', '-')
group by all order by n desc;
