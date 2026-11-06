set timezone = 'UTC';

-- Reference values for the metric definitions proposed in docs/01-assessment-analysis.md.
-- These are checks of what the data supports. They are not the final marts.

create or replace temp table attempt_summary as
select r.payment_id,
    count(*) as attempts,
    sum((d.status_lc in ('paid', 'success', 'completed', 'delivered'))::int) as delivered_attempts,
    sum((d.status_lc in ('failed', 'rejected', 'cancelled', 'error_sending_payout_request', 'payout_not_processed'))::int) as failed_attempts,
    sum((d.id is null)::int) as missing_disbursements
from receipts r left join disbursements d on d.id = r.disbursement_id
group by 1;

create or replace temp table outcomes as
select p.*, case
        when a.payment_id is null then 'no_receipt'
        when a.delivered_attempts > 1 then 'multiple_delivered'
        when a.delivered_attempts = 1 then 'delivered'
        when a.failed_attempts = a.attempts then 'all_attempts_failed'
        else 'in_flight_or_unknown' end as payout_outcome
from payments p left join attempt_summary a on a.payment_id = p.id;

.print ## Payment outcome reconciliation
select status, payout_outcome, count(*) as payments, sum(amount) as usd
from outcomes group by all order by 1, 3 desc;

.print ## Outcome total check
select count(*) as classified, (select count(*) from payments) as payment_rows from outcomes;

.print ## Volume definitions
select 'all rows' as definition, count(*) as payments, sum(amount) as usd from payments
union all select 'SUCCESSFUL', count(*), sum(amount) from payments where status = 'SUCCESSFUL'
union all select 'delivered', count(*), sum(amount) from outcomes
    where status = 'SUCCESSFUL' and payout_outcome in ('delivered', 'multiple_delivered');

.print ## Monthly delivered volume
select strftime(created_at, '%Y-%m') as month, count(*) as remittances, count(distinct user_id) as active_users, sum(amount) as usd
from outcomes where status = 'SUCCESSFUL' and payout_outcome in ('delivered', 'multiple_delivered')
group by 1 order by 1;

.print ## Fee and promotion split on delivered attempts
select count(*) as delivered_attempts, sum(r.amount_charged) as charged, sum(r.fee) as fee, sum(r.promotion_amount) as promotion
from receipts r
join disbursements d on d.id = r.disbursement_id
join payments p on p.id = r.payment_id
where p.status = 'SUCCESSFUL' and d.status_lc in ('paid', 'success', 'completed', 'delivered');

.print ## Fees by corridor and payout type
select r.destination_country_code, d.type, count(*) as attempts, min(r.fee) as min_fee, median(r.fee) as median_fee, max(r.fee) as max_fee
from receipts r join disbursements d on d.id = r.disbursement_id
group by all having count(*) >= 100 order by attempts desc;

.print ## Successful payments without receipts by amount
select amount, count(*) as n
from outcomes where status = 'SUCCESSFUL' and payout_outcome = 'no_receipt'
group by 1 order by n desc limit 15;

.print ## Are no-receipt payment users also remittance users?
select count(distinct o.user_id) as users,
    count(distinct r.user_id) as also_have_receipts
from outcomes o left join receipts r on r.user_id = o.user_id
where o.status = 'SUCCESSFUL' and o.payout_outcome = 'no_receipt';

.print ## Payment failures by type
select type, count(*) as n, sum((status = 'FAILED')::int) as failed,
    round(100.0 * sum((status = 'FAILED')::int) / count(*), 2) as failed_pct
from payments group by 1 order by n desc;

.print ## Users with only failed payments
select count(*) as users, sum((successful = 0)::int) as never_successful from (
    select user_id, sum((status = 'SUCCESSFUL')::int) as successful from payments group by 1
);

.print ## Provider failure variants
select provider, count(*) as attempts,
    round(100.0 * sum((status_lc in ('failed', 'rejected', 'cancelled'))::int) / count(*), 2) as failed_or_cancelled_status_pct,
    round(100.0 * sum((status_lc in ('failed', 'rejected'))::int) / count(*), 2) as strict_status_pct,
    round(100.0 * sum((raw_status_lc in ('failed', 'rejected'))::int) / count(*), 2) as strict_raw_status_pct,
    round(100.0 * sum((raw_status_lc = 'cancelled')::int) / count(*), 2) as raw_cancelled_pct
from disbursements group by 1 order by attempts desc;

.print ## Provider attempt position
with ranked as (
    select r.payment_id, r.id, row_number() over (partition by r.payment_id order by r.created_at, r.id) as attempt_number
    from receipts r
)
select d.provider,
    sum((attempt_number = 1)::int) as first_attempts,
    sum((attempt_number > 1)::int) as retry_attempts,
    round(100.0 * sum((attempt_number = 1 and d.raw_status_lc in ('failed', 'rejected'))::int) / nullif(sum((attempt_number = 1)::int), 0), 2) as first_attempt_strict_pct,
    round(100.0 * sum((attempt_number > 1 and d.raw_status_lc in ('failed', 'rejected'))::int) / nullif(sum((attempt_number > 1)::int), 0), 2) as retry_strict_pct
