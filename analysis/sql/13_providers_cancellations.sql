set timezone = 'UTC';

-- Evidence for three open modeling questions: who initiates CANCELLED (Q3/F3), what the 67
-- CANCELLED rows with raw PAID, COMPLETED or CREATED mean (Y5), and how stable the provider
-- failure classes are (Y4). Needs the helper tables from 10_research_setup.sql.
-- Rates use the attempt grain. "Non-delivery" means failed or cancelled.

-- Wilson 95% interval for k events in n trials.
create or replace temp macro wilson_lo(k, n) as
    case when n = 0 then null else
        ((k + 1.96 * 1.96 / 2) / (n + 1.96 * 1.96)
         - 1.96 / (n + 1.96 * 1.96) * sqrt(k * (n - k) / n + 1.96 * 1.96 / 4)) end;
create or replace temp macro wilson_hi(k, n) as
    case when n = 0 then null else
        ((k + 1.96 * 1.96 / 2) / (n + 1.96 * 1.96)
         + 1.96 / (n + 1.96 * 1.96) * sqrt(k * (n - k) / n + 1.96 * 1.96 / 4)) end;
create or replace temp macro rate_class(pct) as
    case when pct < 1 then 'low' when pct < 3 then 'medium' else 'high' end;

-- One row per attempt, with its place in the payment's attempt chain and the payment context.
create or replace temp table att as
select a.*,
    epoch(a.disbursement_updated_at - a.disbursement_created_at) as dur_s,
    case when a.provider in ('PROVIDER 3', 'PROVIDER 8', 'PROVIDER 12') then a.provider else 'OTHER' end as provider_group,
    case
        when a.attempt_status = 'cancelled' and a.raw_status_lc in ('paid', 'completed', 'created') then 'y5_raw_paid_or_created'
        when a.attempt_status = 'cancelled' and a.status_lc = 'failed' then 'p3_failed_raw_cancelled'
        when a.attempt_status = 'cancelled' then 'plain_cancelled'
        else 'not_cancelled' end as cancel_kind,
    lead(a.provider) over w as next_provider,
    lead(a.attempt_status) over w as next_status,
    lead(a.attempt_at) over w as next_at,
    lead(a.beneficiary_id) over w as next_beneficiary_id,
    max((a.attempt_status = 'delivered')::int) over (partition by a.payment_id) as payment_has_delivered,
    max(a.attempt_number) over (partition by a.payment_id) as last_attempt_number,
    p.status as payment_status,
    p.has_chargeback,
    p.updated_at as payment_updated_at,
    sum((a.attempt_status = 'delivered')::int) over (partition by a.beneficiary_id order by a.attempt_at, a.receipt_id
        rows between unbounded preceding and 1 preceding) as beneficiary_prior_deliveries
from attempts a
join payments p on p.id = a.payment_id
window w as (partition by a.payment_id order by a.attempt_number);

create or replace temp table att_next as
select *,
    case when next_provider is null then 'none'
         when next_provider = provider then 'same_provider' else 'other_provider' end as next_kind
from att;

-- Q0 -----------------------------------------------------------------------------------------

.print ## Q0.1 Where status and raw_status differ, by provider
select provider, status, raw_status, count(*) as disbursements
from disbursements
where status_lc <> raw_status_lc
group by 1, 2, 3
order by 4 desc;

.print ## Q0.2 Provider 12, Provider 4 and Provider 8: status against raw_status for the paid, completed and created raw values
select provider, status, raw_status, count(*) as disbursements
from disbursements
where provider in ('PROVIDER 12', 'PROVIDER 4', 'PROVIDER 8') and raw_status in ('PAID', 'COMPLETED', 'CREATED')
group by 1, 2, 3
order by 1, 4 desc;

-- Q1 -----------------------------------------------------------------------------------------

.print ## Q1.1 Delivered, failed and cancelled attempts by provider and payout type
select provider, payout_type,
    count(*) filter (where attempt_status = 'delivered') as delivered,
    count(*) filter (where attempt_status = 'failed') as failed,
    count(*) filter (where attempt_status = 'cancelled') as cancelled,
    round(count(*) filter (where attempt_status = 'cancelled')
        / nullif(count(*) filter (where attempt_status = 'failed'), 0), 1) as cancelled_per_failed
from attempts
where provider is not null
group by 1, 2
having count(*) filter (where attempt_status in ('failed', 'cancelled')) > 0
order by 1, 2;

.print ## Q1.2 Share of attempts with a provider_status, by provider and attempt status
select provider, attempt_status, count(*) as attempts,
    round(100.0 * avg((provider_status is not null)::int), 1) as pct_with_provider_status
from attempts
where provider is not null and attempt_status in ('delivered', 'failed', 'cancelled')
group by 1, 2
order by 1, 2;

.print ## Q1.3 provider_status codes on failed and cancelled attempts (10 or more)
select provider, attempt_status, coalesce(provider_status, 'NULL') as provider_status, count(*) as attempts
from attempts
where attempt_status in ('failed', 'cancelled')
group by 1, 2, 3
having count(*) >= 10
order by 1, 2, 4 desc;

.print ## Q1.4 Time from disbursement creation to last update, by provider, payout type and status
select provider, payout_type, attempt_status, count(dur_s) as attempts,
    round(quantile_cont(dur_s, 0.10) / 60, 1) as p10_minutes,
    round(quantile_cont(dur_s, 0.50) / 60, 1) as p50_minutes,
    round(quantile_cont(dur_s, 0.90) / 60, 1) as p90_minutes,
    round(quantile_cont(dur_s, 0.99) / 86400, 2) as p99_days
from att
where attempt_status in ('delivered', 'failed', 'cancelled')
    and provider in ('PROVIDER 3', 'PROVIDER 4', 'PROVIDER 5', 'PROVIDER 7', 'PROVIDER 8', 'PROVIDER 11', 'PROVIDER 12')
    and payout_type in ('BANK', 'CASH', 'WALLET')
group by 1, 2, 3
having count(dur_s) >= 100
order by 1, 2, 3;

.print ## Q1.5 Share of failed and cancelled attempts by time to last update
with binned as (
    select provider_group || ' ' || payout_type || ' ' || attempt_status as grp,
        case when dur_s < 60 then 'a_under_1m' when dur_s < 300 then 'b_1_5m' when dur_s < 900 then 'c_5_15m'
            when dur_s < 3600 then 'd_15_60m' when dur_s < 10800 then 'e_1_3h' when dur_s < 43200 then 'f_3_12h'
            when dur_s < 86400 then 'g_12_24h' when dur_s < 259200 then 'h_1_3d' else 'i_3d_plus' end as bin
    from att
    where attempt_status in ('failed', 'cancelled') and dur_s is not null and payout_type in ('BANK', 'CASH')
),
shares as (
    select grp, bin, 100.0 * count(*) / sum(count(*)) over (partition by grp) as pct,
        sum(count(*)) over (partition by grp) as attempts
    from binned group by grp, bin
)
select * from (pivot shares on bin using round(first(pct), 1) group by grp, attempts) order by grp;

