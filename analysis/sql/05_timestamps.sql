set timezone = 'UTC';

.print ## Timestamp text format
select field, count(*) as n,
    sum((not regexp_full_match(txt, '[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}(\.[0-9]{1,6})?\+00:00'))::int) as unexpected_format,
    sum((try_cast(txt as timestamptz) is null)::int) as failed_cast,
    sum((txt not like '%+00:00')::int) as not_utc_offset,
    min(txt) as first_value, max(txt) as last_value
from timestamp_text group by 1 order by 1;

.print ## Fractional-second digits
select field,
    case when txt like '%.%' then length(split_part(split_part(txt, '.', 2), '+', 1)) else 0 end as fractional_digits,
    count(*) as n
from timestamp_text group by 1, 2 order by 1, 2;

.print ## Monthly coverage by file
select month, sum(payments) as payments, sum(receipts) as receipts, sum(disbursements) as disbursements from (
    select strftime(created_at, '%Y-%m') as month, count(*) as payments, 0 as receipts, 0 as disbursements from payments group by 1
    union all select strftime(created_at, '%Y-%m'), 0, count(*), 0 from receipts group by 1
    union all select strftime(created_at, '%Y-%m'), 0, 0, count(*) from disbursements group by 1
) group by 1 order by 1;

.print ## Missing days inside the extract
with days as (
    select unnest(generate_series(date '2026-01-01', date '2026-09-22', interval 1 day))::date as day
),
counts as (
    select created_at::date as day, count(*) as n from payments group by 1
)
select count(*) as calendar_days, count(c.day) as days_with_payments, min(c.n) as min_daily_payments,
    median(c.n) as median_daily_payments, max(c.n) as max_daily_payments
from days d left join counts c using (day);

.print ## Lowest payment days
select created_at::date as day, count(*) as n
from payments group by 1 order by n limit 10;

.print ## Largest time gaps between consecutive payments
select previous_at, created_at, epoch(created_at - previous_at) / 60 as gap_minutes from (
    select created_at, lag(created_at) over (order by created_at) as previous_at from payments
) order by gap_minutes desc nulls last limit 5;

.print ## Chronology within each record
select 'payments updated before created' as check_name, count(*) as n from payments where updated_at < created_at
union all select 'disbursements updated before created', count(*) from disbursements where updated_at < created_at
union all select 'payments updated after last created_at', count(*) from payments where updated_at > (select max(created_at) from payments)
union all select 'disbursements updated after last created_at', count(*) from disbursements where updated_at > (select max(created_at) from disbursements);

.print ## Latest update timestamps
select (select max(updated_at) from payments) as payments_latest_update,
    (select max(updated_at) from disbursements) as disbursements_latest_update;

.print ## Update lag by payment status, in hours
select status, count(*) as n,
    round(median(epoch(updated_at - created_at)) / 3600, 3) as median_hours,
    round(quantile_cont(epoch(updated_at - created_at), 0.99) / 3600, 3) as p99_hours,
    round(max(epoch(updated_at - created_at)) / 3600, 1) as max_hours
from payments group by 1 order by n desc;

.print ## Update lag by disbursement status, in hours
select status_lc, count(*) as n,
    round(median(epoch(updated_at - created_at)) / 3600, 3) as median_hours,
    round(quantile_cont(epoch(updated_at - created_at), 0.99) / 3600, 3) as p99_hours,
    round(max(epoch(updated_at - created_at)) / 3600, 1) as max_hours
from disbursements group by 1 order by n desc;

.print ## Cross-file timing, in seconds
select
    round(median(epoch(r.created_at - p.created_at)), 2) as receipt_after_payment_median,
    round(quantile_cont(epoch(r.created_at - p.created_at), 0.99), 2) as receipt_after_payment_p99,
    sum((r.created_at < p.created_at)::int) as receipt_before_payment,
    round(median(abs(epoch(d.created_at - r.created_at))), 3) as disbursement_receipt_abs_median,
    round(max(abs(epoch(d.created_at - r.created_at))), 3) as disbursement_receipt_abs_max,
    sum((d.created_at < r.created_at)::int) as disbursement_before_receipt
from receipts r
join payments p on p.id = r.payment_id
join disbursements d on d.id = r.disbursement_id;

.print ## Age of non-terminal disbursements at the extract end
with extract_end as (select max(created_at) as extract_at from disbursements)
select status_lc, count(*) as n,
    sum((created_at >= extract_at - interval 2 day)::int) as under_2_days,
    sum((created_at < extract_at - interval 2 day and created_at >= extract_at - interval 30 day)::int) as days_2_to_30,
    sum((created_at < extract_at - interval 30 day)::int) as over_30_days,
    min(created_at) as oldest
from disbursements, extract_end
where status_lc not in ('paid', 'success', 'completed', 'delivered', 'failed', 'rejected', 'cancelled')
group by 1 order by n desc;

.print ## Sensitivity: UTC month compared with New York month
with delivered as (
    select distinct p.id, p.amount, p.created_at
    from payments p
    join receipts r on r.payment_id = p.id
    join disbursements d on d.id = r.disbursement_id
    where p.status = 'SUCCESSFUL' and d.status_lc in ('paid', 'success', 'completed', 'delivered')
),
months as (
    select strftime(created_at, '%Y-%m') as utc_month,
        strftime(timezone('America/New_York', created_at), '%Y-%m') as new_york_month,
        amount
    from delivered
)
select month, sum(utc_usd) as utc_usd, sum(new_york_usd) as new_york_usd, sum(new_york_usd) - sum(utc_usd) as difference from (
    select utc_month as month, amount as utc_usd, 0 as new_york_usd from months
    union all select new_york_month, 0, amount from months
) group by 1 order by 1;
