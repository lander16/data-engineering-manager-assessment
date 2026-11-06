set timezone = 'UTC';

-- Chargeback research for Q5/F5 (meaning of the flag), Y6 (maturity) and the denominator.
-- Every helper table is a temp table.
-- Card-like means payment type CARD or APPLE_PAY, which hold all 526 flags.

-- Setup. Extract end is the latest payment creation time.
create temp table extract_end as select max(created_at) as ts from payments;

-- One row per payment, with the user's sequence numbers and the next later payment by the same user.
create temp table pay as
with seq as (
    select r.id, r.user_id, r.type, r.status, r.detailed_status, r.amount, r.has_chargeback as cb,
        r.created_at, r.updated_at, r.payout_outcome, r.promotion_usd, r.payment_month,
        r.status in ('SUCCESSFUL', 'REFUNDED') as is_settled,
        r.type in ('CARD', 'APPLE_PAY') as is_card_like,
        row_number() over (partition by r.user_id order by r.created_at, r.id) as payment_seq,
        lead(r.created_at) over (partition by r.user_id order by r.created_at, r.id) as next_any_at,
        max(r.created_at) over (partition by r.user_id) as user_last_payment_at
    from remittances r
),
settled as (
    select id, row_number() over (partition by user_id order by created_at, id) as settled_seq
    from seq where is_settled
),
succ as (select user_id, created_at from payments where status = 'SUCCESSFUL')
select s.*, st.settled_seq, n.created_at as next_success_at,
    epoch((select ts from extract_end) - s.created_at) / 86400.0 as age_days
from seq s
left join settled st on st.id = s.id
asof left join succ n on n.user_id = s.user_id and s.created_at < n.created_at;

.print ## Q5.1 Text signals: any dispute or chargeback wording in payment or payout statuses
select 'payments.status / detailed_status' as field, count(*) as rows_matching
from raw_payments
where regexp_matches(lower(coalesce(status, '') || '|' || coalesce(detailed_status, '') || '|' || coalesce(type, '')), 'disput|charge_?back|reversal')
union all
select 'disbursements.status / raw_status / provider_status', count(*)
from raw_disbursements
where regexp_matches(lower(coalesce(status, '') || '|' || coalesce(raw_status, '') || '|' || coalesce(provider_status, '')), 'disput|charge_?back|reversal');

.print ## Q5.2 Flagged payments by payment status and detailed status
select status, detailed_status, count(*) as payments, sum(cb::int) as flagged
from pay group by 1, 2 having sum(cb::int) > 0 or status = 'REFUNDED' order by payments desc;

.print ## Q5.3 Flag rate by payout outcome (settled card and Apple Pay payments)
select status, payout_outcome, count(*) as payments, sum(cb::int) as flagged,
    round(100.0 * sum(cb::int) / count(*), 3) as flagged_pct
from pay where is_settled and is_card_like
group by 1, 2 order by payments desc;

.print ## Q5.4 Refund share: flagged vs unflagged settled card and Apple Pay payments
select cb as flagged, count(*) as settled, sum((status = 'REFUNDED')::int) as refunded,
    round(100.0 * avg((status = 'REFUNDED')::int), 2) as refunded_pct
from pay where is_settled and is_card_like group by 1 order by 1;

.print ## Q5.5 Payment updated_at lag in seconds: flagged vs unflagged successful card payments
select cb as flagged, count(*) as payments,
    round(quantile_cont(epoch(updated_at - created_at), 0.5), 2) as p50_s,
    round(quantile_cont(epoch(updated_at - created_at), 0.9), 2) as p90_s,
    round(quantile_cont(epoch(updated_at - created_at), 0.99), 2) as p99_s,
    max(epoch(updated_at - created_at)) as max_s,
    sum((epoch(updated_at - created_at) > 3600)::int) as over_1h
from pay where status = 'SUCCESSFUL' and type = 'CARD' group by 1 order by 1;

.print ## Q5.6 Amount band and payment type (settled)
select case when amount < 50 then '1: under 50' when amount < 100 then '2: 50-99' when amount < 200 then '3: 100-199'
        when amount < 500 then '4: 200-499' when amount < 1000 then '5: 500-999' else '6: 1000+' end as amount_band,
    count(*) as settled, sum(cb::int) as flagged, round(100.0 * sum(cb::int) / count(*), 3) as flagged_pct
