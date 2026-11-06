set timezone = 'UTC';

-- Research for open modeling questions Q2/F2 (promotions), Y1 (headline amount) and Q4/F4 (successful payments without receipts).
-- Needs the helper tables from 10_research_setup.sql (attempts, remittances) in the research database.
-- Temp tables below are session-local, so the script runs against a read-only database.

-- ---------------------------------------------------------------------------
-- Session helper tables (no output)
-- ---------------------------------------------------------------------------

-- First attempt per payment. Promotion and charged amount are the same on every attempt of a payment (checked below).
create temp table fa as
select a.payment_id, a.user_id, a.promotion_amount as promo, a.amount_charged as charged, a.fee, a.country,
    a.attempt_status as first_attempt_status, p.type as ptype, p.status as pstatus, p.has_chargeback,
    p.created_at, p.amount as pamount,
    case
        when a.promotion_amount = 0 then 'none'
        when a.amount_charged = 0 then 'fully_funded'
        when a.promotion_amount < 50 then 'partial_under_50'
        else 'partial_50_plus'
    end as promo_class
from attempts a
join payments p on p.id = a.payment_id
where a.attempt_number = 1;

-- Delivered remittances with the primary-attempt economics (Y1 definition).
create temp table dr as
select p.id as payment_id, p.user_id, p.created_at, p.amount as pamount, p.type as ptype, a.country,
    a.amount_charged as charged, a.fee, a.promotion_amount as promo,
    a.attempt_number as primary_attempt_no, r.attempt_count,
    p.amount - (a.amount_charged + a.fee) as gap
from payments p
join remittances r on r.id = p.id and r.is_delivered_remittance
join attempts a on a.payment_id = p.id and a.is_primary_attempt;

-- Per payment, how many payments the same user created before it, and which problem statuses they had.
create temp table hist as
select p.id as payment_id, p.user_id, p.created_at, p.status, p.amount,
    case
        when f.payment_id is null then 'no_receipt'
        else f.promo_class
    end as grp,
    count(*) over w - 1 as n_prior_all,
    sum((p.status = 'REFUNDED')::int) over w - (p.status = 'REFUNDED')::int as n_prior_refund,
    sum((p.status = 'FAILED')::int) over w - (p.status = 'FAILED')::int as n_prior_failed,
    sum(p.has_chargeback::int) over w - p.has_chargeback::int as n_prior_chargeback,
    sum((p.status = 'SUCCESSFUL' and not coalesce(r.is_delivered_remittance, false))::int) over w
        - (p.status = 'SUCCESSFUL' and not coalesce(r.is_delivered_remittance, false))::int as n_prior_unresolved
from payments p
left join fa f on f.payment_id = p.id
left join remittances r on r.id = p.id
window w as (partition by p.user_id order by p.created_at, p.id rows between unbounded preceding and current row);

-- Per-user totals under three money measures, ranked with user_id as tie-break.
create temp table u as
select user_id, count(*) as n, sum(pamount) as paid, sum(charged + promo) as sent, sum(charged) as cash,
    row_number() over (order by sum(pamount) desc, user_id) as rk_paid,
    row_number() over (order by sum(charged + promo) desc, user_id) as rk_sent,
    row_number() over (order by sum(charged) desc, user_id) as rk_cash
from dr
group by 1;

-- SUCCESSFUL payments without any receipt, with an amount-family label.
-- six25_family: amount = 6.25 * m - 0.25 for integer m, between 12 and 150 (12.25, 18.50, 24.75, 31.00, 37.25, ...).
create temp table nr as
select p.id as payment_id, p.user_id, p.created_at, p.updated_at, p.amount, p.type, p.detailed_status, p.has_chargeback,
    case
        when p.amount = 1 then 'one_dollar'
        when (p.amount + 0.25) % 6.25 = 0 and p.amount between 12 and 150 then 'six25_family'
        when p.created_at < timestamptz '2026-07-01' then 'june_round'
        else 'other'
    end as amount_family,
    hour(p.created_at) as hr_utc,
    dayofweek(p.created_at) as dow
from payments p
join remittances r on r.id = p.id
where p.status = 'SUCCESSFUL' and r.payout_outcome = 'no_receipt';

-- Every payment with the same amount-family label (any status), for failure and refund comparisons.
create temp table pcl as
select p.id, p.user_id, p.created_at, p.status, p.detailed_status, p.type, p.amount, p.has_chargeback, r.payout_outcome,
    case
        when p.amount = 1 then 'one_dollar'
        when (p.amount + 0.25) % 6.25 = 0 and p.amount between 12 and 150 then 'six25_family'
        else 'other'
    end as amount_family
from payments p
join remittances r on r.id = p.id;

-- ===========================================================================
-- Q1: What is promotion_amount?
-- ===========================================================================

.print ## 1.01 Promotion volume and consistency across attempts
-- Receipts with a promotion, distinct values, total, and whether the value changes between attempts of one payment.
select
    count(*) as receipts,
    sum((promotion_amount > 0)::int) as receipts_with_promo,
    count(distinct promotion_amount) filter (where promotion_amount > 0) as distinct_promo_values,
    sum(promotion_amount) as promo_usd_all_receipts,
    (select count(*) from fa where promo > 0) as payments_with_promo,
    (select count(*) from (select payment_id from attempts group by 1 having count(distinct promotion_amount) > 1)) as payments_where_promo_varies_by_attempt,
    (select count(*) from (select payment_id from attempts group by 1 having count(distinct amount_charged) > 1)) as payments_where_charged_varies_by_attempt
from receipts;

.print ## 1.02 Most common promotion values (receipt level)
select promotion_amount, count(*) as receipts, count(distinct user_id) as users,
    round(100 * count(*) / sum(count(*)) over (), 2) as pct_of_promo_receipts,
    round(100 * sum(count(*)) over (order by count(*) desc, promotion_amount) / sum(count(*)) over (), 1) as cumulative_pct
from receipts
where promotion_amount > 0
group by 1
order by 2 desc, 1
limit 20;

.print ## 1.03 Promotion value quantiles and roundness by class (payment level, first attempt)
select promo_class, count(*) as payments,
    quantile_cont(promo, [0.1, 0.5, 0.9, 0.99])::double[] as promo_q10_50_90_99,
    max(promo) as max_promo,
    round(100 * avg((promo = round(promo))::int), 1) as pct_whole_dollar,
    round(100 * avg((promo % 10 = 0)::int), 1) as pct_multiple_of_10,
    round(100 * avg((promo % 50 = 0)::int), 1) as pct_multiple_of_50
from fa
where promo > 0
group by 1
order by 1;

.print ## 1.04 Promotion as a share of value sent, by class (payment level, first attempt)
select promo_class, count(*) as payments, round(sum(promo), 0) as promo_usd, round(avg(promo), 2) as avg_promo,
    round(avg(charged + promo), 2) as avg_value_sent,
    round(100 * avg(promo / (charged + promo)), 1) as avg_promo_pct_of_value_sent,
    round(100 * sum(promo) / sum(charged + promo), 2) as promo_pct_of_class_value_sent
from fa
where promo > 0
group by 1
order by 1;

.print ## 1.05 Promotion classes among delivered remittances: size and user position (primary attempt)
-- first_in_extract = the user has no earlier payment of any status in the extract (left-censored for January and February).
select case when d.promo = 0 then 'none' when d.charged = 0 then 'fully_funded' when d.promo < 50 then 'partial_under_50' else 'partial_50_plus' end as promo_class,
    count(*) as delivered_remittances, round(sum(d.promo), 0) as promo_usd,
    round(100 * sum(d.promo) / sum(sum(d.promo)) over (), 1) as pct_of_all_promo_usd,
    round(100 * avg((h.n_prior_all = 0)::int), 1) as pct_first_in_extract,
    round(100 * avg((h.n_prior_all <= 1)::int), 1) as pct_first_or_second