.print ## Q1.6 Cash attempts by whole days from creation to last update
select floor(dur_s / 86400)::int as days,
    count(*) filter (where attempt_status = 'cancelled' and provider = 'PROVIDER 8') as p8_cancelled,
    count(*) filter (where attempt_status = 'cancelled' and provider = 'PROVIDER 12') as p12_cancelled,
    count(*) filter (where attempt_status = 'cancelled' and provider = 'PROVIDER 7') as p7_cancelled,
    count(*) filter (where attempt_status = 'failed' and provider = 'PROVIDER 11'
        and provider_status = 'TRANSFER_REQUEST_HAS_EXPIRED') as p11_failed_expired_code,
    count(*) filter (where attempt_status = 'failed') as all_cash_failed,
    count(*) filter (where attempt_status = 'delivered') as all_cash_delivered
from att
where payout_type = 'CASH' and attempt_status in ('cancelled', 'failed', 'delivered') and dur_s is not null
    and dur_s < 46 * 86400
group by 1
order by 1;

.print ## Q1.7 Cancelled and failed rate by UTC hour of creation (3-hour buckets)
select provider, hour(disbursement_created_at) // 3 * 3 as utc_hour_from, count(*) as attempts,
    round(100.0 * avg((attempt_status = 'cancelled')::int), 2) as cancelled_pct,
    round(100.0 * avg((attempt_status = 'failed')::int), 2) as failed_pct
from att
where provider in ('PROVIDER 3', 'PROVIDER 8', 'PROVIDER 12')
    and attempt_status in ('delivered', 'failed', 'cancelled')
group by 1, 2
order by 1, 2;

.print ## Q1.8 Batch check: failed and cancelled attempts per minute of last update
with per_minute as (
    select provider, attempt_status, date_trunc('minute', disbursement_updated_at) as minute, count(*) as n
    from att
    where attempt_status in ('failed', 'cancelled') and disbursement_updated_at is not null
    group by 1, 2, 3
)
select provider, attempt_status, sum(n) as attempts, count(*) as distinct_minutes, max(n) as max_in_one_minute
from per_minute
group by 1, 2
having sum(n) >= 100
order by 1, 2;

.print ## Q1.9 What happens after a failed or cancelled attempt
select provider_group, attempt_status, count(*) as attempts,
    round(100.0 * avg((next_kind <> 'none')::int), 1) as pct_retried,
    round(100.0 * avg((next_kind = 'same_provider')::int), 1) as pct_same_provider,
    round(100.0 * avg((next_kind = 'other_provider')::int), 1) as pct_other_provider,
    round(100.0 * avg((next_status = 'delivered')::int), 1) as pct_next_delivered,
    round(100.0 * avg((next_kind <> 'none' and next_status = attempt_status)::int), 1) as pct_next_same_status,
    round(100.0 * avg(payment_has_delivered), 1) as pct_payment_delivered,
    round(100.0 * avg((payment_status = 'REFUNDED')::int), 1) as pct_payment_refunded
from att_next
where attempt_status in ('failed', 'cancelled') and provider is not null
group by 1, 2
order by 1, 2;

.print ## Q1.10 Retry timing and beneficiary change after a failed or cancelled attempt
select provider_group, attempt_status, count(*) as retried_attempts,
    round(quantile_cont(epoch(next_at - attempt_at) / 60, 0.10), 1) as p10_minutes_to_next,
    round(quantile_cont(epoch(next_at - attempt_at) / 60, 0.50), 1) as p50_minutes_to_next,
    round(quantile_cont(epoch(next_at - attempt_at) / 60, 0.90), 1) as p90_minutes_to_next,
    round(100.0 * avg((next_at < disbursement_updated_at)::int), 1) as pct_next_created_before_close,
    round(100.0 * avg((next_beneficiary_id <> beneficiary_id)::int), 1) as pct_beneficiary_changed
from att_next
where attempt_status in ('failed', 'cancelled') and next_kind <> 'none' and provider is not null
group by 1, 2
order by 1, 2;

.print ## Q1.11 Refund timing after the last attempt of a refunded payment
select provider_group, payout_type, attempt_status, count(*) as attempts,
    round(quantile_cont(epoch(payment_updated_at - disbursement_updated_at) / 3600, 0.10), 2) as p10_hours,
    round(quantile_cont(epoch(payment_updated_at - disbursement_updated_at) / 3600, 0.50), 2) as p50_hours,
    round(quantile_cont(epoch(payment_updated_at - disbursement_updated_at) / 3600, 0.90), 2) as p90_hours,
    round(100.0 * avg((payment_updated_at < disbursement_updated_at - interval 1 minute)::int), 1) as pct_refunded_before_close
from att_next
where attempt_status in ('failed', 'cancelled') and next_kind = 'none' and payment_status = 'REFUNDED'
    and provider is not null and payout_type in ('BANK', 'CASH', 'WALLET')
group by 1, 2, 3
having count(*) >= 50
order by 1, 2, 3;

.print ## Q1.12 Does the user send again after a non-delivered last attempt?
-- Last attempts of payments with no delivery, against a 10% deterministic sample of last delivered attempts.
create or replace temp table user_payments as
select p.id as payment_id, p.user_id, p.created_at, p.status, r.beneficiary_id
from payments p left join receipts r on r.payment_id = p.id;

create or replace temp table resend_base as
select receipt_id, payment_id, user_id, beneficiary_id,
    coalesce(disbursement_updated_at, attempt_at) as anchor,
    provider_group || ' ' ||
        case when attempt_status = 'delivered' then 'delivered (10% sample)'
             when cancel_kind = 'y5_raw_paid_or_created' then 'cancelled, status conflict'
             else attempt_status end as grp
from att
where provider is not null
    and ((attempt_status in ('failed', 'cancelled') and payment_has_delivered = 0 and attempt_number = last_attempt_number)
        or (attempt_status = 'delivered' and attempt_number = last_attempt_number and hash(receipt_id) % 10 = 0));

