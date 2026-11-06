set timezone = 'UTC';

-- Rechecks figures under the adopted status rule, plus later checks.
-- Uses the adopted rule: `status` decides, and `raw_status` only raises a conflict flag.
-- Helper tables come from 10_research_setup.sql, which used the earlier rule, so status is reclassified here.

create temp table review_attempts as
select *,
    case
        when matched_disbursement_id is null then 'missing'
        when status_lc = 'cancelled' then 'cancelled'
        when status_lc in ('paid', 'success', 'completed', 'delivered') then 'delivered'
        when status_lc in ('failed', 'rejected', 'error_sending_payout_request', 'payout_not_processed') then 'failed'
        when status_lc in ('payable', 'wire_released', 'wire_confirmed', 'transmitted', 'in_progress', 'pending',
            'to_be_processed', 'on_hold', 'hold_by_compliance', 'hold_by_payer', 'cancellation_in_progress') then 'in_flight'
        else 'unknown'
    end as adopted_status,
    status_lc = 'cancelled' and raw_status_lc in ('paid', 'completed') as is_cancelled_raw_paid
from attempts;

create temp table review_payments as
select a.payment_id, p.status as payment_status, p.amount,
    count(*) filter (where a.adopted_status = 'delivered') as delivered_attempts
from review_attempts a
join payments p on p.id = a.payment_id
group by all;

.print ## R1 Outcomes under the adopted rule
select adopted_status, count(*) as attempts from review_attempts group by 1 order by 1;
select count(*) as delivered_remittances, sum(amount) as customer_paid_usd
from review_payments where payment_status = 'SUCCESSFUL' and delivered_attempts > 0;

.print ## R2 Receipts with no disbursement: null ID against orphan ID
select count(*) filter (where disbursement_id is null) as null_id,
    count(*) filter (where disbursement_id is not null) as orphan_id,
    count(*) filter (where provider is null) as null_provider
from review_attempts where adopted_status = 'missing';

.print ## R3 Provider rates, classes, and 95% Wilson intervals
with counts as (
    select provider,
        count(*) filter (where adopted_status = 'failed') as failed,
        count(*) filter (where adopted_status = 'delivered') as delivered,
        count(*) filter (where adopted_status = 'cancelled') as cancelled,
        count(*) filter (where adopted_status = 'failed' and attempt_number = 1) as first_failed,
        count(*) filter (where adopted_status = 'delivered' and attempt_number = 1) as first_delivered
    from review_attempts
    where adopted_status <> 'missing'
    group by 1
),
rates as (
    select *, failed + delivered as n, failed * 1.0 / nullif(failed + delivered, 0) as r,
        first_failed * 1.0 / nullif(first_failed + first_delivered, 0) as fr,
        (failed + cancelled) * 1.0 / nullif(failed + delivered + cancelled, 0) as ur,
        1.96 as z
    from counts
)
select provider, n as terminal_attempts,
    round(100 * r, 2) as failed_pct,
    round(100 * (r + z * z / (2 * n) - z * sqrt(r * (1 - r) / n + z * z / (4 * n * n))) / (1 + z * z / n), 2) as wilson_low,
    round(100 * (r + z * z / (2 * n) + z * sqrt(r * (1 - r) / n + z * z / (4 * n * n))) / (1 + z * z / n), 2) as wilson_high,
    round(100 * fr, 2) as first_attempt_failed_pct,
    round(100 * ur, 2) as unsuccessful_terminal_pct,
    case when n < 1000 then 'insufficient_volume' when r < 0.01 then 'low' when r < 0.03 then 'medium' else 'high' end as failure_class,
    case when n < 1000 then 'insufficient_volume' when fr < 0.01 then 'low' when fr < 0.03 then 'medium' else 'high' end as first_attempt_class,
    case when n < 1000 then 'insufficient_volume' when ur < 0.01 then 'low' when ur < 0.03 then 'medium' else 'high' end as unsuccessful_class
from rates
order by n desc;

.print ## R4 CANCELLED with raw PAID or COMPLETED, by what else happened
select a.provider, b.payment_status, b.delivered_attempts > 0 as has_delivered_attempt,
    count(*) as attempts, count(distinct a.payment_id) as payments, sum(b.amount) as usd
from review_attempts a
join review_payments b using (payment_id)
where a.is_cancelled_raw_paid
group by all
order by 1, 2, 3;

.print ## R5 Named issues
select 'conflict_likely_delivered' as issue, count(distinct a.payment_id) as payments, sum(b.amount) as usd
from (select distinct payment_id from review_attempts where is_cancelled_raw_paid) a
join review_payments b using (payment_id)
where b.payment_status = 'SUCCESSFUL' and b.delivered_attempts = 0
union all
select 'possible_double_payout', count(*), sum(b.amount)
from (
    select distinct a.payment_id
    from review_attempts a
    join review_attempts later on later.payment_id = a.payment_id
        and later.adopted_status = 'delivered' and later.attempt_number > a.attempt_number
    where a.is_cancelled_raw_paid
) a
join review_payments b using (payment_id);

.print ## R6 Provider 4 cancelled with raw COMPLETED
select count(*) as attempts, sum(b.amount) as usd, min(a.attempt_at)::date as first_day, max(a.attempt_at)::date as last_day
from review_attempts a
join review_payments b using (payment_id)
where a.is_cancelled_raw_paid and a.provider = 'PROVIDER 4';

.print ## R7 No-receipt successful payments by amount family
select case
        when p.amount = 1 then 'one_dollar'
        when (p.amount + 0.25) / 6.25 = round((p.amount + 0.25) / 6.25) then 'scheduled_amount'
        else 'other'
    end as family,
    count(*) as payments, sum(p.amount) as usd