from ranked x
join receipts r on r.id = x.id
join disbursements d on d.id = r.disbursement_id
group by 1 order by first_attempts + retry_attempts desc;

.print ## Failed-attempt rescue
select sum((failed_attempts > 0)::int) as payments_with_failed_attempt,
    sum((failed_attempts > 0 and delivered_attempts > 0)::int) as later_delivered,
    sum((failed_attempts > 0 and delivered_attempts = 0)::int) as never_delivered
from attempt_summary;

.print ## Chargeback cohorts
select strftime(created_at, '%Y-%m') as month, count(*) as settled,
    sum(has_chargeback::int) as chargebacks,
    round(100.0 * sum(has_chargeback::int) / count(*), 3) as count_pct,
    round(100.0 * sum(case when has_chargeback then amount else 0 end) / sum(amount), 3) as usd_pct
from payments where status in ('SUCCESSFUL', 'REFUNDED') group by 1 order by 1;

.print ## Chargeback summary
select count(*) as settled, sum(has_chargeback::int) as chargebacks,
    round(100.0 * sum(has_chargeback::int) / count(*), 3) as count_pct,
    sum(case when has_chargeback then amount else 0 end) as chargeback_usd,
    round(100.0 * sum(case when has_chargeback then amount else 0 end) / sum(amount), 3) as usd_pct
from payments where status in ('SUCCESSFUL', 'REFUNDED');

.print ## Chargebacks by payout outcome and type
select status, payout_outcome, type, count(*) as chargebacks, sum(amount) as usd
from outcomes where has_chargeback group by all order by chargebacks desc;

.print ## Chargeback timing proxy: updated_at lag in days
select round(median(epoch(updated_at - created_at)) / 86400, 1) as median_days,
    round(quantile_cont(epoch(updated_at - created_at), 0.9) / 86400, 1) as p90_days,
    round(max(epoch(updated_at - created_at)) / 86400, 1) as max_days
from payments where has_chargeback;

.print ## Top user concentration
with user_volume as (
    select user_id, sum(amount) as volume from outcomes
    where status = 'SUCCESSFUL' and payout_outcome in ('delivered', 'multiple_delivered')
    group by 1
),
ranked as (
    select *, sum(volume) over (order by volume desc, user_id) as cumulative_volume,
        sum(volume) over () as total_volume,
        row_number() over (order by volume desc, user_id) as user_rank,
        count(*) over () as users
    from user_volume
)
select min(user_rank) filter (where cumulative_volume >= total_volume * 0.5) as users_to_50_pct,
    max(users) as users,
    round(100.0 * min(user_rank) filter (where cumulative_volume >= total_volume * 0.5) / max(users), 2) as user_pct,
    min(volume) filter (where cumulative_volume < total_volume * 0.5) as lowest_included_before_crossing,
    max(volume) as highest_user_volume
from ranked;

.print ## Recurring definitions
with user_activity as (
    select user_id, count(*) as remittances, count(distinct strftime(created_at, '%Y-%m')) as active_months
    from outcomes
    where status = 'SUCCESSFUL' and payout_outcome in ('delivered', 'multiple_delivered')
    group by 1
)
select count(*) as users,
    sum((remittances >= 2)::int) as two_plus_remittances,
    sum((active_months >= 2)::int) as two_plus_months,
    sum((active_months >= 3)::int) as three_plus_months,
    round(100.0 * sum((active_months >= 2)::int) / count(*), 1) as two_plus_months_pct
from user_activity;

.print ## Recurring share by first delivered month
with user_activity as (
    select user_id, min(strftime(created_at, '%Y-%m')) as first_month,
        count(distinct strftime(created_at, '%Y-%m')) as active_months
    from outcomes
    where status = 'SUCCESSFUL' and payout_outcome in ('delivered', 'multiple_delivered')
    group by 1
)
select first_month, count(*) as users, sum((active_months >= 2)::int) as recurring,
    round(100.0 * sum((active_months >= 2)::int) / count(*), 1) as recurring_pct
from user_activity group by 1 order by 1;

.print ## Gap between delivered remittances, in days
with gaps as (
    select epoch(created_at - lag(created_at) over (partition by user_id order by created_at)) / 86400 as gap_days
    from outcomes where status = 'SUCCESSFUL' and payout_outcome in ('delivered', 'multiple_delivered')
)
select count(gap_days) as gaps, round(quantile_cont(gap_days, 0.25), 1) as p25,
    round(median(gap_days), 1) as p50, round(quantile_cont(gap_days, 0.75), 1) as p75,
    round(quantile_cont(gap_days, 0.9), 1) as p90
from gaps;