from pay where is_settled and is_card_like group by 1 order by 1;

select type, count(*) as settled, sum(cb::int) as flagged, round(100.0 * sum(cb::int) / count(*), 3) as flagged_pct
from pay where is_settled group by 1 order by 2 desc;

.print ## Q5.7 First settled payment and promotion concentration (settled card and Apple Pay)
select case when settled_seq = 1 then 'first settled payment' else 'later' end as position,
    count(*) as settled, sum(cb::int) as flagged, round(100.0 * sum(cb::int) / count(*), 3) as flagged_pct,
    round(100.0 * sum(cb::int) / sum(sum(cb::int)) over (), 1) as share_of_flags_pct
from pay where is_settled and is_card_like group by 1 order by 1 desc;

select case when promotion_usd > 0 then 'has promotion' else 'no promotion' end as promo,
    case when settled_seq = 1 then 'first' else 'later' end as position,
    count(*) as delivered, sum(cb::int) as flagged, round(100.0 * sum(cb::int) / count(*), 3) as flagged_pct
from pay where is_settled and is_card_like and payout_outcome = 'delivered'
group by 1, 2 order by 2 desc, 1;

.print ## Q5.8 Repeat flags per user, against independence
with u as (
    select user_id, count(*) as n_pay, sum(cb::int) as n_flag
    from pay where is_settled and is_card_like group by 1
),
rate as (select sum(n_flag) * 1.0 / sum(n_pay) as p from u)
select (select count(*) from u where n_flag = 1) as users_1_flag,
    (select count(*) from u where n_flag = 2) as users_2_flags,
    (select count(*) from u where n_flag >= 3) as users_3plus_flags,
    round(sum(n_pay * (n_pay - 1) / 2.0 * p * p), 2) as expected_pairs_if_independent,
    (select sum(n_flag * (n_flag - 1) / 2) from u) as observed_pairs
from u, rate;

.print ## Q5.9 Repeat flags: days between a user's flagged payments
with f as (
    select user_id, id, created_at, row_number() over (partition by user_id order by created_at) as k,
        lag(created_at) over (partition by user_id order by created_at) as prev_flag_at
    from pay where cb
),
g as (select epoch(created_at - prev_flag_at) / 86400.0 as gap_days from f where k >= 2)
select count(*) as repeat_flags,
    round(quantile_cont(gap_days, 0.1), 2) as p10_days,
    round(quantile_cont(gap_days, 0.5), 2) as p50_days,
    round(quantile_cont(gap_days, 0.9), 2) as p90_days,
    round(max(gap_days), 1) as max_days,
    sum((gap_days > 30)::int) as over_30_days
from g;

.print ## Q5.10 Activity after the flagged payment vs matched unflagged payments
-- Strata: payment month, type, first or later settled payment, amount band.
-- A horizon only counts payments with at least that many days of follow-up before the extract end.
-- Expected = flagged count in each stratum times the unflagged rate in the same stratum.
create temp table strata as
select *, strftime(created_at, '%Y-%m') as mth,
    case when settled_seq = 1 then 'first' when settled_seq = 2 then 'second' else 'third+' end as seq_band,
    case when amount < 100 then 'lt100' when amount < 300 then '100-299' else '300+' end as amt_band,
    epoch(next_any_at - created_at) / 86400.0 as days_to_next_any,
    epoch(next_success_at - created_at) / 86400.0 as days_to_next_success
from pay where is_settled and is_card_like;

create temp table horizons as select unnest([7, 30, 60, 90]) as h;

with ctl as (
    select h, mth, type, seq_band, amt_band, count(*) as n,
        avg((days_to_next_any <= h)::int) as r_any, avg((days_to_next_success <= h)::int) as r_succ
    from strata, horizons
    where not cb and age_days >= h group by all
),
flg as (
    select h, mth, type, seq_band, amt_band, count(*) as n_f,
        sum((days_to_next_any <= h)::int) as k_any, sum((days_to_next_success <= h)::int) as k_succ
    from strata, horizons
    where cb and age_days >= h group by all
)
select h as horizon_days, sum(n_f) as flagged_payments,
    sum(n_f) filter (where r_any is null) as unmatched,
    sum(k_any) as flagged_with_later_payment,
    round(sum(n_f * coalesce(r_any, 0)), 1) as expected_later_payment,
    sum(k_succ) as flagged_with_later_success,
    round(sum(n_f * coalesce(r_succ, 0)), 1) as expected_later_success,
    round(100.0 * sum(k_succ) / sum(n_f), 1) as flagged_success_pct,
    round(100.0 * sum(n_f * coalesce(r_succ, 0)) / sum(n_f), 1) as expected_success_pct
