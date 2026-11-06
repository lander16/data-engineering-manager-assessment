set timezone = 'UTC';

-- Evidence for the design changes in docs/02-revised-plan.md.
-- Applies the proposed attempt status rule, using the earliest delivered attempt as the primary one.

create or replace temp table attempts as
select r.id as receipt_id, r.payment_id, r.created_at, r.amount_charged, r.fee, r.promotion_amount,
    d.id as disbursement_id, d.provider, d.status_lc, d.raw_status_lc,
    case
        when d.id is null then 'missing'
        when d.status_lc = 'cancelled' or d.raw_status_lc = 'cancelled' then 'cancelled'
        when d.status_lc in ('paid', 'success', 'completed', 'delivered') then 'delivered'
        when d.status_lc in ('failed', 'rejected', 'error_sending_payout_request', 'payout_not_processed') then 'failed'
        else 'in_flight'
    end as attempt_status
from receipts r left join disbursements d on d.id = r.disbursement_id;

create or replace temp table delivered_attempts as
select a.*, p.amount as payment_amount,
    row_number() over (partition by a.payment_id order by a.created_at, a.receipt_id) as delivered_rank,
    count(*) over (partition by a.payment_id) as delivered_count
from attempts a join payments p on p.id = a.payment_id
where a.attempt_status = 'delivered' and p.status = 'SUCCESSFUL';

create or replace temp table payment_outcomes as
select p.id, p.status, p.amount, case
        when count(a.receipt_id) = 0 then 'no_receipt'
        when sum((a.attempt_status = 'delivered')::int) > 1 then 'multiple_delivered'
        when sum((a.attempt_status = 'delivered')::int) = 1 then 'delivered'
        when sum((a.attempt_status = 'in_flight')::int) > 0 then 'in_flight'
        when sum((a.attempt_status = 'missing')::int) > 0 then 'missing_payout'
        else 'not_delivered' end as payout_outcome
from payments p left join attempts a on a.payment_id = p.id
group by all;

.print ## Delivered attempts and payments
select count(*) as delivered_attempts, count(distinct payment_id) as payments from delivered_attempts;

.print ## Primary attempt economics compared with all delivered attempts
select
    sum(amount_charged + promotion_amount) as value_all_delivered,
    sum(amount_charged + promotion_amount) filter (where delivered_rank = 1) as value_primary,
    sum(fee) as fee_all_delivered,
    sum(fee) filter (where delivered_rank = 1) as fee_primary,
    sum(promotion_amount) as promotion_all_delivered,
    sum(promotion_amount) filter (where delivered_rank = 1) as promotion_primary
from delivered_attempts;

.print ## Multiple delivered payments
select count(distinct payment_id) as payments,
    sum(amount_charged + promotion_amount) filter (where delivered_rank > 1) as duplicate_value,
    sum(fee) filter (where delivered_rank > 1) as duplicate_fee,
    sum(promotion_amount) filter (where delivered_rank > 1) as duplicate_promotion
from delivered_attempts where delivered_count > 1;

.print ## Primary attempt compared with payment amount
select count(*) as payments,
    sum((round(payment_amount, 2) = amount_charged + fee)::int) as ties_out,
    sum((round(payment_amount, 2) <> amount_charged + fee)::int) as does_not_tie,
    sum(round(payment_amount, 2) - (amount_charged + fee)) as net_gap_usd
from delivered_attempts where delivered_rank = 1;

.print ## Promotions by attempt status
select attempt_status, count(*) as attempts, sum(promotion_amount) as promotion_usd
from attempts where promotion_amount > 0 group by 1 order by 3 desc;

.print ## Fee and promotion differences across attempts of one payment
select count(*) as multi_attempt_payments,
    sum((fees > 1)::int) as fee_differs,
    sum((promotions > 1)::int) as promotion_differs
from (
    select payment_id, count(distinct fee) as fees, count(distinct promotion_amount) as promotions
    from attempts group by 1 having count(*) > 1
);

.print ## Payout outcomes under the proposed rule
select status, payout_outcome, count(*) as payments, sum(amount) as usd
from payment_outcomes group by all order by 1, 3 desc;

.print ## Provider rates with a terminal denominator
with totals as (
    select provider, count(*) as attempts,
        sum((attempt_status = 'delivered')::int) as delivered,
        sum((attempt_status = 'failed')::int) as failed,
        sum((attempt_status = 'cancelled')::int) as cancelled,
        sum((attempt_status = 'in_flight')::int) as in_flight
    from attempts where attempt_status <> 'missing' group by 1
)
select provider, attempts, delivered, failed, cancelled, in_flight,
    round(100.0 * failed / attempts, 2) as failed_over_all_pct,
    round(100.0 * failed / nullif(delivered + failed, 0), 2) as failed_rate_pct,
    round(100.0 * cancelled / nullif(delivered + failed + cancelled, 0), 2) as cancelled_rate_pct,
    case when attempts < 1000 then 'insufficient_volume'
        when 100.0 * failed / nullif(delivered + failed, 0) < 1 then 'low'
        when 100.0 * failed / nullif(delivered + failed, 0) < 3 then 'medium'
        else 'high' end as failure_class
from totals order by attempts desc;

.print ## First observed attempt rates with a terminal denominator
with ranked as (
    select *, row_number() over (partition by payment_id order by created_at, receipt_id) as attempt_number
    from attempts
)
select provider,
    sum((attempt_status in ('delivered', 'failed'))::int) as terminal_first_attempts,
    round(100.0 * sum((attempt_status = 'failed')::int) / nullif(sum((attempt_status in ('delivered', 'failed'))::int), 0), 2) as first_failed_rate_pct
from ranked where attempt_number = 1 and attempt_status <> 'missing'
group by 1 order by 2 desc;

.print ## Status conflicts and whether another attempt was delivered
with conflicts as (
    select a.payment_id, a.raw_status_lc, p.status as payment_status
    from attempts a join payments p on p.id = a.payment_id
    where a.status_lc = 'cancelled' and a.raw_status_lc in ('paid', 'completed', 'created')
),
delivered as (
    select payment_id, sum((attempt_status = 'delivered')::int) as delivered_attempts
    from attempts group by 1
)
select c.raw_status_lc, c.payment_status, d.delivered_attempts > 0 as other_attempt_delivered,
    o.payout_outcome, count(*) as attempts, sum(o.amount) as usd
from conflicts c
join delivered d using (payment_id)
join payment_outcomes o on o.id = c.payment_id
group by all order by 1, 2, 3;

.print ## Comparable recurring follow-up by first delivered month
with delivered_payments as (
    select distinct p.id, p.user_id, p.created_at
    from payments p join attempts a on a.payment_id = p.id
    where p.status = 'SUCCESSFUL' and a.attempt_status = 'delivered'
),
firsts as (
    select user_id, min(created_at) as first_at, strftime(min(created_at), '%Y-%m') as cohort
    from delivered_payments group by 1
),
extract_end as (select max(created_at) as extract_at from payments),
users as (
    select f.user_id, f.cohort, f.first_at,
        max((dp.created_at > f.first_at + interval 1 day and dp.created_at <= f.first_at + interval 60 day)::int) as repeated_within_60_days
    from firsts f join delivered_payments dp using (user_id)
    group by all
)
select cohort, count(*) as users,
    sum((first_at <= extract_at - interval 60 day)::int) as users_with_full_window,
    round(100.0 * sum(repeated_within_60_days) filter (where first_at <= extract_at - interval 60 day)
        / nullif(sum((first_at <= extract_at - interval 60 day)::int), 0), 1) as repeat_60_day_pct
from users, extract_end group by 1 order by 1;