from payments p
left join receipts r on r.payment_id = p.id
where r.id is null and p.status = 'SUCCESSFUL'
group by 1
order by 2 desc;

.print ## R8 User and beneficiary pairs
select count(*) as all_pairs, count(*) filter (where is_on_first_attempt) as first_attempt_pairs,
    count(*) filter (where not is_on_first_attempt) as retry_only_pairs,
    count(distinct user_id) filter (where not is_on_first_attempt) as users_with_retry_only_pairs
from (
    select user_id, beneficiary_id, bool_or(attempt_number = 1) as is_on_first_attempt
    from review_attempts
    group by 1, 2
);

.print ## R9 Chargeback rates by maturity lag, settled against card denominators
with settled as (
    select cast(date_trunc('month', created_at at time zone 'UTC') as date) as payment_month,
        amount, type in ('CARD', 'APPLE_PAY') as is_card_like, has_chargeback
    from payments
    where status in ('SUCCESSFUL', 'REFUNDED')
),
windows(lag_label, last_month) as (
    values ('60 days', date '2026-06-01'), ('90 days', date '2026-05-01'),
        ('120 days', date '2026-04-01'), ('none', date '2026-09-01')
)
select lag_label, count(*) as settled_payments, count(*) filter (where has_chargeback) as flagged,
    round(100.0 * count(*) filter (where has_chargeback) / count(*), 4) as count_rate_pct,
    round(100 * sum(amount) filter (where has_chargeback) / sum(amount), 4) as value_rate_pct,
    count(*) filter (where is_card_like) as card_payments,
    round(100.0 * count(*) filter (where has_chargeback and is_card_like) / count(*) filter (where is_card_like), 4) as card_count_rate_pct
from settled
join windows on payment_month <= last_month
group by 1
order by 2;

.print ## R10 Paid, undelivered, and unrefunded payments
select count(*) as payments, sum(p.amount) as usd, count(*) filter (where p.has_chargeback) as flagged,
    count(*) filter (where p.type in ('CARD', 'APPLE_PAY')) as card_like
from payments p
join (
    select payment_id from review_attempts
    group by 1
    having count(*) filter (where adopted_status in ('delivered', 'in_flight', 'missing')) = 0
) x on x.payment_id = p.id
where p.status = 'SUCCESSFUL';

create temp table review_primary as
select * from (
    select *, row_number() over (partition by payment_id order by attempt_number) as delivered_rank
    from review_attempts
    where adopted_status = 'delivered'
)
where delivered_rank = 1;

create temp table review_remittances as
select p.id as payment_id, p.user_id, p.amount, p.created_at,
    cast(date_trunc('month', p.created_at at time zone 'UTC') as date) as payment_month,
    a.amount_charged, a.fee, a.promotion_amount
from payments p
join review_primary a on a.payment_id = p.id
where p.status = 'SUCCESSFUL';

.print ## R11 Delivered remittances by payment amount
select case when amount < 0 then 'negative' when amount = 0 then 'zero' else 'positive' end as amount_sign,
    count(*) as remittances, count(distinct user_id) as users, sum(amount_charged + promotion_amount) as value_sent_usd
from review_remittances
group by 1
order by 2 desc;
select count(*) as users_with_only_zero_amount
from (select user_id from review_remittances group by 1 having sum(amount) = 0);
select count(*) filter (where months >= 2) as recurring, count(*) filter (where positive_months >= 2) as recurring_on_positive_amounts
from (
    select user_id, count(distinct payment_month) as months,
        count(distinct payment_month) filter (where amount > 0) as positive_months
    from review_remittances
    group by 1
);

.print ## R12 Payment against primary attempt, by cause
select case
        when round(amount, 2) = round(amount_charged + fee, 2) then 'ties'
        when fee = 0 and round(amount - amount_charged, 2) > 0 then 'fee_zero_on_receipt'
        when round(amount, 2) < round(amount_charged + fee, 2) then 'receipt_higher'
        else 'other'
    end as cause,
    count(*) as remittances, sum(round(amount, 2) - round(amount_charged + fee, 2)) as net_usd
from review_remittances
group by 1
order by 2 desc;

.print ## R13 Disbursement created over a minute before its receipt
select count(*) as attempts, count(*) filter (where attempt_number > 1) as on_retries,
    round(max(epoch(attempt_at - disbursement_created_at)) / 86400, 1) as longest_days
from review_attempts
where disbursement_created_at < attempt_at - interval 1 minute;
select count(*) as payments_whose_first_attempt_changes
from (
    select payment_id, arg_min(receipt_id, attempt_at) as by_receipt,
        arg_min(receipt_id, coalesce(disbursement_created_at, attempt_at)) as by_disbursement
    from review_attempts
    group by 1
    having count(*) > 1
)
where by_receipt <> by_disbursement;

.print ## R14 Grain checks for receipt to disbursement
select count(*) as disbursement_ids_on_several_receipts
from (select disbursement_id from receipts group by 1 having count(*) > 1);
select count(*) as disbursements_without_receipt
from disbursements d
left join receipts r on r.disbursement_id = d.id
where r.id is null;

.print ## R15 Monthly senders
with user_months as (
    select user_id, payment_month from review_remittances group by 1, 2
),
first_months as (
    select user_id, min(payment_month) as first_month from user_months group by 1
)
select payment_month, count(*) as active_senders,
    count(*) filter (where payment_month = first_month) as first_seen_senders,
    count(*) filter (where payment_month > first_month) as returning_senders,
    round(100.0 * count(*) filter (where payment_month > first_month) / count(*), 1) as returning_pct
from user_months
join first_months using (user_id)
group by 1
order by 1;