from flg left join ctl using (h, mth, type, seq_band, amt_band)
group by h order by h;

.print ## Q5.11 Flagged payments: share of users with any successful payment in later windows, vs matched unflagged
-- Only payments with at least 120 days of follow-up. A user counts if a successful payment falls in the window.
with w as (select unnest([[0, 7], [7, 30], [30, 60], [60, 90], [90, 120]]) as win),
x as (select w.win[1] as lo, w.win[2] as hi, s.* from strata s, w where s.age_days >= 120),
ctl as (
    select lo, hi, mth, type, seq_band, amt_band, avg((days_to_next_success > lo and days_to_next_success <= hi)::int) as r, count(*) as n
    from x where not cb group by all
),
flg as (
    select lo, hi, mth, type, seq_band, amt_band, count(*) as n_f, sum((days_to_next_success > lo and days_to_next_success <= hi)::int) as k
    from x where cb group by all
)
select lo || '-' || hi as days_after_payment, sum(n_f) as flagged_payments, sum(k) as flagged_with_success,
    round(sum(n_f * coalesce(r, 0)), 1) as expected_with_success,
    round(sum(k) / nullif(sum(n_f * coalesce(r, 0)), 0), 2) as ratio_flagged_to_expected
from flg left join ctl using (lo, hi, mth, type, seq_band, amt_band)
group by lo, hi order by lo;

.print ## Q5.12 Flagged payments followed by a successful payment more than 30 days later
-- If a user is blocked at dispute time, this gap is a lower bound on the dispute lag for that payment.
select round(s.age_days, 0) as age_days, round(s.days_to_next_success, 1) as days_to_next_success,
    s.settled_seq, (select cb from pay n where n.user_id = s.user_id and n.created_at = s.next_success_at) as later_payment_also_flagged
from strata s where s.cb and s.days_to_next_success > 30 order by s.days_to_next_success desc;

.print ## Q5.13 Flagged payment is the user's last payment of any status, vs matched unflagged
-- Only payments with at least 120 days of follow-up.
with ctl as (
    select mth, type, seq_band, amt_band, avg((user_last_payment_at = created_at)::int) as r
    from strata where not cb and age_days >= 120 group by all
),
flg as (
    select mth, type, seq_band, amt_band, count(*) as n_f, sum((user_last_payment_at = created_at)::int) as k
    from strata where cb and age_days >= 120 group by all
)
select sum(n_f) as flagged_payments, sum(k) as flagged_is_last_payment,
    round(100.0 * sum(k) / sum(n_f), 1) as flagged_pct,
    round(100.0 * sum(n_f * coalesce(r, 0)) / sum(n_f), 1) as expected_pct
from flg left join ctl using (mth, type, seq_band, amt_band);

.print ## Y6.1 Flag rate by payment month, settled card and Apple Pay payments
select payment_month, count(*) as settled, sum(cb::int) as flagged,
    round(100.0 * sum(cb::int) / count(*), 3) as count_pct,
    round(100.0 * (sum(cb::int) - 1.96 * sqrt(sum(cb::int))) / count(*), 3) as ci_low_pct,
    round(100.0 * (sum(cb::int) + 1.96 * sqrt(sum(cb::int))) / count(*), 3) as ci_high_pct,
    round(100.0 * sum(amount) filter (where cb) / sum(amount), 3) as usd_pct,
    round(avg(age_days), 0) as mean_age_days, round(min(age_days), 0) as min_age_days
from pay where is_settled and is_card_like group by 1 order by 1;