from dr d
join hist h using (payment_id)
group by 1
order by 1;

.print ## 1.06 Delivered promotions by month and class
select date_trunc('month', created_at)::date as month,
    sum((promo > 0 and charged = 0)::int) as fully_funded_n,
    round(sum(case when promo > 0 and charged = 0 then promo end), 0) as fully_funded_usd,
    sum((promo > 0 and charged > 0 and promo < 50)::int) as partial_under_50_n,
    round(sum(case when promo > 0 and charged > 0 and promo < 50 then promo end), 0) as partial_under_50_usd,
    sum((promo >= 50 and charged > 0)::int) as partial_50_plus_n,
    round(sum(case when promo >= 50 and charged > 0 then promo end), 0) as partial_50_plus_usd,
    round(100 * sum(promo) / sum(charged + promo), 3) as promo_pct_of_value_sent
from dr
group by 1
order by 1;

.print ## 1.07 Partial promotions: tier by month (first attempt, promotion above 0 and amount_charged above 0; tiers with 50 or more payments)
select promo, sum((month(fa.created_at) = 1)::int) as jan, sum((month(fa.created_at) = 2)::int) as feb,
    sum((month(fa.created_at) = 3)::int) as mar, sum((month(fa.created_at) = 4)::int) as apr,
    sum((month(fa.created_at) = 5)::int) as may, sum((month(fa.created_at) = 6)::int) as jun,
    sum((month(fa.created_at) = 7)::int) as jul, sum((month(fa.created_at) = 8)::int) as aug,
    sum((month(fa.created_at) = 9)::int) as sep, count(*) as total,
    round(100 * avg((h.n_prior_all = 0)::int), 1) as pct_first_in_extract
from fa
join hist h using (payment_id)
where promo > 0 and charged > 0
group by 1
having count(*) >= 50
order by total desc;

.print ## 1.08 Fully funded promotions: value tiers by month
select promo, sum((month(created_at) <= 4)::int) as jan_to_apr, sum((month(created_at) in (5, 6))::int) as may_jun,
    sum((month(created_at) in (7, 8))::int) as jul_aug, sum((month(created_at) = 9)::int) as sep, count(*) as total
from fa
where promo > 0 and charged = 0
group by 1
having count(*) >= 30
order by total desc;

.print ## 1.09 Promotion incidence by corridor (delivered remittances)
select country, count(*) as delivered, sum((promo > 0)::int) as with_promo,
    round(100 * avg((promo > 0)::int), 2) as pct_with_promo,
    sum((promo > 0 and charged = 0)::int) as fully_funded,
    round(100 * avg((promo > 0 and charged = 0)::int), 2) as pct_fully_funded,
    round(sum(promo), 0) as promo_usd
from dr
group by 1
order by delivered desc;

.print ## 1.10 Promotion incidence by payment type (delivered remittances)
select ptype, count(*) as delivered, sum((promo > 0)::int) as with_promo,
    round(100 * avg((promo > 0)::int), 2) as pct_with_promo, sum((promo > 0 and charged = 0)::int) as fully_funded
from dr
group by 1
order by delivered desc;

.print ## 1.11 Promotion and fee (first attempt, all payments)
select promo_class, count(*) as payments, round(avg(fee), 2) as avg_fee, round(100 * avg((fee = 0)::int), 1) as pct_fee_zero,
    round(100 * avg((pamount = charged + fee)::int), 2) as pct_payment_equals_charged_plus_fee,
    round(100 * avg((promo = fee and promo > 0)::int), 2) as pct_promo_equals_fee
from fa
group by 1
order by 1;

.print ## 1.12 Fully funded receipts: what payments.amount equals
-- 2,953 receipts, 2,888 payments. amount_charged is 0 on all of them.
select count(*) as fully_funded_receipts, count(distinct a.payment_id) as payments,
    sum((abs(p.amount - a.fee) < 0.005)::int) as payment_amount_equals_receipt_fee,
    sum((p.amount = 0)::int) as payment_amount_zero,
    sum((a.fee = 0)::int) as receipt_fee_zero,
    sum((abs(p.amount - a.fee) >= 0.005)::int) as payment_amount_not_equal_fee
from attempts a
join payments p on p.id = a.payment_id
where a.amount_charged = 0;

.print ## 1.13 Fully funded receipts where payment amount differs from the receipt fee
select p.status, a.attempt_number, a.attempt_status, a.fee as receipt_fee, p.amount as payment_amount, round(p.amount - a.fee, 2) as gap
from attempts a
join payments p on p.id = a.payment_id
where a.amount_charged = 0 and abs(p.amount - a.fee) >= 0.005
order by gap;

.print ## 1.14 Fully funded: value sent against ordinary sends up to $600
-- Ordinary = no promotion, value sent 600 or less, delivered primary attempt.
select case when promo = 0 then 'no_promo_up_to_600' else 'fully_funded' end as grp, count(*) as n,
    quantile_cont(charged + promo, [0.1, 0.25, 0.5, 0.75, 0.9])::double[] as value_q,
    max(charged + promo) as max_value_sent,
    round(100 * avg(((charged + promo) = round(charged + promo))::int), 1) as pct_whole_dollar,
    round(100 * avg((charged + promo = 100)::int), 1) as pct_exactly_100,
    round(100 * avg((charged + promo = 150)::int), 1) as pct_exactly_150,
    round(100 * avg((charged + promo = 500)::int), 1) as pct_exactly_500,
    round(100 * avg((charged + promo = 600)::int), 1) as pct_exactly_600
from dr
where (promo = 0 and charged + promo <= 600) or (promo > 0 and charged = 0)
group by 1;

.print ## 1.15 Ordinary delivered sends above $600
select count(*) as delivered_without_promo_above_600, count(distinct user_id) as users, max(charged) as max_charged
from dr
where promo = 0 and charged > 600;

.print ## 1.16 Fully funded: share of payments that are the user's first in the extract, by month
-- Ordinary and fully funded payments move together, so promoted payments are not concentrated at first use.
select date_trunc('month', created_at)::date as month,
    sum((grp = 'fully_funded')::int) as fully_funded_n,
    round(100 * avg((n_prior_all = 0)::int) filter (where grp = 'fully_funded'), 1) as fully_funded_pct_first,
    round(100 * avg((n_prior_all = 0)::int) filter (where grp = 'none'), 1) as ordinary_pct_first,
    round(100 * avg((n_prior_all = 0)::int) filter (where grp like 'partial%'), 1) as partial_promo_pct_first
from hist
where status = 'SUCCESSFUL' and grp <> 'no_receipt'
group by 1
order by 1;

.print ## 1.17 Fully funded: delivered-sequence position and repeat recipients
select case when d.promo = 0 then 'none' when d.charged = 0 then 'fully_funded' else 'partial' end as grp, count(*) as delivered,
    round(100 * avg((s.dseq = 1)::int), 1) as pct_first_delivered,
    round(100 * avg((s.dseq = 2)::int), 1) as pct_second_delivered,
    round(100 * avg((s.dseq >= 3)::int), 1) as pct_third_or_later
from dr d
join (select payment_id, row_number() over (partition by user_id order by created_at, payment_id) as dseq from dr) s using (payment_id)
group by 1
order by 1;