create or replace temp table resend as
select b.receipt_id,
    count(distinct case when u.created_at > b.anchor and u.created_at <= b.anchor + interval 7 day then u.payment_id end) as new_7d,
    count(distinct case when u.created_at > b.anchor and u.created_at <= b.anchor + interval 7 day
        and u.beneficiary_id = b.beneficiary_id then u.payment_id end) as same_beneficiary_7d,
    count(distinct case when u.created_at > b.anchor and u.created_at <= b.anchor + interval 30 day
        and u.beneficiary_id = b.beneficiary_id then u.payment_id end) as same_beneficiary_30d
from resend_base b
left join user_payments u on u.user_id = b.user_id and u.payment_id <> b.payment_id and u.created_at > b.anchor
group by 1;

select grp, count(*) as attempts,
    round(100.0 * avg((new_7d > 0)::int), 1) as pct_new_payment_7d,
    round(100.0 * avg((same_beneficiary_7d > 0)::int), 1) as pct_same_beneficiary_7d,
    round(100.0 * avg((same_beneficiary_30d > 0)::int), 1) as pct_same_beneficiary_30d
from resend_base join resend using (receipt_id)
group by 1
having count(*) >= 20
order by 1;

.print ## Q1.13 Monthly share of attempts that are cancelled or failed (UTC month of the receipt)
select provider, strftime(date_trunc('month', attempt_at), '%Y-%m') as month, count(*) as attempts,
    round(100.0 * avg((attempt_status = 'cancelled')::int), 2) as cancelled_pct,
    round(100.0 * avg((attempt_status = 'failed')::int), 2) as failed_pct,
    round(100.0 * avg((attempt_status in ('cancelled', 'failed'))::int), 2) as non_delivery_pct
from att
where provider in ('PROVIDER 3', 'PROVIDER 8', 'PROVIDER 12') and attempt_status in ('delivered', 'failed', 'cancelled')
group by 1, 2
order by 1, 2;

.print ## Q1.14 Provider 12 by week: cancelled and failed labels and provider_status coverage
select date_trunc('week', attempt_at)::date as week, count(*) as attempts,
    count(*) filter (where attempt_status = 'cancelled') as cancelled,
    count(*) filter (where attempt_status = 'failed' and provider_status is null) as failed_no_provider_status,
    count(*) filter (where attempt_status = 'failed' and provider_status is not null) as failed_with_provider_status,
    round(100.0 * avg((attempt_status in ('cancelled', 'failed'))::int), 2) as non_delivery_pct,
    round(100.0 * avg((provider_status is not null)::int), 1) as pct_any_provider_status
from att
where provider = 'PROVIDER 12' and attempt_at >= '2026-06-01'
group by 1
order by 1;

.print ## Q1.15 Provider 12 non-delivery before and after the labelling change
-- Before: created before the first provider_status (2026-07-11). After: from 2026-08-17, with no cancelled rows.
create or replace temp table p12_era as
select *, case when attempt_at < '2026-07-11' then '1_before' when attempt_at >= '2026-08-17' then '3_after' else '2_transition' end as era
from att
where provider = 'PROVIDER 12' and attempt_status in ('delivered', 'failed', 'cancelled') and payout_type in ('BANK', 'CASH');

select era, payout_type, attempt_status, count(*) as attempts,
    round(quantile_cont(dur_s / 60, 0.10), 1) as p10_minutes,
    round(quantile_cont(dur_s / 60, 0.50), 1) as p50_minutes,
    round(quantile_cont(dur_s / 60, 0.90), 1) as p90_minutes,
    round(100.0 * avg((dur_s < 10)::int), 1) as pct_under_10s
from p12_era
where attempt_status in ('failed', 'cancelled')
group by 1, 2, 3
order by 2, 1, 3;

.print ## Q1.16 Provider 12 non-delivery rate by amount band and beneficiary history, before and after
select era, 'amount ' || case when amount_charged < 250 then '1_under_250' when amount_charged < 1000 then '2_250_1000'
        when amount_charged < 2000 then '3_1000_2000' else '4_2000_plus' end as segment,
    count(*) as attempts,
    round(100.0 * avg((attempt_status = 'cancelled')::int), 2) as cancelled_pct,
    round(100.0 * avg((attempt_status = 'failed')::int), 2) as failed_pct,
    round(100.0 * avg((attempt_status <> 'delivered')::int), 2) as non_delivery_pct
from p12_era where era <> '2_transition' group by 1, 2
union all
select era, 'beneficiary ' || case when beneficiary_prior_deliveries > 0 then 'with_prior_delivery' else 'no_prior_delivery' end,
    count(*), round(100.0 * avg((attempt_status = 'cancelled')::int), 2), round(100.0 * avg((attempt_status = 'failed')::int), 2),
    round(100.0 * avg((attempt_status <> 'delivered')::int), 2)
from p12_era where era <> '2_transition' group by 1, 2
order by 1, 2;

.print ## Q1.17 Cancelled and failed rate by charged amount band (before 2026-07-11)
select provider, case when amount_charged < 250 then '1_under_250' when amount_charged < 1000 then '2_250_1000'
        when amount_charged < 1500 then '3_1000_1500' when amount_charged < 2000 then '4_1500_2000'
        when amount_charged < 2750 then '5_2000_2750' else '6_2750_plus' end as amount_usd,
    count(*) as attempts,
    round(100.0 * avg((attempt_status = 'cancelled')::int), 2) as cancelled_pct,
    round(100.0 * avg((attempt_status = 'failed')::int), 2) as failed_pct
from att
where provider in ('PROVIDER 3', 'PROVIDER 8', 'PROVIDER 12') and attempt_status in ('delivered', 'failed', 'cancelled')
    and attempt_at < '2026-07-11' and amount_charged >= 0
group by 1, 2
order by 1, 2;

.print ## Q1.18 Same check in local currency: MXN disbursement amount bands (before 2026-07-11)
-- Independent of receipts.amount_charged. Status comes from disbursements only.
select provider, case when amount < 1000 then '1_under_1k' when amount < 5000 then '2_1k_5k' when amount < 10000 then '3_5k_10k'
        when amount < 20000 then '4_10k_20k' when amount < 40000 then '5_20k_40k' else '6_40k_plus' end as amount_mxn,
    count(*) as disbursements,
    round(100.0 * avg((raw_status_lc = 'cancelled' or status_lc = 'cancelled')::int), 2) as cancelled_pct,
    round(100.0 * avg((status_lc in ('failed', 'rejected') and raw_status_lc <> 'cancelled')::int), 2) as failed_pct