.print ## Y6.2 Flag rate by 14-day age band at the extract end (age = extract end minus payment time)
select case when age_days < 8 then '00-07' else lpad((8 + 14 * floor((age_days - 8) / 14))::int::varchar, 3, '0') || '-' || lpad((8 + 14 * floor((age_days - 8) / 14) + 13)::int::varchar, 3, '0') end as age_band_days,
    count(*) as settled, sum(cb::int) as flagged,
    round(100.0 * sum(cb::int) / count(*), 3) as count_pct,
    round(100.0 * (sum(cb::int) - 1.96 * sqrt(sum(cb::int))) / count(*), 3) as ci_low_pct,
    round(100.0 * (sum(cb::int) + 1.96 * sqrt(sum(cb::int))) / count(*), 3) as ci_high_pct
from pay where is_settled and is_card_like group by 1 order by 1;

.print ## Y6.2b Flag rate by wide age band, with the rate relative to the oldest band
with b as (
    select case when age_days < 8 then '0: 0-7 days' when age_days < 50 then '1: 8-49 days' when age_days < 106 then '2: 50-105 days'
            when age_days < 176 then '3: 106-175 days' else '4: 176+ days' end as age_band,
        cb
    from pay where is_settled and is_card_like
)
select age_band, count(*) as settled, sum(cb::int) as flagged,
    round(100.0 * sum(cb::int) / count(*), 4) as count_pct,
    round((sum(cb::int) * 1.0 / count(*)) / (select sum(cb::int) * 1.0 / count(*) from b where age_band like '4:%'), 2) as ratio_to_176plus,
    round((sum(cb::int) * 1.0 / count(*)) / (select sum(cb::int) * 1.0 / count(*) from b where age_band like '3:%'), 2) as ratio_to_106_175
from b group by 1 order by 1;

.print ## Y6.3 Youngest flagged payments: age in days at the extract end
select round(age_days, 1) as age_days, type, round(amount, 2) as amount, settled_seq
from pay where cb order by age_days limit 8;

.print ## Y6.4 Flagged payments in the youngest ages, against the volume at risk
select case when age_days < 4 then '0-3' when age_days < 8 then '4-7' when age_days < 11 then '8-10' when age_days < 15 then '11-14' else '15+' end as age_band_days,
    count(*) as settled, sum(cb::int) as flagged
from pay where is_settled and is_card_like and age_days < 30 group by 1 order by min(age_days);

.print ## Y6.5 Flag rate by payment week, settled card and Apple Pay payments
select cast(date_trunc('week', created_at) as date) as week_start, count(*) as settled, sum(cb::int) as flagged,
    round(100.0 * sum(cb::int) / count(*), 3) as count_pct, round(avg(age_days), 0) as mean_age_days
from pay where is_settled and is_card_like group by 1 order by 1;

.print ## Y6.6 Card vs Apple Pay (Apple Pay first appears on 2026-06-08), same period
select type, count(*) as settled, sum(cb::int) as flagged, round(100.0 * sum(cb::int) / count(*), 3) as count_pct
from pay where is_settled and is_card_like and created_at >= (select min(created_at) from payments where type = 'APPLE_PAY')
group by 1 order by 1;

.print ## Y6.7 First vs later settled payments by month (settled card and Apple Pay)
select payment_month, sum((settled_seq = 1)::int) as first_payments,
    round(100.0 * avg((settled_seq = 1)::int), 1) as first_share_pct,
    round(100.0 * sum(cb::int) filter (where settled_seq = 1) / sum((settled_seq = 1)::int), 3) as first_flag_pct,
    round(100.0 * sum(cb::int) filter (where settled_seq > 1) / sum((settled_seq > 1)::int), 3) as later_flag_pct
from pay where is_settled and is_card_like group by 1 order by 1;

.print ## Y6.8 Risk-drift proxies available at payment time: card declines by month, against the flag count
-- Declines are known immediately, so they cannot be affected by dispute lag.
select strftime(created_at, '%Y-%m') as month, count(*) as card_attempts,
    round(100.0 * avg((detailed_status = 'FAILED_DUE_TO_SUSPECTED_FRAUD_BY_PROCESSOR')::int), 2) as suspected_fraud_decline_pct,
    round(100.0 * avg((detailed_status in ('FAILED_DUE_TO_STOLEN_CARD', 'FAILED_DUE_TO_REPORTED_LOST'))::int), 2) as stolen_or_lost_decline_pct,
    sum(cb::int) as flagged,
    round(sum(cb::int) / (sum((detailed_status = 'FAILED_DUE_TO_SUSPECTED_FRAUD_BY_PROCESSOR')::int) / 100.0), 2) as flagged_per_100_fraud_declines