.print ## 1.18 Number of promoted payments per user, by class
select grp, promoted_payments, count(*) as users
from (select user_id, case when charged = 0 then 'fully_funded' else 'partial' end as grp, count(*) as promoted_payments from fa where promo > 0 group by 1, 2)
group by 1, 2
order by 1, 2;

.print ## 1.19 Refund-credit test A: earlier problem payments of the same user, by promotion class
-- Share of successful payments whose user has an earlier refunded / failed-card / unresolved-success payment, with and without a prior payment.
select grp, count(*) as payments, round(100 * avg((n_prior_all > 0)::int), 1) as pct_with_any_prior,
    round(100 * avg((n_prior_refund > 0)::int), 2) as pct_prior_refund,
    round(100 * avg((n_prior_failed > 0)::int), 2) as pct_prior_failed_card,
    round(100 * avg((n_prior_chargeback > 0)::int), 3) as pct_prior_chargeback,
    round(100 * avg((n_prior_unresolved > 0)::int), 2) as pct_prior_successful_but_undelivered
from hist
where status = 'SUCCESSFUL'
group by 1
order by 1;

.print ## 1.20 Refund-credit test A restricted to users with at least one earlier payment
select grp, count(*) as payments, round(100 * avg((n_prior_refund > 0)::int), 2) as pct_prior_refund,
    round(100 * avg((n_prior_failed > 0)::int), 2) as pct_prior_failed_card,
    round(100 * avg((n_prior_unresolved > 0)::int), 2) as pct_prior_successful_but_undelivered
from hist
where status = 'SUCCESSFUL' and n_prior_all > 0
group by 1
order by 1;

.print ## 1.21 Refund-credit test B: earlier payment with the same amount as the promotion
-- ff = fully funded payment. A prior payment "matches" when its amount, its value sent, or amount + the fully funded payment's fee equals the promotion.
-- The control is every ordinary delivered payment from March on with value sent of 600 or less, tested against the same user's earlier payments.
with ff as (select payment_id, user_id, created_at, promo, pamount from fa where promo_class = 'fully_funded'),
prior as (
    select ff.payment_id as ffid, ff.promo, ff.pamount as fee_paid, o.status as ostatus, o.amount as oamount, r.value_sent_usd as ovalue,
        coalesce(r.is_delivered_remittance, false) as odelivered
    from ff
    join payments o on o.user_id = ff.user_id and o.created_at < ff.created_at
    left join remittances r on r.id = o.id
),
ctrl_base as (select payment_id, user_id, created_at, charged + promo as val, pamount from dr where promo = 0 and charged + promo <= 600 and created_at >= timestamptz '2026-03-01'),
ctrl as (
    select c.payment_id as cid, c.val, c.pamount, o.status as ostatus, o.amount as oamount, r.value_sent_usd as ovalue,
        coalesce(r.is_delivered_remittance, false) as odelivered
    from ctrl_base c
    join payments o on o.user_id = c.user_id and o.created_at < c.created_at
    left join remittances r on r.id = o.id
)
select 'fully_funded' as grp, (select count(*) from ff) as payments,
    count(distinct ffid) filter (where ostatus = 'REFUNDED') as with_prior_refund,
    count(distinct ffid) filter (where ostatus = 'REFUNDED' and (oamount = promo or ovalue = promo or oamount = promo + fee_paid)) as prior_refund_same_amount,
    count(distinct ffid) filter (where (ostatus in ('REFUNDED', 'FAILED') or not odelivered) and (oamount = promo or ovalue = promo or oamount = promo + fee_paid)) as prior_problem_same_amount,
    count(distinct ffid) filter (where oamount = promo or ovalue = promo or oamount = promo + fee_paid) as prior_any_same_amount
from prior
union all
select 'ordinary_up_to_600_from_march', (select count(*) from ctrl_base),
    count(distinct cid) filter (where ostatus = 'REFUNDED'),
    count(distinct cid) filter (where ostatus = 'REFUNDED' and (oamount = val or ovalue = val or oamount = pamount)),
    count(distinct cid) filter (where (ostatus in ('REFUNDED', 'FAILED') or not odelivered) and (oamount = val or ovalue = val or oamount = pamount)),
    count(distinct cid) filter (where oamount = val or ovalue = val or oamount = pamount)
from ctrl;

.print ## 1.22 Refund-credit test C: does a promotion follow a refunded or failed payout?
-- For each problem payment, whether the same user later gets a promoted payment. Baseline: delivered payments from before July.
with src as (
    select p.id as sid, p.user_id, p.created_at as s_at, p.amount as samount, p.status as sstatus, r.payout_outcome as sout, r.value_sent_usd as sval
    from payments p
    join remittances r on r.id = p.id
    where (p.status = 'REFUNDED' and r.payout_outcome = 'not_delivered')
        or (p.status = 'SUCCESSFUL' and r.payout_outcome in ('not_delivered', 'in_flight'))
        or (r.is_delivered_remittance and p.created_at < timestamptz '2026-07-01')
),
lk as (
    select s.sid, s.sstatus, s.sout,
        max((f.promo > 0)::int) as any_promo_after, max((f.promo_class = 'fully_funded')::int) as fully_funded_after,
        max((f.promo > 0 and (f.promo = s.samount or f.promo = s.sval))::int) as promo_equals_problem_amount
    from src s
    left join fa f on f.user_id = s.user_id and f.created_at > s.s_at
    group by all
)
select sstatus, sout, count(*) as source_payments, round(100 * avg(any_promo_after), 2) as pct_any_promo_after,
    round(100 * avg(fully_funded_after), 2) as pct_fully_funded_after, sum(promo_equals_problem_amount) as promo_equals_amount_n
from lk
group by all
order by 3 desc;

.print ## 1.23 Beneficiary side: destination amount against charged and promotion
-- Tie = within 1% of destination amount. A payout that excluded the promotion would tie to amount_charged x rate instead.
select case when amount_charged = 0 then 'fully_funded' else 'partial' end as grp, attempt_status, count(*) as receipts,
    sum((abs(destination_amount::double - (amount_charged + promotion_amount)::double * exchange_rate::double) <= 0.01 * destination_amount::double)::int) as ties_charged_plus_promo,
    sum((abs(destination_amount::double - amount_charged::double * exchange_rate::double) <= 0.01 * destination_amount::double)::int) as ties_charged_only,
    sum((disbursement_amount is not null and abs(disbursement_amount::double - (amount_charged + promotion_amount)::double * exchange_rate::double) <= 0.01 * disbursement_amount::double)::int) as provider_amount_ties_charged_plus_promo
from attempts
where promotion_amount > 0
group by all
order by 1, 2;

.print ## 1.24 Beneficiary side: the one partial promotion that does not tie
select country, currency, amount_charged, promotion_amount, exchange_rate, destination_amount, attempt_status
from attempts
where promotion_amount > 0 and abs(destination_amount::double - (amount_charged + promotion_amount)::double * exchange_rate::double) > 0.01 * destination_amount::double;

.print ## 1.25 Refund, chargeback and first-attempt failure rates by promotion class
select promo_class, count(*) as payments, round(100 * avg((pstatus = 'REFUNDED')::int), 2) as refund_pct,
    round(100 * avg(has_chargeback::int), 3) as chargeback_pct, round(100 * avg((first_attempt_status = 'failed')::int), 2) as first_attempt_failed_pct
from fa
where pstatus in ('SUCCESSFUL', 'REFUNDED')
group by 1
order by 1;