from disbursements
where provider in ('PROVIDER 3', 'PROVIDER 8', 'PROVIDER 12') and destination_currency = 'MXN'
    and created_at < '2026-07-11' and amount is not null
group by 1, 2
order by 1, 2;

.print ## Q1.19 Cancelled and failed rate by beneficiary history (before 2026-07-11)
select provider, case when beneficiary_prior_deliveries > 0 then 'with_prior_delivery' else 'no_prior_delivery' end as beneficiary,
    count(*) as attempts,
    round(100.0 * avg((attempt_status = 'cancelled')::int), 2) as cancelled_pct,
    round(100.0 * avg((attempt_status = 'failed')::int), 2) as failed_pct
from att
where provider in ('PROVIDER 3', 'PROVIDER 8', 'PROVIDER 12') and attempt_status in ('delivered', 'failed', 'cancelled')
    and attempt_at < '2026-07-11'
group by 1, 2
order by 1, 2;

.print ## Q1.20 What follows cancelled and failed attempts of USD 1,000 or more
select provider, attempt_status, case when amount_charged >= 1000 then '1000_plus' else 'under_1000' end as amount_usd,
    count(*) as attempts,
    round(100.0 * avg((next_kind = 'none')::int), 1) as pct_no_retry,
    round(100.0 * avg(payment_has_delivered), 1) as pct_payment_delivered,
    round(100.0 * avg((payment_status = 'REFUNDED')::int), 1) as pct_payment_refunded,
    round(quantile_cont(dur_s / 60, 0.5), 0) as p50_minutes_to_close
from att_next
where provider in ('PROVIDER 3', 'PROVIDER 8', 'PROVIDER 12') and attempt_status in ('failed', 'cancelled')
group by 1, 2, 3
order by 1, 2, 3;

.print ## Q1.21 Same country and payout type, different providers (2026-05-01 to 2026-07-10)
select country, payout_type, provider, count(*) as attempts,
    round(100.0 * avg((attempt_status = 'cancelled')::int), 2) as cancelled_pct,
    round(100.0 * avg((attempt_status = 'failed')::int), 2) as failed_pct,
    round(100.0 * avg((attempt_status in ('cancelled', 'failed'))::int), 2) as non_delivery_pct
from att
where attempt_status in ('delivered', 'failed', 'cancelled') and attempt_at >= '2026-05-01' and attempt_at < '2026-07-11'
    and (country, payout_type) in (('MX', 'BANK'), ('MX', 'CASH'), ('GT', 'CASH'), ('GT', 'BANK'))
group by 1, 2, 3
having count(*) >= 1000
order by 1, 2, 5 desc;

.print ## Q1.22 Provider 3 raw cancelled against Provider 3 failed
select case when raw_status_lc = 'cancelled' then 'cancelled (status Failed, raw cancelled)' else 'failed' end as p3_group,
    count(*) as attempts,
    round(100.0 * avg((dur_s < 60)::int), 1) as pct_under_1m,
    round(100.0 * avg((dur_s < 300)::int), 1) as pct_under_5m,
    round(100.0 * avg((hour(disbursement_created_at) < 3)::int), 1) as pct_created_00_03_utc,
    round(100.0 * avg((next_kind <> 'none')::int), 1) as pct_retried,
    round(100.0 * avg((next_kind = 'other_provider')::int), 1) as pct_retried_on_other_provider,
    round(100.0 * avg((next_beneficiary_id <> beneficiary_id)::int) filter (where next_kind <> 'none'), 1) as pct_beneficiary_changed_on_retry,
    round(100.0 * avg(payment_has_delivered), 1) as pct_payment_delivered,
    round(100.0 * avg((payment_status = 'REFUNDED')::int), 1) as pct_payment_refunded
from att_next
where provider = 'PROVIDER 3' and attempt_status in ('failed', 'cancelled')
group by 1
order by 1;

.print ## Q1.23 Rule-based classes of cancelled attempts (first matching rule)
-- Rules use only observable features. They separate what the data can separate, nothing more.
-- Expiry windows are the day spikes in Q1.6: Provider 8 from 29 to 31 days, Provider 12 from 23 to 27 days.
select provider,
    case
        when cancel_kind = 'y5_raw_paid_or_created' then '1_status_conflict'
        when dur_s is null then '6_no_updated_at'
        when dur_s < 300 then '2_instant_under_5m'
        when payout_type = 'CASH' and ((provider = 'PROVIDER 8' and dur_s / 86400 >= 29 and dur_s / 86400 < 31)
            or (provider = 'PROVIDER 12' and dur_s / 86400 >= 23 and dur_s / 86400 < 27)) then '3_expiry_like_cash'
        when payment_status = 'REFUNDED' and payment_updated_at < disbursement_updated_at - interval 1 minute then '4_refund_before_close'
        else '5_async_origin_unknown' end as class,
    count(*) as attempts
from att
where attempt_status = 'cancelled'
group by 1, 2
order by 1, 2;

.print ## Q1.24 Expiry-spike excess over the neighbouring days
-- Background is the mean per day in the 4 days on each side of the spike window, within 3 to 40 days.
with daily as (
    select provider, floor(dur_s / 86400)::int as day, count(*) as n
    from att where attempt_status = 'cancelled' and payout_type = 'CASH' and provider in ('PROVIDER 8', 'PROVIDER 12')
        and dur_s is not null group by 1, 2
),
win as (select 'PROVIDER 8' as provider, 29 as lo, 30 as hi union all select 'PROVIDER 12', 23, 26)
select w.provider, w.lo || '-' || w.hi as spike_days,
    sum(d.n) filter (where d.day between w.lo and w.hi) as in_window,
    round(avg(d.n) filter (where d.day between w.lo - 4 and w.lo - 1 or d.day between w.hi + 1 and w.hi + 4), 1) as background_per_day,
    round(sum(d.n) filter (where d.day between w.lo and w.hi)
        - (w.hi - w.lo + 1) * avg(d.n) filter (where d.day between w.lo - 4 and w.lo - 1 or d.day between w.hi + 1 and w.hi + 4), 0) as excess,
    (select count(*) from att a where a.provider = w.provider and a.attempt_status = 'cancelled' and a.payout_type = 'CASH') as cash_cancelled
from win w join daily d using (provider)
group by w.provider, w.lo, w.hi
order by 1;