from pay where is_card_like group by 1 order by 1;

.print ## Y6.9 Headline flag rate over the months that are mature under each assumed lag
-- A month is mature when its end plus the lag is on or before the extract end.
with lags as (select unnest([30, 60, 90, 120, 150]) as lag_days),
m as (
    select payment_month, count(*) as settled, sum(cb::int) as flagged,
        sum(amount) as usd, sum(amount) filter (where cb) as flagged_usd
    from pay where is_settled and is_card_like group by 1
)
select lag_days, count(*) as mature_months, min(payment_month) || ' to ' || max(payment_month) as months,
    sum(settled) as settled, sum(flagged) as flagged,
    round(100.0 * sum(flagged) / sum(settled), 4) as count_pct,
    round(100.0 * sum(flagged_usd) / sum(usd), 4) as usd_pct
from lags join m on cast(m.payment_month + interval 1 month as timestamptz) + lag_days * interval 1 day <= (select ts from extract_end)
group by lag_days
union all
select null, count(*), 'all months', sum(settled), sum(flagged),
    round(100.0 * sum(flagged) / sum(settled), 4), round(100.0 * sum(flagged_usd) / sum(usd), 4)
from m
order by lag_days nulls last;

.print ## Y6.10 Each month's flag rate as a share of the pooled mature-month rate, for lags of 60, 90 and 120 days
with m as (
    select payment_month, count(*) as settled, sum(cb::int) as flagged
    from pay where is_settled and is_card_like group by 1
),
ref as (
    select l.lag_days, sum(flagged) * 1.0 / sum(settled) as mature_rate
    from (select unnest([60, 90, 120]) as lag_days) l
    join m on cast(m.payment_month + interval 1 month as timestamptz) + l.lag_days * interval 1 day <= (select ts from extract_end)
    group by 1
)
select m.payment_month, m.settled, m.flagged,
    round(100.0 * m.flagged / m.settled, 3) as count_pct,
    round(100.0 * (m.flagged * 1.0 / m.settled) / max(r.mature_rate) filter (where r.lag_days = 60), 0) as pct_of_rate_lag60,
    round(100.0 * (m.flagged * 1.0 / m.settled) / max(r.mature_rate) filter (where r.lag_days = 90), 0) as pct_of_rate_lag90,
    round(100.0 * (m.flagged * 1.0 / m.settled) / max(r.mature_rate) filter (where r.lag_days = 120), 0) as pct_of_rate_lag120
from m cross join ref r group by m.payment_month, m.settled, m.flagged order by 1;

.print ## D7.1 Denominator comparison: count and USD flag rates
-- Numerator is the flagged payments (and their payment amount) that fall inside each denominator.
with d as (
    select 'A settled, all types (SUCCESSFUL + REFUNDED)' as denominator, * from pay where is_settled
    union all select 'B settled, card + Apple Pay', * from pay where is_settled and is_card_like
    union all select 'C settled, card + Apple Pay, excluding no-receipt SUCCESSFUL', * from pay
        where is_settled and is_card_like and not (status = 'SUCCESSFUL' and payout_outcome = 'no_receipt')
    union all select 'D SUCCESSFUL only, card + Apple Pay', * from pay where status = 'SUCCESSFUL' and is_card_like
    union all select 'E delivered remittances (SUCCESSFUL with a delivered attempt), all types', * from pay
        where status = 'SUCCESSFUL' and payout_outcome in ('delivered', 'multiple_delivered')
    union all select 'F delivered remittances, card + Apple Pay', * from pay
        where status = 'SUCCESSFUL' and payout_outcome in ('delivered', 'multiple_delivered') and is_card_like
    union all select 'G CARD type only, settled', * from pay where is_settled and type = 'CARD'
    union all select 'H all card + Apple Pay attempts, including FAILED', * from pay where is_card_like
)
select denominator, count(*) as payments, sum(cb::int) as flagged,
    round(100.0 * sum(cb::int) / count(*), 4) as count_pct,
    round(sum(amount), 0) as usd, round(sum(amount) filter (where cb), 0) as flagged_usd,
    round(100.0 * sum(amount) filter (where cb) / sum(amount), 4) as usd_pct