.print ## 1.26 Overlap of fully funded users with the no-receipt payments (Q4 link)
select (select count(distinct user_id) from fa where promo_class = 'fully_funded') as fully_funded_users,
    (select count(distinct user_id) from nr) as no_receipt_users,
    (select count(distinct f.user_id) from fa f join nr n on n.user_id = f.user_id where f.promo_class = 'fully_funded') as both,
    (select count(distinct user_id) from payments) as all_users;

.print ## 1.27 Fully funded payments preceded by a successful but undelivered payment of the same user
-- Splits the 1.19 signal by the prior payment's outcome; no_receipt priors are the Q4 population, which only exists from late June.
select r.payout_outcome as prior_outcome, count(distinct ff.payment_id) as fully_funded_payments_with_such_a_prior
from fa ff
join payments o on o.user_id = ff.user_id and o.created_at < ff.created_at
join remittances r on r.id = o.id
where ff.promo_class = 'fully_funded' and o.status = 'SUCCESSFUL' and not r.is_delivered_remittance
group by 1
order by 2 desc;

.print ## 1.28 Check with raw text tables: fully funded receipts and the payment amount
-- Independent of the typed tables: text columns compared after casting.
with rr as (select payment_id, fee from raw_receipts where try_cast(amount_charged as decimal(18, 4)) = 0)
select count(*) as fully_funded_receipts, count(distinct p.id) as payments,
    sum((try_cast(p.amount as decimal(18, 4)) = try_cast(rr.fee as decimal(18, 4)))::int) as payment_amount_equals_fee
from raw_payments p
join rr on rr.payment_id = p.id;

-- ===========================================================================
-- Y1: Headline "amount transacted"
-- ===========================================================================

.print ## 2.01 Candidate measures, extract total
select * from (
    select 1 as ord, 'All payment rows (any status)' as measure, count(*) as payments, round(sum(amount), 2) as usd from payments
    union all select 2, 'SUCCESSFUL payments, payments.amount', count(*), round(sum(amount), 2) from payments where status = 'SUCCESSFUL'
    union all select 3, 'Delivered remittances, customer paid (payments.amount)', count(*), round(sum(pamount), 2) from dr
    union all select 4, 'Delivered, charged + fee from primary receipt', count(*), round(sum(charged + fee), 2) from dr
    union all select 5, 'Delivered, value sent (charged + promotion)', count(*), round(sum(charged + promo), 2) from dr
    union all select 6, 'Delivered, cash principal (charged only, no fee, no promotion)', count(*), round(sum(charged), 2) from dr
    union all select 7, 'Delivered, value sent + fee (gross of promotion)', count(*), round(sum(charged + promo + fee), 2) from dr
    union all select 8, 'Delivered, beneficiary side: destination amount / rate (USD-equivalent)', count(*),
        round((select sum(a.destination_amount / a.exchange_rate) from attempts a join dr using (payment_id) where a.is_primary_attempt and a.exchange_rate > 0 and a.destination_amount > 0), 2) from dr
    union all select 9, 'Receipt-level join, SUCCESSFUL payments x receipts, payments.amount (double counts retries)', count(*), round(sum(p.amount), 2)
        from payments p join receipts r on r.payment_id = p.id where p.status = 'SUCCESSFUL'
) order by ord;

.print ## 2.02 Composition of the gap between customer paid and value sent
select round(sum(pamount), 2) as customer_paid, round(sum(charged + promo), 2) as value_sent,
    round(sum(pamount) - sum(charged + promo), 2) as paid_minus_sent,
    round(sum(fee), 2) as receipt_fees, round(sum(promo), 2) as promotions,
    round(sum(fee) - sum(promo), 2) as fees_minus_promotions,
    round(sum(pamount) - sum(charged + fee), 2) as paid_minus_receipt_paid
from dr;

.print ## 2.03 Monthly measures (UTC payment month), delivered remittances
select date_trunc('month', created_at)::date as month, count(*) as remittances,
    round(sum(pamount) / 1e6, 3) as customer_paid_m, round(sum(charged + promo) / 1e6, 3) as value_sent_m,
    round(sum(charged) / 1e6, 3) as cash_principal_m, round(sum(charged + fee) / 1e6, 3) as receipt_paid_m,
    round(sum(pamount - (charged + promo)) / 1e3, 1) as paid_minus_sent_k,
    round(100 * (sum(pamount) / sum(charged + promo) - 1), 3) as paid_over_sent_pct,
    round(100 * sum(fee) / sum(charged + promo), 3) as fee_pct_of_sent, round(100 * sum(promo) / sum(charged + promo), 3) as promo_pct_of_sent
from dr
group by 1
order by 1;

.print ## 2.04 Month-over-month growth under each measure
with m as (
    select date_trunc('month', created_at)::date as month, sum(pamount) as a, sum(charged + promo) as b, sum(charged) as c
    from dr group by 1
),
g as (select month, a / lag(a) over (order by month) - 1 as ga, b / lag(b) over (order by month) - 1 as gb, c / lag(c) over (order by month) - 1 as gc from m)
select month, round(100 * ga, 2) as paid_mom_pct, round(100 * gb, 2) as sent_mom_pct, round(100 * gc, 2) as cash_mom_pct,
    round(100 * (gb - ga), 3) as sent_minus_paid_pp
from g
order by 1;

.print ## 2.05 Growth from first to last full month (January to August)
select round(100 * (max(a) filter (where month = date '2026-08-01') / max(a) filter (where month = date '2026-01-01') - 1), 2) as paid_growth_pct,
    round(100 * (max(b) filter (where month = date '2026-08-01') / max(b) filter (where month = date '2026-01-01') - 1), 2) as sent_growth_pct
from (select date_trunc('month', created_at)::date as month, sum(pamount) as a, sum(charged + promo) as b from dr group by 1);

.print ## 2.06 Sensitivity of value sent to the primary-attempt rule
-- Alternative attempt choices for the delivered remittances.
with d as (select payment_id from dr),
first_any as (select a.payment_id, a.amount_charged + a.promotion_amount as v, a.fee as f, a.promotion_amount as pr from attempts a join d using (payment_id) where a.attempt_number = 1),
last_del as (
    select payment_id, v, f, pr from (
        select a.payment_id, a.amount_charged + a.promotion_amount as v, a.fee as f, a.promotion_amount as pr,
            row_number() over (partition by a.payment_id order by a.attempt_number desc) as rn
        from attempts a join d using (payment_id) where a.attempt_status = 'delivered'
    ) where rn = 1
),
max_any as (select a.payment_id, max(a.amount_charged + a.promotion_amount) as v from attempts a join d using (payment_id) group by 1)
select 'primary: earliest delivered attempt' as basis, sum(charged + promo) as value_sent, sum(fee) as fee, sum(promo) as promotion from dr
union all select 'first attempt, any status', sum(v), sum(f), sum(pr) from first_any
union all select 'last delivered attempt', sum(v), sum(f), sum(pr) from last_del
union all select 'highest value over attempts', sum(v), null, null from max_any;

.print ## 2.07 Payments where the first attempt and the primary attempt give a different value or fee
select count(*) as delivered_remittances,
    sum(((p.charged + p.promo) <> (f.amount_charged + f.promotion_amount))::int) as value_differs,
    sum((p.fee <> f.fee)::int) as fee_differs,
    sum((p.primary_attempt_no > 1)::int) as primary_is_a_later_attempt
from dr p
join attempts f on f.payment_id = p.payment_id and f.attempt_number = 1;