.print ## Q1.25 Cancellations above the rate seen under USD 1,000 (before 2026-07-11)
-- Excess = cancelled attempts of USD 1,000 or more minus what the under-1,000 rate would give.
-- It sizes the amount-linked part only. It does not say who cancelled.
with rates as (
    select provider,
        count(*) filter (where amount_charged < 1000) as n_low,
        count(*) filter (where amount_charged < 1000 and attempt_status = 'cancelled') as c_low,
        count(*) filter (where amount_charged >= 1000) as n_high,
        count(*) filter (where amount_charged >= 1000 and attempt_status = 'cancelled') as c_high,
        count(*) filter (where attempt_status = 'cancelled') as c_all
    from att
    where provider in ('PROVIDER 3', 'PROVIDER 8', 'PROVIDER 12') and attempt_status in ('delivered', 'failed', 'cancelled')
        and attempt_at < '2026-07-11' and amount_charged >= 0
    group by 1
)
select provider, n_high as attempts_1000_plus, c_high as cancelled_1000_plus,
    round(100.0 * c_low / n_low, 2) as cancelled_pct_under_1000,
    round(100.0 * c_high / n_high, 2) as cancelled_pct_1000_plus,
    round(c_high - n_high * c_low * 1.0 / n_low, 0) as excess_cancelled,
    round(100.0 * (c_high - n_high * c_low * 1.0 / n_low) / c_all, 1) as excess_pct_of_provider_cancellations
from rates
order by 1;

-- Q2 (Y5) ------------------------------------------------------------------------------------

.print ## Q2.1 CANCELLED rows with raw PAID, COMPLETED or CREATED
select provider, raw_status, payout_type, count(*) as rows_, min(attempt_at)::date as first_day, max(attempt_at)::date as last_day,
    round(quantile_cont(dur_s / 60, 0.5), 1) as p50_minutes_to_close, round(max(dur_s / 60), 1) as max_minutes_to_close
from att
where cancel_kind = 'y5_raw_paid_or_created'
group by 1, 2, 3
order by 1, 2, 3;

.print ## Q2.2 The 67 rows by other deliveries on the payment and payment status
select provider, raw_status,
    case when payment_has_delivered = 1 then 'another attempt delivered' else 'no delivered attempt' end as other_delivery,
    payment_status, count(*) as rows_, sum(has_chargeback::int) as chargebacks, round(sum(amount_charged), 2) as amount_charged_usd
from att
where cancel_kind = 'y5_raw_paid_or_created'
group by 1, 2, 3, 4
order by 1, 2, 3, 4;

.print ## Q2.3 Payment status of the last attempt, by kind of non-delivered attempt
-- Last attempts of payments with no delivered attempt, so the money only moved if this row paid out.
select case when cancel_kind = 'y5_raw_paid_or_created' then 'cancelled, status conflict'
        when attempt_status = 'cancelled' then 'cancelled, plain' else 'failed' end as attempt_kind,
    count(*) as attempts,
    sum((payment_status = 'SUCCESSFUL')::int) as payment_successful,
    sum((payment_status = 'REFUNDED')::int) as payment_refunded,
    sum((payment_status not in ('SUCCESSFUL', 'REFUNDED'))::int) as payment_other,
    round(100.0 * avg((payment_status = 'SUCCESSFUL')::int), 1) as pct_not_refunded,
    sum(has_chargeback::int) as chargebacks
from att
where attempt_status in ('failed', 'cancelled') and payment_has_delivered = 0 and attempt_number = last_attempt_number
group by 1
order by 1;

.print ## Q2.4 Provider 12: time to close and payment update relative to disbursement update
select payout_type,
    case when cancel_kind = 'y5_raw_paid_or_created' then 'cancelled, raw PAID'
         when attempt_status = 'cancelled' then 'cancelled, plain' else 'delivered' end as attempt_kind,
    payment_status, count(*) as attempts,
    round(quantile_cont(dur_s / 60, 0.10), 1) as p10_minutes_to_close,
    round(quantile_cont(dur_s / 60, 0.50), 1) as p50_minutes_to_close,
    round(quantile_cont(dur_s / 60, 0.90), 1) as p90_minutes_to_close,
    round(quantile_cont(epoch(payment_updated_at - disbursement_updated_at) / 3600, 0.50), 2) as p50_hours_payment_update_minus_disbursement_update
from att
where provider = 'PROVIDER 12' and payout_type in ('BANK', 'CASH')
    and attempt_status in ('cancelled', 'delivered') and attempt_number = last_attempt_number and payment_has_delivered = (attempt_status = 'delivered')::int
group by 1, 2, 3
having count(*) >= 4
order by 1, 2, 3;

.print ## Q2.5 Provider 4 COMPLETED then CANCELLED: the 2026-01-22 cluster
select count(*) as rows_, min(attempt_at) as first_attempt, max(attempt_at) as last_attempt,
    round(quantile_cont(dur_s, 0.5), 0) as p50_seconds_to_close,
    count(*) filter (where next_kind = 'other_provider' and next_provider = 'PROVIDER 3' and next_status = 'delivered') as rerouted_to_p3_and_delivered,
    round(quantile_cont(epoch(next_at - disbursement_updated_at), 0.5), 1) as p50_seconds_close_to_next_attempt,
    max(epoch(next_at - disbursement_updated_at)) as max_seconds_close_to_next_attempt,
    (select count(*) from att where provider = 'PROVIDER 4' and attempt_status = 'delivered' and payout_type = 'BANK'
        and attempt_at >= '2026-01-22 13:00' and attempt_at < '2026-01-22 16:00') as p4_bank_delivered_same_window
from att_next
where provider = 'PROVIDER 4' and cancel_kind = 'y5_raw_paid_or_created';

.print ## Q2.6 Days with 3 or more status-conflict rows
select attempt_at::date as day, count(*) as rows_, string_agg(distinct provider || ' ' || raw_status, ', ') as providers_and_raw_status
from att
where cancel_kind = 'y5_raw_paid_or_created'
group by 1
having count(*) >= 3
order by 1;

.print ## Q2.7 Metric effect of treating the status-conflict rows as delivered
-- Payments that would move into delivered volume: SUCCESSFUL, no other delivered attempt, and a conflict row as last attempt.
select count(*) as payments, round(sum(p.amount), 2) as customer_paid_usd,
    round(100.0 * count(*) / (select count(*) from remittances where is_delivered_remittance), 4) as pct_of_delivered_remittances,
    round(100.0 * sum(p.amount) / (select sum(amount) from remittances where is_delivered_remittance), 4) as pct_of_delivered_usd
from att a join payments p on p.id = a.payment_id
where a.cancel_kind = 'y5_raw_paid_or_created' and a.payment_has_delivered = 0 and a.payment_status = 'SUCCESSFUL';

-- Q3 (Y4) ------------------------------------------------------------------------------------