from d group by denominator order by denominator;

.print ## D7.2 No-receipt SUCCESSFUL payments by month and their effect on the card rate
select p.payment_month, count(*) as settled_card_like,
    sum((status = 'SUCCESSFUL' and payout_outcome = 'no_receipt')::int) as no_receipt_successful,
    round(100.0 * avg((status = 'SUCCESSFUL' and payout_outcome = 'no_receipt')::int), 2) as no_receipt_pct,
    round(100.0 * sum(cb::int) / count(*), 4) as rate_with_pct,
    round(100.0 * sum(cb::int) filter (where not (status = 'SUCCESSFUL' and payout_outcome = 'no_receipt'))
        / count(*) filter (where not (status = 'SUCCESSFUL' and payout_outcome = 'no_receipt')), 4) as rate_without_pct
from pay p where is_settled and is_card_like group by 1 order by 1;

.print ## D7.3 Flagged payments that sit outside the delivered-remittance denominator
select status, payout_outcome, count(*) as flagged, round(sum(amount), 0) as usd
from pay where cb and not (status = 'SUCCESSFUL' and payout_outcome in ('delivered', 'multiple_delivered'))
group by 1, 2 order by 3 desc;

.print ## D7.4 Delivered denominator by month: rate on delivered remittances vs settled card payments
select payment_month,
    round(100.0 * sum(cb::int) filter (where is_settled and is_card_like) / count(*) filter (where is_settled and is_card_like), 4) as settled_card_pct,
    round(100.0 * sum(cb::int) filter (where status = 'SUCCESSFUL' and payout_outcome in ('delivered', 'multiple_delivered')) /
        count(*) filter (where status = 'SUCCESSFUL' and payout_outcome in ('delivered', 'multiple_delivered')), 4) as delivered_pct
from pay group by 1 order by 1;

.print ## Check1 Flags in the youngest ages, recomputed from the raw text tables
select count(*) filter (where has_dispute_chargeback = 'True') as flagged_all,
    count(*) filter (where has_dispute_chargeback = 'True' and replace(created_at, '+00:00', '')::timestamp > (select max(replace(created_at, '+00:00', '')::timestamp) from raw_payments) - interval 8 day) as flagged_in_last_8_days,
    count(*) filter (where status in ('SUCCESSFUL', 'REFUNDED') and type in ('CARD', 'APPLE_PAY') and replace(created_at, '+00:00', '')::timestamp > (select max(replace(created_at, '+00:00', '')::timestamp) from raw_payments) - interval 8 day) as settled_card_in_last_8_days
from raw_payments;

.print ## Check2 Flag rate of SUCCESSFUL card payments whose every payout failed or was cancelled, recomputed from receipts and disbursements
select count(*) as payments, sum(has_chargeback::int) as flagged, round(100.0 * sum(has_chargeback::int) / count(*), 2) as flagged_pct
from payments p
where p.status = 'SUCCESSFUL' and p.type in ('CARD', 'APPLE_PAY')
    and exists (select 1 from receipts r where r.payment_id = p.id)
    and not exists (
        select 1 from receipts r left join disbursements d on d.id = r.disbursement_id
        where r.payment_id = p.id
            and coalesce(d.status_lc, 'missing') not in ('failed', 'rejected', 'error_sending_payout_request', 'payout_not_processed', 'cancelled'));

.print ## Check3 Flagged payments with a successful payment by the same user in the following 90 days, by self-join
select count(*) as flagged_with_90_days_follow_up,
    count(*) filter (where exists (
        select 1 from payments n where n.user_id = f.user_id and n.status = 'SUCCESSFUL'
            and n.created_at > f.created_at and n.created_at <= f.created_at + interval 90 day)) as with_later_success
from payments f
where f.has_chargeback and f.type in ('CARD', 'APPLE_PAY') and f.status in ('SUCCESSFUL', 'REFUNDED')
    and f.created_at <= (select max(created_at) from payments) - interval 90 day;