.print ## 2.08 Beneficiary-side tie of value sent (USD-equivalent of destination and provider amounts)
select round(sum(a.destination_amount / a.exchange_rate), 2) as receipt_destination_usd_equiv,
    round(sum(a.disbursement_amount / a.exchange_rate), 2) as provider_amount_usd_equiv,
    round(sum(a.amount_charged + a.promotion_amount), 2) as value_sent,
    round(sum(a.destination_amount / a.exchange_rate) - sum(a.amount_charged + a.promotion_amount), 2) as destination_minus_sent,
    round(100 * (sum(a.destination_amount / a.exchange_rate) / sum(a.amount_charged + a.promotion_amount) - 1), 4) as destination_minus_sent_pct,
    count(*) as remittances_in_check
from attempts a
join dr using (payment_id)
where a.is_primary_attempt and a.exchange_rate > 0 and a.destination_amount > 0 and a.disbursement_amount > 0;

.print ## 2.09 Where customer paid does not tie to the primary receipt (rounded to cents)
-- gap = payments.amount - (amount_charged + fee). A tie means both sides are equal after rounding to cents (the definition behind the 887 non-ties in the plan).
select case
        when round(pamount, 2) = round(charged + fee, 2) then '0 tie'
        when gap > 0 and fee = 0 and round(gap, 2) in (2.99, 4.98, 5.99, 6.49) then '1 payment carries a standard fee, receipt fee is 0'
        when gap > 0 and fee = 0 then '2 receipt fee is 0, other positive gap'
        when gap > 0 then '3 positive gap, receipt fee above 0'
        when round(gap, 2) = -1 and country = 'SV' then '4 receipt fee $1 above payment, SV'
        else '5 other negative gap'
    end as gap_class,
    count(*) as remittances, round(sum(gap), 2) as net_gap_usd, round(100 * avg((promo > 0)::int), 2) as pct_with_promo,
    sum((attempt_count > 1)::int) as multi_attempt_payments, sum((primary_attempt_no > 1)::int) as primary_not_first_attempt
from dr
group by 1
order by 1;

.print ## 2.10 Non-ties by month
select date_trunc('month', created_at)::date as month, count(*) as remittances,
    sum((round(pamount, 2) <> round(charged + fee, 2))::int) as non_ties,
    sum((round(pamount, 2) <> round(charged + fee, 2) and gap > 0)::int) as positive,
    sum((round(pamount, 2) <> round(charged + fee, 2) and round(gap, 2) = -1)::int) as minus_one_dollar
from dr
group by 1
order by 1;

.print ## 2.11 Users in the 50% volume group under each measure
with a as (select user_id, paid, sum(paid) over (order by rk_paid) as cum, sum(paid) over () as tot from u),
b as (select user_id, sent, sum(sent) over (order by rk_sent) as cum, sum(sent) over () as tot from u),
c as (select user_id, cash, sum(cash) over (order by rk_cash) as cum, sum(cash) over () as tot from u),
ga as (select user_id from a where cum - paid < 0.5 * tot),
gb as (select user_id from b where cum - sent < 0.5 * tot),
gc as (select user_id from c where cum - cash < 0.5 * tot)
select (select count(*) from u) as users, (select count(*) from ga) as top50_customer_paid, (select count(*) from gb) as top50_value_sent,
    (select count(*) from gc) as top50_cash_principal,
    (select count(*) from ga join gb using (user_id)) as in_both_paid_and_sent,
    (select count(*) from ga where user_id not in (select user_id from gb)) as only_in_paid_group,
    (select count(*) from gb where user_id not in (select user_id from ga)) as only_in_sent_group,
    (select min(paid) from u where rk_paid <= (select count(*) from ga)) as paid_cutoff_usd;

.print ## 2.12 Top-k overlap between customer-paid and alternative rankings
select t.k as top_k,
    (select count(*) from u where rk_paid <= t.k and rk_sent <= t.k) as in_both_paid_and_sent,
    (select count(*) from u where rk_paid <= t.k and rk_sent > t.k) as leave_under_value_sent,
    (select count(*) from u where rk_paid <= t.k and rk_cash > t.k) as leave_under_cash_principal
from (values (10), (100), (1000), (10000), (59511)) as t(k)
order by 1;

.print ## 2.13 Rank movement among the top 1,000 customer-paid users
select count(*) as users, sum((rk_paid <> rk_sent)::int) as rank_changed, max(abs(rk_paid - rk_sent)) as max_shift,
    quantile_cont(abs(rk_paid - rk_sent), [0.5, 0.9])::double[] as shift_q50_q90
from u
where rk_paid <= 1000;

.print ## 2.14 Profile of users who cross the 50% line only under customer paid
select count(*) as users, round(avg(n), 1) as avg_remittances, round(avg(paid), 0) as avg_paid, round(avg(sent), 0) as avg_sent,
    round(avg(paid - sent), 1) as avg_paid_minus_sent
from u
where rk_paid <= 59511 and rk_sent > 59100;

-- ===========================================================================
-- Q4: SUCCESSFUL payments without a receipt
-- ===========================================================================

.print ## 3.01 No-receipt SUCCESSFUL payments by type, detailed status and month
select type, detailed_status, date_trunc('month', created_at)::date as month, count(*) as payments, round(sum(amount), 0) as usd,
    count(distinct user_id) as users, sum(has_chargeback::int) as chargebacks
from nr
group by all
order by 3, 1;

.print ## 3.02 Detailed status of regular SUCCESSFUL payments with a receipt
select p.type, p.detailed_status, count(*) as payments
from payments p
join remittances r on r.id = p.id
where p.status = 'SUCCESSFUL' and r.payout_outcome <> 'no_receipt'
group by all
order by 3 desc;

.print ## 3.03 Amount families by month
-- one_dollar: exactly 1.00. six25_family: 6.25 x m - 0.25, 12 to 150. june_round: round amounts before July.
select date_trunc('month', created_at)::date as month, count(*) as payments, round(sum(amount), 0) as usd,
    sum((amount_family = 'one_dollar')::int) as one_dollar, sum((amount_family = 'six25_family')::int) as six25_family,
    sum((amount_family = 'june_round')::int) as june_round, sum((amount_family = 'other')::int) as other
from nr
group by 1
order by 1;

.print ## 3.04 Most common amounts
select amount, count(*) as payments, count(distinct user_id) as users, min(created_at)::date as first_day, max(created_at)::date as last_day
from nr
group by 1
order by 2 desc, 1
limit 20;

.print ## 3.05 Index m of the 6.25 x m - 0.25 family
select round((amount + 0.25) / 6.25)::int as m, round(6.25 * round((amount + 0.25) / 6.25) - 0.25, 2) as amount, count(*) as payments
from nr
where amount_family = 'six25_family'
group by 1, 2
order by 1;

.print ## 3.06 Cents of the amount: no-receipt payments against delivered remittances
-- Regular remittance amounts are principal + fee, so most end in .99, .98 or .49. The six most common endings per group are shown.
select grp, cents, payments, pct
from (
    select grp, cents, payments, round(100 * payments / sum(payments) over (partition by grp), 1) as pct,
        row_number() over (partition by grp order by payments desc) as rn
    from (
        select g as grp, cents, count(*) as payments
        from (
            select case when payout_outcome = 'no_receipt' and status = 'SUCCESSFUL' then 'successful_no_receipt'
                    when payout_outcome = 'delivered' and status = 'SUCCESSFUL' then 'delivered_remittance' end as g,
                round((amount - floor(amount)) * 100)::int as cents
            from pcl
        )
        where g is not null
        group by 1, 2
    )
)
where rn <= 6
order by grp, payments desc;