create or replace temp table provider_counts as
select provider,
    count(*) as attempts,
    count(*) filter (where attempt_status = 'delivered') as delivered,
    count(*) filter (where attempt_status = 'failed') as failed,
    count(*) filter (where attempt_status = 'cancelled') as cancelled,
    count(*) filter (where cancel_kind = 'p3_failed_raw_cancelled') as p3_raw_cancelled,
    count(*) filter (where cancel_kind = 'y5_raw_paid_or_created') as y5_conflict,
    -- failed attempts whose provider_status says the provider cancelled or expired the transfer
    count(*) filter (where attempt_status = 'failed'
        and (provider_status ilike '%cancel%' or provider_status ilike '%expired%')) as failed_with_cancel_code
from att
where provider is not null
group by 1;

.print ## Q3.1 Failed rate with Wilson 95% intervals, and rates under other readings of cancellations
select provider, attempts, delivered, failed, cancelled,
    round(100.0 * failed / (delivered + failed), 2) as failed_pct,
    round(100 * wilson_lo(failed, delivered + failed), 2) as failed_lo,
    round(100 * wilson_hi(failed, delivered + failed), 2) as failed_hi,
    case when attempts < 1000 then 'insufficient_volume' else rate_class(100.0 * failed / (delivered + failed)) end as class_as_written,
    case when attempts >= 1000 and wilson_lo(failed, delivered + failed) < 0.01 and wilson_hi(failed, delivered + failed) > 0.01 then 'straddles 1%'
         when attempts >= 1000 and wilson_lo(failed, delivered + failed) < 0.03 and wilson_hi(failed, delivered + failed) > 0.03 then 'straddles 3%'
         else '' end as interval_vs_threshold,
    round(100.0 * (failed + cancelled) / (delivered + failed + cancelled), 2) as failed_or_cancelled_pct,
    round(100 * wilson_lo(failed + cancelled, delivered + failed + cancelled), 2) as fc_lo,
    round(100 * wilson_hi(failed + cancelled, delivered + failed + cancelled), 2) as fc_hi,
    case when attempts < 1000 then 'insufficient_volume' else rate_class(100.0 * (failed + cancelled) / (delivered + failed + cancelled)) end as class_failed_or_cancelled
from provider_counts
order by attempts desc;

.print ## Q3.2 Failed rate by provider and month (UTC month of the receipt)
select provider, strftime(date_trunc('month', attempt_at), '%Y-%m') as month,
    count(*) filter (where attempt_status in ('delivered', 'failed')) as terminal_attempts,
    count(*) filter (where attempt_status = 'failed') as failed,
    round(100.0 * count(*) filter (where attempt_status = 'failed') / count(*) filter (where attempt_status in ('delivered', 'failed')), 2) as failed_pct,
    round(100 * wilson_lo(count(*) filter (where attempt_status = 'failed'), count(*) filter (where attempt_status in ('delivered', 'failed'))), 2) as lo,
    round(100 * wilson_hi(count(*) filter (where attempt_status = 'failed'), count(*) filter (where attempt_status in ('delivered', 'failed'))), 2) as hi,
    rate_class(100.0 * count(*) filter (where attempt_status = 'failed') / count(*) filter (where attempt_status in ('delivered', 'failed'))) as class_failed,
    round(100.0 * count(*) filter (where attempt_status in ('failed', 'cancelled')) / count(*) filter (where attempt_status in ('delivered', 'failed', 'cancelled')), 2) as failed_or_cancelled_pct,
    rate_class(100.0 * count(*) filter (where attempt_status in ('failed', 'cancelled')) / count(*) filter (where attempt_status in ('delivered', 'failed', 'cancelled'))) as class_failed_or_cancelled
from att
where provider in (select provider from provider_counts where attempts >= 1000)
group by 1, 2
having count(*) filter (where attempt_status in ('delivered', 'failed')) >= 100
order by 1, 2;

.print ## Q3.3 Class stability across months with 1,000 or more terminal attempts
with monthly as (
    select provider, date_trunc('month', attempt_at) as month,
        count(*) filter (where attempt_status in ('delivered', 'failed')) as n,
        100.0 * count(*) filter (where attempt_status = 'failed') / count(*) filter (where attempt_status in ('delivered', 'failed')) as failed_pct,
        100.0 * count(*) filter (where attempt_status in ('failed', 'cancelled')) / count(*) filter (where attempt_status in ('delivered', 'failed', 'cancelled')) as fc_pct
    from att where provider is not null group by 1, 2
    having count(*) filter (where attempt_status in ('delivered', 'failed')) >= 1000
)
select provider, count(*) as months,
    round(min(failed_pct), 2) as min_failed_pct, round(max(failed_pct), 2) as max_failed_pct,
    count(distinct rate_class(failed_pct)) as distinct_classes_failed,
    string_agg(substr(rate_class(failed_pct), 1, 1), '' order by month) as class_sequence_failed,
    round(min(fc_pct), 2) as min_fc_pct, round(max(fc_pct), 2) as max_fc_pct,
    count(distinct rate_class(fc_pct)) as distinct_classes_fc,
    string_agg(substr(rate_class(fc_pct), 1, 1), '' order by month) as class_sequence_fc
from monthly
group by 1
order by 1;

.print ## Q3.4 Recent period: attempts created from 2026-07-01
select provider,
    count(*) filter (where attempt_status in ('delivered', 'failed')) as terminal_attempts,
    round(100.0 * count(*) filter (where attempt_status = 'failed') / count(*) filter (where attempt_status in ('delivered', 'failed')), 2) as failed_pct,
    round(100 * wilson_lo(count(*) filter (where attempt_status = 'failed'), count(*) filter (where attempt_status in ('delivered', 'failed'))), 2) as lo,
    round(100 * wilson_hi(count(*) filter (where attempt_status = 'failed'), count(*) filter (where attempt_status in ('delivered', 'failed'))), 2) as hi,
    rate_class(100.0 * count(*) filter (where attempt_status = 'failed') / count(*) filter (where attempt_status in ('delivered', 'failed'))) as class_failed,
    case when wilson_lo(count(*) filter (where attempt_status = 'failed'), count(*) filter (where attempt_status in ('delivered', 'failed'))) < 0.01
            and wilson_hi(count(*) filter (where attempt_status = 'failed'), count(*) filter (where attempt_status in ('delivered', 'failed'))) > 0.01 then 'straddles 1%'
         when wilson_lo(count(*) filter (where attempt_status = 'failed'), count(*) filter (where attempt_status in ('delivered', 'failed'))) < 0.03
            and wilson_hi(count(*) filter (where attempt_status = 'failed'), count(*) filter (where attempt_status in ('delivered', 'failed'))) > 0.03 then 'straddles 3%'
         else '' end as interval_vs_threshold,
    round(100.0 * count(*) filter (where attempt_status in ('failed', 'cancelled')) / count(*) filter (where attempt_status in ('delivered', 'failed', 'cancelled')), 2) as failed_or_cancelled_pct