.print ## 3.07 No-receipt amounts that look like a remittance (cents not .00 .25 .50 .75)
select created_at, amount, type, hr_utc, dow,
    (select count(*) from payments o where o.user_id = nr.user_id and o.id <> nr.payment_id and o.created_at between nr.created_at - interval 1 day and nr.created_at + interval 1 day) as other_payments_within_1_day
from nr
where round((amount - floor(amount)) * 100)::int not in (0, 25, 50, 75)
order by created_at;

.print ## 3.08 Hour of day (UTC) of no-receipt payments against regular delivered remittances in August and September
select h as hour_utc,
    round(100 * sum((g = 'six25_family')::int) / sum(sum((g = 'six25_family')::int)) over (), 1) as pct_six25_family,
    round(100 * sum((g = 'one_dollar')::int) / sum(sum((g = 'one_dollar')::int)) over (), 1) as pct_one_dollar,
    round(100 * sum((g = 'regular')::int) / sum(sum((g = 'regular')::int)) over (), 1) as pct_regular_aug_sep
from (
    select hour(created_at) as h, amount_family as g from nr
    union all
    select hour(created_at), 'regular' from dr where created_at >= timestamptz '2026-08-01'
)
group by 1
order by 1;

.print ## 3.09 Day of week of no-receipt payments against regular delivered remittances (0 = Sunday, 6 = Saturday)
select d as day_of_week,
    round(100 * sum((g = 'six25_family')::int) / sum(sum((g = 'six25_family')::int)) over (), 1) as pct_six25_family,
    round(100 * sum((g = 'one_dollar')::int) / sum(sum((g = 'one_dollar')::int)) over (), 1) as pct_one_dollar,
    round(100 * sum((g = 'regular')::int) / sum(sum((g = 'regular')::int)) over (), 1) as pct_regular_aug_sep
from (
    select dow as d, amount_family as g from nr
    union all
    select dayofweek(created_at), 'regular' from dr where created_at >= timestamptz '2026-08-01'
)
group by 1
order by 1;

.print ## 3.10 Share of each amount family at 11:00 UTC and on Saturdays
select amount_family, count(*) as payments, sum((hr_utc = 11)::int) as at_11_utc, round(100 * avg((hr_utc = 11)::int), 1) as pct_11_utc,
    sum((dow = 6)::int) as on_saturday, round(100 * avg((dow = 6)::int), 1) as pct_saturday,
    sum((hr_utc = 11 and dow = 6)::int) as saturday_11_utc
from nr
group by 1
order by 1;

.print ## 3.11 Saturday 11:00 UTC batches: charges per Saturday, successes and failures (amount family)
-- All payments with a six25 amount and no receipt at 11 UTC, by status.
select created_at::date as day, dayname(created_at) as weekday,
    sum((status = 'SUCCESSFUL')::int) as successful, sum((status = 'FAILED')::int) as failed, sum((status = 'REFUNDED')::int) as refunded,
    strftime(min(created_at), '%H:%M:%S') as first_time, strftime(max(created_at), '%H:%M:%S') as last_time
from pcl
where amount_family = 'six25_family' and payout_outcome = 'no_receipt' and hour(created_at) = 11 and created_at >= timestamptz '2026-07-25'
group by 1, 2
having count(*) >= 20
order by 1;

.print ## 3.12 Weekly series by pattern
select date_trunc('week', created_at)::date as week_start,
    sum((amount_family = 'six25_family' and hr_utc = 11)::int) as six25_at_11_utc,
    sum((amount_family = 'six25_family' and hr_utc <> 11)::int) as six25_other_hours,
    sum((amount_family = 'one_dollar')::int) as one_dollar,
    sum((amount_family in ('june_round', 'other'))::int) as other_amounts
from nr
group by 1
order by 1;

.print ## 3.13 Same amount families among non-successful no-receipt payments, by month
select date_trunc('month', created_at)::date as month, status, amount_family, count(*) as payments
from pcl
where payout_outcome = 'no_receipt' and status in ('FAILED', 'REFUNDED', 'SUCCESSFUL') and created_at >= timestamptz '2026-05-01'
group by all
order by 1, 2, 3;

.print ## 3.14 Failure rate by amount family, no-receipt payments from August
select amount_family, count(*) filter (where status = 'FAILED') as failed, count(*) filter (where status = 'SUCCESSFUL') as successful,
    count(*) filter (where status = 'REFUNDED') as refunded,
    round(100 * count(*) filter (where status = 'FAILED') / count(*), 1) as failed_pct
from pcl
where created_at >= timestamptz '2026-08-01' and payout_outcome = 'no_receipt' and status in ('FAILED', 'SUCCESSFUL', 'REFUNDED')
group by 1
order by 1;

.print ## 3.15 Failure reasons since mid-July: share of failed payments by family
select amount_family, reason, failed, round(100 * failed / sum(failed) over (partition by amount_family), 1) as pct
from (
    select amount_family, replace(coalesce(detailed_status, '(null)'), 'FAILED_DUE_TO_', '') as reason, count(*) as failed
    from pcl
    where status = 'FAILED' and created_at >= timestamptz '2026-07-15'
    group by 1, 2
)
where reason in ('INSUFFICIENT_FUNDS', 'CVV_ERROR', '3DS_CHALLENGE_FAILED', 'SUSPECTED_FRAUD_BY_PROCESSOR', 'STOLEN_CARD', 'EXPIRED_CARD', 'CARD_INVALID', 'INVALID_AMOUNT')
order by 1, 3 desc;

.print ## 3.16 Chargebacks and refunds since July (no-receipt payments)
select amount_family, count(*) filter (where status = 'SUCCESSFUL') as successful, sum(has_chargeback::int) filter (where status = 'SUCCESSFUL') as successful_with_chargeback,
    count(*) filter (where status = 'REFUNDED') as refunded,
    round(100 * count(*) filter (where status = 'REFUNDED') / count(*) filter (where status in ('SUCCESSFUL', 'REFUNDED')), 2) as refund_pct
from pcl
where payout_outcome = 'no_receipt' and created_at >= timestamptz '2026-07-01'
group by 1
order by 1;

.print ## 3.17 Baseline refund and chargeback rates on regular remittances with receipts
select count(*) filter (where status = 'SUCCESSFUL') as successful, round(100 * avg(has_chargeback::int) filter (where status = 'SUCCESSFUL'), 3) as chargeback_pct,
    round(100 * count(*) filter (where status = 'REFUNDED') / count(*), 2) as refund_pct
from pcl
where payout_outcome <> 'no_receipt' and status in ('SUCCESSFUL', 'REFUNDED');