from att
where attempt_at >= '2026-07-01' and provider in (select provider from provider_counts where attempts >= 1000)
group by 1
order by failed_pct;

.print ## Q3.5 Rates by provider and payout type
select provider, payout_type, count(*) filter (where attempt_status in ('delivered', 'failed')) as terminal_attempts,
    round(100.0 * count(*) filter (where attempt_status = 'failed') / count(*) filter (where attempt_status in ('delivered', 'failed')), 2) as failed_pct,
    round(100.0 * count(*) filter (where attempt_status in ('failed', 'cancelled')) / count(*) filter (where attempt_status in ('delivered', 'failed', 'cancelled')), 2) as failed_or_cancelled_pct
from att
where provider in (select provider from provider_counts where attempts >= 1000) and payout_type in ('BANK', 'CASH', 'WALLET')
group by 1, 2
having count(*) filter (where attempt_status in ('delivered', 'failed')) >= 1000
order by 1, 2;

.print ## Q3.6 Direct standardization by country and payout type
-- Standard population: terminal attempts of all providers in each country and payout type cell.
-- A provider uses only the cells where it has 500 or more attempts, with standard weights renormalised over those cells.
-- Coverage is the share of the standard population those cells hold. Low coverage means the figure is not comparable.
create or replace temp table cells as
select provider, country, payout_type,
    count(*) filter (where attempt_status in ('delivered', 'failed')) as n,
    count(*) filter (where attempt_status = 'failed') as f,
    count(*) filter (where attempt_status in ('delivered', 'failed', 'cancelled')) as n2,
    count(*) filter (where attempt_status in ('failed', 'cancelled')) as f2
from att
where provider is not null and country is not null and payout_type in ('BANK', 'CASH', 'WALLET')
group by 1, 2, 3;

create or replace temp table std_weights as
select country, payout_type, sum(n) as w, sum(n2) as w2 from cells group by 1, 2;

with joined as (
    select c.*, s.w, s.w2 from cells c join std_weights s using (country, payout_type) where c.n >= 500
),
std as (
    select provider, sum(n) as terminal_attempts,
        100.0 * sum(f) / sum(n) as crude_pct,
        100.0 * sum(w * f * 1.0 / n) / sum(w) as std_pct,
        100.0 * sum(w) / (select sum(w) from std_weights) as coverage_pct,
        100.0 * sum(f2) / sum(n2) as crude_fc_pct,
        100.0 * sum(w2 * f2 * 1.0 / n2) / sum(w2) as std_fc_pct
    from joined group by 1 having sum(n) >= 1000
)
select provider, terminal_attempts, round(crude_pct, 2) as crude_failed_pct, round(std_pct, 2) as standardized_failed_pct,
    rate_class(crude_pct) as crude_class, rate_class(std_pct) as standardized_class,
    rank() over (order by crude_pct) as crude_rank, rank() over (order by std_pct) as standardized_rank,
    round(coverage_pct, 1) as coverage_pct,
    round(crude_fc_pct, 2) as crude_fc_pct, round(std_fc_pct, 2) as standardized_fc_pct,
    rank() over (order by crude_fc_pct) as crude_fc_rank, rank() over (order by std_fc_pct) as standardized_fc_rank
from std
order by crude_pct;

.print ## Q3.7 First observed attempt against retries, with Wilson intervals
select provider, case when attempt_number = 1 then 'first' else 'retry' end as position,
    count(*) filter (where attempt_status in ('delivered', 'failed')) as terminal_attempts,
    count(*) filter (where attempt_status = 'failed') as failed,
    round(100.0 * count(*) filter (where attempt_status = 'failed') / count(*) filter (where attempt_status in ('delivered', 'failed')), 2) as failed_pct,
    round(100 * wilson_lo(count(*) filter (where attempt_status = 'failed'), count(*) filter (where attempt_status in ('delivered', 'failed'))), 2) as lo,
    round(100 * wilson_hi(count(*) filter (where attempt_status = 'failed'), count(*) filter (where attempt_status in ('delivered', 'failed'))), 2) as hi,
    round(100.0 * count(*) filter (where attempt_status in ('failed', 'cancelled')) / count(*) filter (where attempt_status in ('delivered', 'failed', 'cancelled')), 2) as failed_or_cancelled_pct
from att
where provider in (select provider from provider_counts where attempts >= 1000)
group by provider, 2, attempt_number > 1
order by 1, 2 desc;

.print ## Q3.8 Natural breaks: gaps between neighbouring providers (1,000 or more attempts)
with ranked as (
    select provider, 100.0 * failed / (delivered + failed) as failed_pct,
        100.0 * (failed + cancelled) / (delivered + failed + cancelled) as fc_pct
    from provider_counts where attempts >= 1000
),
f as (select provider, failed_pct as pct, lag(failed_pct) over (order by failed_pct) as prev_pct from ranked),
c as (select provider, fc_pct as pct, lag(fc_pct) over (order by fc_pct) as prev_pct from ranked)
select 'failed' as measure, provider, round(pct, 2) as rate_pct, round(pct - prev_pct, 2) as gap_pp, round(pct / prev_pct, 2) as ratio_to_previous
from f
union all
select 'failed_or_cancelled', provider, round(pct, 2), round(pct - prev_pct, 2), round(pct / prev_pct, 2) from c
order by 1 desc, 3;

.print ## Q3.9 Precision at the thresholds, and provider-months under 1,000 terminal attempts
with grid as (select unnest([100, 300, 1000, 3000, 10000, 30000]) as n),
cases as (select unnest([0.01, 0.03]) as p)
select n as attempts, p as true_rate,
    round(100 * wilson_lo(p * n, n), 2) as lo_pct, round(100 * wilson_hi(p * n, n), 2) as hi_pct,
    round(100 * (wilson_hi(p * n, n) - wilson_lo(p * n, n)) / 2, 2) as half_width_pp
from grid, cases
order by p, n;

with monthly as (
    select provider, date_trunc('month', attempt_at) as month,
        count(*) filter (where attempt_status in ('delivered', 'failed')) as n
    from att where provider in (select provider from provider_counts where attempts >= 1000) group by 1, 2
)
select count(*) as provider_months, count(*) filter (where n < 1000) as under_1000,
    count(*) filter (where n < 300) as under_300,
    string_agg(distinct provider, ', ') filter (where n < 1000) as providers_with_short_months