.print ## 3.18 Relation to the same user's other payments: windows around the no-receipt payment
with near as (
    select n.payment_id, n.amount, epoch(o.created_at - n.created_at) / 60 as delta_min, r.is_delivered_remittance as o_delivered,
        o.amount as o_amount, r.fee_usd as o_fee, r.promotion_usd as o_promo, r.value_sent_usd as o_value
    from nr n
    join payments o on o.user_id = n.user_id and o.id <> n.payment_id
    left join remittances r on r.id = o.id
)
select 'other payment of any status within 60 minutes' as relation, count(distinct payment_id) as no_receipt_payments, round(100 * count(distinct payment_id) / (select count(*) from nr), 1) as pct from near where abs(delta_min) <= 60
union all select 'delivered remittance within 60 minutes (either side)', count(distinct payment_id), round(100 * count(distinct payment_id) / (select count(*) from nr), 1) from near where abs(delta_min) <= 60 and o_delivered
union all select 'delivered remittance within 60 minutes before', count(distinct payment_id), round(100 * count(distinct payment_id) / (select count(*) from nr), 1) from near where delta_min between -60 and 0 and o_delivered
union all select 'delivered remittance within 60 minutes after', count(distinct payment_id), round(100 * count(distinct payment_id) / (select count(*) from nr), 1) from near where delta_min between 0 and 60 and o_delivered
union all select 'any other payment within 24 hours', count(distinct payment_id), round(100 * count(distinct payment_id) / (select count(*) from nr), 1) from near where abs(delta_min) <= 1440
union all select 'any other payment within 7 days', count(distinct payment_id), round(100 * count(distinct payment_id) / (select count(*) from nr), 1) from near where abs(delta_min) <= 10080
union all select 'delivered remittance at any earlier time', count(distinct payment_id), round(100 * count(distinct payment_id) / (select count(*) from nr), 1) from near where delta_min < 0 and o_delivered
union all select 'delivered remittance at any later time', count(distinct payment_id), round(100 * count(distinct payment_id) / (select count(*) from nr), 1) from near where delta_min > 0 and o_delivered
union all select 'amount equals another payment amount of the user', count(distinct payment_id), round(100 * count(distinct payment_id) / (select count(*) from nr), 1) from near where abs(o_amount - amount) < 0.005
union all select 'amount equals a receipt fee of the user', count(distinct payment_id), round(100 * count(distinct payment_id) / (select count(*) from nr), 1) from near where abs(o_fee - amount) < 0.005
union all select 'amount equals a promotion of the user', count(distinct payment_id), round(100 * count(distinct payment_id) / (select count(*) from nr), 1) from near where o_promo > 0 and abs(o_promo - amount) < 0.005
union all select 'amount equals value sent of a user remittance', count(distinct payment_id), round(100 * count(distinct payment_id) / (select count(*) from nr), 1) from near where abs(o_value - amount) < 0.005;

.print ## 3.19 Distance to the user's nearest delivered remittance, by family (days)
with x as (
    select n.payment_id, n.amount_family, n.hr_utc,
        (select min(epoch(n.created_at - o.created_at) / 86400) from dr o where o.user_id = n.user_id and o.created_at < n.created_at) as days_since_prev_delivered,
        (select min(epoch(o.created_at - n.created_at) / 86400) from dr o where o.user_id = n.user_id and o.created_at > n.created_at) as days_to_next_delivered,
        (select count(*) from payments o where o.user_id = n.user_id and o.id <> n.payment_id) as other_payments
    from nr n
)
select amount_family, case when hr_utc = 11 then 'at 11 UTC' else 'other hours' end as hour_group, count(*) as payments,
    round(100 * avg((other_payments = 0)::int), 1) as pct_user_has_no_other_payment,
    round(100 * avg((days_since_prev_delivered is not null)::int), 1) as pct_delivered_before,
    round(100 * avg((days_to_next_delivered is not null)::int), 1) as pct_delivered_after,
    round(median(days_since_prev_delivered), 1) as median_days_since_prev_delivered,
    round(median(days_to_next_delivered), 1) as median_days_to_next_delivered
from x
group by all
order by 1, 2;

.print ## 3.20 Baseline: share of regular successful payments in August and September with an earlier delivered remittance or no earlier payment
select count(*) as payments, round(100 * avg((n_prior_all = 0)::int), 1) as pct_first_in_extract
from hist
where status = 'SUCCESSFUL' and grp <> 'no_receipt' and created_at >= timestamptz '2026-08-01';

.print ## 3.21 Repeat frequency: no-receipt successful payments per user
select payments_per_user, count(*) as users
from (select user_id, count(*) as payments_per_user from nr group by 1)
group by 1
order by 1;

.print ## 3.22 Gap between a user's consecutive no-receipt successful payments (days)
with g as (
    select user_id, amount, created_at, lag(created_at) over (partition by user_id order by created_at) as prev_at,
        lag(amount) over (partition by user_id order by created_at) as prev_amount
    from nr
),
b as (
    select epoch(created_at - prev_at) / 86400 as gap_days, amount, prev_amount from g where prev_at is not null
)
select case when gap_days < 1 then 'a 0-1' when gap_days < 7 then 'b 1-7' when gap_days < 14 then 'c 7-14'
        when gap_days < 28 then 'd 14-28' else 'e 28+' end as gap_days,
    count(*) as pairs, sum((amount = prev_amount)::int) as same_amount
from b
group by 1
order by 1;

.print ## 3.23 Six25-family charges per user since July: all statuses
with fam as (select * from pcl where payout_outcome = 'no_receipt' and amount_family = 'six25_family' and created_at >= timestamptz '2026-07-01'),
famu as (
    select user_id, count(*) as events, sum((status = 'SUCCESSFUL')::int) as succ, sum((status = 'FAILED')::int) as failed, count(distinct amount) as distinct_amounts
    from fam group by 1
)
select count(*) as users, sum((events > 1)::int) as users_with_more_than_one_event, sum((succ >= 2)::int) as users_with_two_or_more_successes,
    sum((succ = 0)::int) as users_never_succeeded, sum((succ >= 1 and failed >= 1)::int) as users_with_failure_then_or_and_success,
    sum((distinct_amounts > 1)::int) as users_with_changing_amount
from famu;

.print ## 3.24 Saturday batch users who were also in the previous week's batch
with fam as (select * from pcl where payout_outcome = 'no_receipt' and amount_family = 'six25_family' and hour(created_at) = 11 and created_at >= timestamptz '2026-07-25'),
s as (select user_id, date_trunc('week', created_at)::date as wk from fam group by all)
select a.wk as week_start, count(*) as users, sum((b.user_id is not null)::int) as also_in_previous_week
from s a
left join s b on b.user_id = a.user_id and b.wk = a.wk - interval 7 days
group by 1
order by 1;

.print ## 3.25 One-dollar payments: no-receipt against regular remittances with receipts
-- Regular one-dollar payments have receipts (principal 1.00, fee 0) all year; the no-receipt ones start in July.
select 'with receipt' as grp, date_trunc('month', p.created_at)::date as month, count(*) as payments,
    sum((p.status = 'REFUNDED')::int) as refunded
from payments p
join attempts a on a.payment_id = p.id and a.attempt_number = 1
where p.amount = 1
group by 1, 2
union all
select 'no receipt (any status)', date_trunc('month', created_at)::date, count(*), sum((status = 'REFUNDED')::int)
from pcl
where amount = 1 and payout_outcome = 'no_receipt'
group by 1, 2
order by 1, 2;

.print ## 3.26 Other amounts of the families among regular receipted payments
select amount_family, status, payout_outcome, count(*) as payments, min(created_at)::date as first_day, max(created_at)::date as last_day
from pcl
where amount_family <> 'other' and payout_outcome <> 'no_receipt'
group by all
order by 1, 4 desc;

.print ## 3.27 Retry cadence: consecutive six25-family events of one user (all statuses, from late July)
-- Pairs seen at least 8 times. All repeated events keep the amount and happen at 11:00 UTC.
with fam as (select * from pcl where payout_outcome = 'no_receipt' and amount_family = 'six25_family' and created_at >= timestamptz '2026-07-25'),
g as (
    select user_id, status, created_at, amount,
        lag(created_at) over (partition by user_id order by created_at) as prev_at,
        lag(status) over (partition by user_id order by created_at) as prev_status,
        lag(amount) over (partition by user_id order by created_at) as prev_amount
    from fam
)
select prev_status, status, round(epoch(created_at - prev_at) / 86400)::int as gap_days, hour(created_at) as hour_utc, count(*) as pairs,
    sum((amount = prev_amount)::int) as same_amount