from monthly;

.print ## Q3.10 Failed rate and class under alternative readings of cancellations
-- as_written: cancellations excluded. p3_cancel_as_failed: Provider 3 raw cancelled counted as failed
-- (its own status says Failed). all_cancel_as_failed: every cancellation counted as failed.
-- cancel_codes_excluded: failed attempts whose provider_status says the provider cancelled or expired
-- the transfer (Providers 11 and 6) are dropped, which treats them like Providers 8 and 12 cancellations.
-- y5_as_delivered_in_all_cancel: all_cancel_as_failed with the status-conflict rows counted as delivered.
select provider, attempts,
    round(100.0 * failed / (delivered + failed), 2) as as_written,
    round(100.0 * (failed + p3_raw_cancelled) / (delivered + failed + p3_raw_cancelled), 2) as p3_cancel_as_failed,
    round(100.0 * (failed + cancelled) / (delivered + failed + cancelled), 2) as all_cancel_as_failed,
    round(100.0 * (failed - failed_with_cancel_code) / (delivered + failed - failed_with_cancel_code), 2) as cancel_codes_excluded,
    round(100.0 * (failed + cancelled - y5_conflict) / (delivered + y5_conflict + failed + cancelled - y5_conflict), 2) as y5_as_delivered_in_all_cancel,
    case when attempts < 1000 then 'insufficient_volume' else rate_class(100.0 * failed / (delivered + failed)) end as class_as_written,
    case when attempts < 1000 then 'insufficient_volume' else rate_class(100.0 * (failed + p3_raw_cancelled) / (delivered + failed + p3_raw_cancelled)) end as class_p3_cancel_as_failed,
    case when attempts < 1000 then 'insufficient_volume' else rate_class(100.0 * (failed + cancelled) / (delivered + failed + cancelled)) end as class_all_cancel_as_failed,
    case when attempts < 1000 then 'insufficient_volume' else rate_class(100.0 * (failed - failed_with_cancel_code) / (delivered + failed - failed_with_cancel_code)) end as class_cancel_codes_excluded
from provider_counts
order by attempts desc;

.print ## Q3.11 Failed attempts whose provider_status says cancelled or expired
select provider, provider_status, payout_type, count(*) as attempts,
    round(quantile_cont(dur_s / 3600, 0.5), 1) as p50_hours_to_close
from att
where attempt_status = 'failed' and (provider_status ilike '%cancel%' or provider_status ilike '%expired%')
group by 1, 2, 3
order by 1, 4 desc;

-- Q4 Cross-checks -----------------------------------------------------------------------------
-- These use the raw text tables only, without the attempts helper table.

.print ## Q4.1 Raw-table checks of the headline counts
select 'Provider 12 rows cancelled (status or raw), created before 2026-07-11' as check_, count(*) as value_
from raw_disbursements where disbursement_provider = 'PROVIDER 12' and (lower(status) = 'cancelled' or lower(raw_status) = 'cancelled') and created_at < '2026-07-11'
union all
select 'Provider 12 rows cancelled (status or raw), created from 2026-08-17', count(*)
from raw_disbursements where disbursement_provider = 'PROVIDER 12' and (lower(status) = 'cancelled' or lower(raw_status) = 'cancelled') and created_at >= '2026-08-17'
union all
select 'Provider 3 rows with raw cancelled', count(*) from raw_disbursements where disbursement_provider = 'PROVIDER 3' and lower(raw_status) = 'cancelled'
union all
select 'Provider 3 raw cancelled closed within 60 seconds', count(*)
from raw_disbursements where disbursement_provider = 'PROVIDER 3' and lower(raw_status) = 'cancelled'
    and epoch(cast(updated_at as timestamptz) - cast(created_at as timestamptz)) < 60
union all
select 'Provider 8 rows failed', count(*) from raw_disbursements where disbursement_provider = 'PROVIDER 8' and lower(status) = 'failed'
union all
select 'Provider 8 rows failed, closed within 60 seconds', count(*)
from raw_disbursements where disbursement_provider = 'PROVIDER 8' and lower(status) = 'failed'
    and epoch(cast(updated_at as timestamptz) - cast(created_at as timestamptz)) < 60
union all
select 'Provider 8 rows cancelled (status and raw), closed within 60 seconds', count(*)
from raw_disbursements where disbursement_provider = 'PROVIDER 8' and lower(status) = 'cancelled' and lower(raw_status) = 'cancelled'
    and epoch(cast(updated_at as timestamptz) - cast(created_at as timestamptz)) < 60
union all
select 'Provider 8 rows cancelled (status and raw)', count(*)
from raw_disbursements where disbursement_provider = 'PROVIDER 8' and lower(status) = 'cancelled' and lower(raw_status) = 'cancelled'
union all
select 'CANCELLED rows with raw PAID or COMPLETED', count(*) from raw_disbursements where status = 'CANCELLED' and raw_status in ('PAID', 'COMPLETED')
union all
select 'Those rows on a SUCCESSFUL payment with no other delivered attempt', count(*)
from raw_disbursements d
join raw_receipts r on r.disbursement_id = d.id
join raw_payments p on p.id = r.payment_id
where d.status = 'CANCELLED' and d.raw_status in ('PAID', 'COMPLETED') and p.status = 'SUCCESSFUL'
    and not exists (
        select 1 from raw_receipts r2 join raw_disbursements d2 on d2.id = r2.disbursement_id
        where r2.payment_id = r.payment_id and r2.id <> r.id and lower(d2.status) in ('paid', 'success', 'completed', 'delivered'));

.print ## Q4.2 Provider 12 non-delivery by month, from raw_disbursements (one row per disbursement)
select substr(created_at, 1, 7) as month,
    count(*) filter (where lower(status) in ('paid', 'completed')) as delivered,
    count(*) filter (where lower(status) = 'failed') as failed,
    count(*) filter (where lower(status) = 'cancelled' or lower(raw_status) = 'cancelled') as cancelled,
    round(100.0 * count(*) filter (where lower(status) in ('failed', 'cancelled') or lower(raw_status) = 'cancelled')
        / count(*) filter (where lower(status) in ('paid', 'completed', 'failed', 'cancelled') or lower(raw_status) = 'cancelled'), 2) as non_delivery_pct
from raw_disbursements
where disbursement_provider = 'PROVIDER 12'
group by 1
order by 1;