from g
where prev_at is not null
group by all
having count(*) >= 8
order by pairs desc, gap_days;

.print ## 3.28 Overlap of no-receipt users with fully funded promotions, by family
select n.amount_family, count(*) as payments,
    round(100 * avg(coalesce(x.b, 0)), 2) as pct_user_had_fully_funded_before,
    round(100 * avg(coalesce(x.a, 0)), 2) as pct_user_gets_fully_funded_after
from nr n
left join (
    select n2.payment_id, max((f.created_at < n2.created_at)::int) as b, max((f.created_at > n2.created_at)::int) as a
    from nr n2 join fa f on f.user_id = n2.user_id and f.promo_class = 'fully_funded' group by 1
) x on x.payment_id = n.payment_id
group by 1
order by 1;

.print ## 3.29 Baseline for 3.28: delivered remittances from August
select count(*) as payments, round(100 * avg(coalesce(x.b, 0)), 2) as pct_user_had_fully_funded_before, round(100 * avg(coalesce(x.a, 0)), 2) as pct_user_gets_fully_funded_after
from dr d
left join (
    select d2.payment_id, max((f.created_at < d2.created_at)::int) as b, max((f.created_at > d2.created_at)::int) as a
    from dr d2 join fa f on f.user_id = d2.user_id and f.promo_class = 'fully_funded' where d2.created_at >= timestamptz '2026-08-01' group by 1
) x on x.payment_id = d.payment_id
where d.created_at >= timestamptz '2026-08-01';

.print ## 3.30 Overlap of one-dollar users and six25-family users (no-receipt payments since July, any status)
-- Active users = users with any payment from August on. Independence would give about fam_users x one_users / active_users.
with fam as (select user_id, min(created_at) as first_event from pcl where payout_outcome = 'no_receipt' and amount_family = 'six25_family' and created_at >= timestamptz '2026-07-01' group by 1),
one as (select user_id, min(created_at) as first_event from pcl where payout_outcome = 'no_receipt' and amount_family = 'one_dollar' and created_at >= timestamptz '2026-07-01' group by 1)
select (select count(*) from fam) as six25_users, (select count(*) from one) as one_dollar_users,
    (select count(*) from fam join one using (user_id)) as users_in_both,
    (select count(*) from fam join one using (user_id) where one.first_event < fam.first_event) as one_dollar_first,
    (select count(*) from fam join one using (user_id) where one.first_event > fam.first_event) as six25_first,
    round((select count(*) from fam) * (select count(*) from one) / (select count(distinct user_id) from payments where created_at >= timestamptz '2026-08-01')::double, 1) as expected_if_independent;

.print ## 3.31 Remittance context of six25-family users at their first six25 event
with fam as (select user_id, min(created_at) as first_event from pcl where payout_outcome = 'no_receipt' and amount_family = 'six25_family' and created_at >= timestamptz '2026-07-01' group by 1)
select count(*) as users,
    sum((exists (select 1 from payments o where o.user_id = f.user_id and o.created_at < f.first_event))::int) as with_any_earlier_payment,
    sum((exists (select 1 from dr o where o.user_id = f.user_id and o.created_at < f.first_event))::int) as with_earlier_delivered,
    sum((exists (select 1 from dr o where o.user_id = f.user_id and o.created_at between f.first_event - interval 7 days and f.first_event))::int) as delivered_in_prior_7_days,
    sum((exists (select 1 from dr o where o.user_id = f.user_id and o.created_at between f.first_event - interval 35 days and f.first_event - interval 7 days))::int) as delivered_7_to_35_days_before
from fam f;

.print ## 3.32 Right-censoring: lag from payment creation to first receipt
with l as (select p.id, p.created_at, min(a.attempt_at) as first_receipt_at from payments p join attempts a on a.payment_id = p.id where p.status = 'SUCCESSFUL' group by 1, 2)
select count(*) as successful_with_receipt,
    quantile_cont(epoch(first_receipt_at - created_at), [0.5, 0.9, 0.99, 0.999, 1])::decimal(14, 1)[] as lag_seconds_q50_90_99_999_max,
    sum((epoch(first_receipt_at - created_at) > 3600)::int) as over_1_hour,
    sum((epoch(first_receipt_at - created_at) > 86400)::int) as over_1_day,
    sum((first_receipt_at < created_at)::int) as receipt_before_payment
from l;

.print ## 3.33 Right-censoring: no-receipt share of SUCCESSFUL payments by age at extract end (September payments)
-- Age 14 is "14 days or older". A censoring problem would raise the share for the youngest ages.
select least(floor(epoch(timestamptz '2026-09-22 14:07:30+00' - created_at) / 86400), 14)::int as age_days, count(*) as successful,
    sum((payout_outcome = 'no_receipt')::int) as no_receipt, round(100 * avg((payout_outcome = 'no_receipt')::int), 3) as pct,
    sum((payout_outcome = 'no_receipt' and round((amount - floor(amount)) * 100)::int not in (0, 25, 50, 75))::int) as no_receipt_remittance_shaped
from remittances
where status = 'SUCCESSFUL' and created_at >= timestamptz '2026-09-01'
group by 1
order by 1;

.print ## 3.34 Right-censoring: end of extract
select max(created_at) as last_payment, (select max(created_at) from receipts) as last_receipt, (select max(created_at) from disbursements) as last_disbursement,
    (select count(*) from nr where created_at > timestamptz '2026-09-22 14:07:30+00' - interval 12 minutes) as no_receipt_in_last_12_minutes
from payments;

.print ## 3.35 Age of the oldest weekly-batch charges at extract end
select min(created_at) as first_batch_charge, round(epoch(timestamptz '2026-09-22 14:07:30+00' - min(created_at)) / 86400, 1) as age_days_at_extract_end
from nr
where amount_family = 'six25_family' and hr_utc = 11;

.print ## 3.36 Other no-receipt payments that are not SUCCESSFUL
select p.status, p.type, coalesce(p.detailed_status, '(null)') as detailed_status, count(*) as payments, min(p.created_at)::date as first_day, round(sum(p.amount), 0) as usd
from payments p
join remittances r on r.id = p.id
where r.payout_outcome = 'no_receipt' and p.status <> 'FAILED'
group by all
order by 4 desc;

.print ## 3.37 Check with raw text tables: no-receipt SUCCESSFUL payments at 11:00 UTC and on Saturday
-- Independent of the typed tables: hour from the timestamp text, weekday from a parsed date. The six25 test uses a text cast.
with p as (
    select id, try_cast(amount as decimal(18, 4)) as amt, substr(created_at, 12, 2) as hh, dayofweek(cast(substr(created_at, 1, 10) as date)) as dow
    from raw_payments
    where status = 'SUCCESSFUL' and id not in (select payment_id from raw_receipts)
)
select count(*) as no_receipt_successful, sum((hh = '11')::int) as at_11, sum((dow = 6)::int) as on_saturday,
    sum((amt = 1)::int) as exactly_1, sum(((amt + 0.25) % 6.25 = 0 and amt between 12 and 150)::int) as six25_family,
    sum((hh = '11' and dow = 6 and (amt + 0.25) % 6.25 = 0 and amt between 12 and 150)::int) as six25_saturday_11
from p;
