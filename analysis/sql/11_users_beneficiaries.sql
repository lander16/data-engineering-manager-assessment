set timezone = 'UTC';

-- Research for open questions Q1/F1 (beneficiaries), Y2 (recurring) and Y3 (top-user window).
-- Needs the helper tables from 10_research_setup.sql (attempts, remittances).
-- Everything below is read-only; temp tables live in memory only.

-- Shared temp tables -------------------------------------------------------

-- One row per delivered remittance (payment level), with the corridor of its primary attempt.
create temp table dr as
select r.id, r.user_id, r.created_at as t, r.payment_month as mo, r.amount as usd, a.country
from remittances r
left join attempts a on a.payment_id = r.id and a.is_primary_attempt
where r.is_delivered_remittance;

-- Consecutive attempts of the same payment (retry chain steps).
create temp table pairs as
select a.payment_id, a.user_id, a.attempt_number as n1,
    a.beneficiary_id as b1, b.beneficiary_id as b2,
    a.beneficiary_id <> b.beneficiary_id as ben_chg,
    a.provider is distinct from b.provider as prov_chg,
    a.payout_type is distinct from b.payout_type as type_chg,
    a.payer_destination_name is distinct from b.payer_destination_name as payer_chg,
    a.country is distinct from b.country as ctry_chg,
    a.attempt_status as s1,
    epoch(b.attempt_at) - epoch(a.attempt_at) as gap_s,
    b.attempt_at as t2
from attempts a
join attempts b on b.payment_id = a.payment_id and b.attempt_number = a.attempt_number + 1;

-- Per user and beneficiary: payments touched and first sighting.
create temp table benuse as
select beneficiary_id, user_id, count(distinct payment_id) as pays, min(attempt_at) as first_at
from attempts
group by 1, 2;

-- Delivered primary attempts, the base for cross-user link tests.
create temp table d as
select row_number() over () as rid, a.user_id, a.payer_destination_name as payer, a.country,
    a.payout_type as ty, a.destination_amount as dest_amt, a.attempt_at as t, p.amount as usd
from attempts a
join payments p on p.id = a.payment_id
where a.is_primary_attempt;

-- Q1: what a beneficiary_id represents -----------------------------------

.print ## Q1.1 Beneficiary ids, users and sharing
select count(distinct beneficiary_id) as beneficiary_ids,
    count(distinct user_id) as users,
    count(distinct payment_id) as payments,
    (select count(*) from (select beneficiary_id from benuse group by 1 having count(*) > 1)) as ids_with_more_than_one_user
from attempts;

.print ## Q1.2 Payments by attempt count and beneficiary id changes
with c as (
    select payment_id, count(*) as attempts, count(distinct beneficiary_id) as distinct_ids
    from attempts group by 1
)
select attempts, count(*) as payments, sum((distinct_ids > 1)::int) as id_changed,
    round(100.0 * avg((distinct_ids > 1)::int), 1) as pct_changed
from c group by 1 order by 1;

.print ## Q1.3 What else changes between consecutive attempts when the id changes
select ben_chg as id_changed, count(*) as attempt_pairs,
    round(100.0 * avg(prov_chg::int), 1) as pct_provider_changed,
    round(100.0 * avg(type_chg::int), 1) as pct_payout_type_changed,
    round(100.0 * avg(payer_chg::int), 1) as pct_payer_changed,
    round(100.0 * avg(ctry_chg::int), 2) as pct_country_changed,
    round(100.0 * avg((s1 = 'failed')::int), 1) as pct_previous_failed,
    round(100.0 * avg((s1 = 'cancelled')::int), 1) as pct_previous_cancelled,
    round(median(gap_s) / 60, 1) as median_gap_minutes
from pairs group by 1 order by 1 desc;

.print ## Q1.4 Chance the id changes, by other changes and by gap
select 'payer changed' as dim, payer_chg::varchar as value, count(*) as pairs, round(100.0 * avg(ben_chg::int), 1) as pct_id_changed from pairs group by all
union all select 'payout type changed', type_chg::varchar, count(*), round(100.0 * avg(ben_chg::int), 1) from pairs group by all
union all select 'provider changed', prov_chg::varchar, count(*), round(100.0 * avg(ben_chg::int), 1) from pairs group by all
union all select 'gap under 10 minutes', null, count(*), round(100.0 * avg(ben_chg::int), 1) from pairs where gap_s < 600
union all select 'gap 10 minutes to 1 day', null, count(*), round(100.0 * avg(ben_chg::int), 1) from pairs where gap_s >= 600 and gap_s < 86400
union all select 'gap 1 day or more', null, count(*), round(100.0 * avg(ben_chg::int), 1) from pairs where gap_s >= 86400
order by 1, 2;

.print ## Q1.5 Where a changed id points
select (select pays from benuse where beneficiary_id = p.b2) > 1 as new_id_used_on_other_payments,
    (select pays from benuse where beneficiary_id = p.b1) > 1 as old_id_used_on_other_payments,
    (select first_at from benuse where beneficiary_id = p.b2) < p.t2 as new_id_seen_before_this_attempt,
    count(*) as id_changes
from pairs p where p.ben_chg group by all order by 1, 2, 3;

.print ## Q1.6 Chains that return to an id they already used
with c as (
    select payment_id, beneficiary_id, attempt_number,
        lag(beneficiary_id) over (partition by payment_id order by attempt_number) as prev_id,
        min(attempt_number) over (partition by payment_id, beneficiary_id) as first_n
    from attempts
)
select count(distinct payment_id) as chains_returning_to_earlier_id,
    (select count(distinct payment_id) from pairs where ben_chg) as chains_with_any_change
from c where prev_id is not null and beneficiary_id <> prev_id and first_n < attempt_number;

.print ## Q1.7 Reuse of ids by the same user across payments
with first_attempt as (
    select a.payment_id, a.user_id, a.beneficiary_id, a.attempt_at,
        min(a.attempt_at) over (partition by a.payment_id) as pay_t0
    from attempts a where a.attempt_number = 1
),
flags as (
    select f.*,
        exists (select 1 from attempts x
                join (select payment_id, min(attempt_at) as t0 from attempts group by 1) px using (payment_id)
                where x.user_id = f.user_id and x.beneficiary_id = f.beneficiary_id and px.t0 < f.pay_t0) as id_used_before,
        exists (select 1 from (select user_id, min(attempt_at) as t0 from attempts group by user_id, payment_id) py
                where py.user_id = f.user_id and py.t0 < f.pay_t0) as user_has_earlier_payment
    from first_attempt f
)
select user_has_earlier_payment, id_used_before, count(*) as payments,
    round(100.0 * count(*) / sum(count(*)) over (partition by user_has_earlier_payment), 1) as pct_within_group
from flags group by 1, 2 order by 1, 2;

.print ## Q1.8 Payments per beneficiary id
with b as (select beneficiary_id, count(distinct payment_id) as pays from attempts group by 1)
select least(pays, 10) as payments_bucket_10_is_10_plus, count(*) as ids,
    round(100.0 * count(*) / sum(count(*)) over (), 2) as pct
from b group by 1 order by 1;

.print ## Q1.9 Stability of an id's destination, first attempts only
with f as (select * from attempts where attempt_number = 1),
b as (
    select beneficiary_id, count(*) as pays, count(distinct payer_destination_name) as payers,
        count(distinct payout_type) as types, count(distinct provider) as providers, count(distinct country) as countries
    from f group by 1
)
select pays >= 2 as two_or_more_payments, count(*) as ids,
    round(100.0 * avg((payers > 1)::int), 1) as pct_more_than_one_payer,
    round(100.0 * avg((types > 1)::int), 1) as pct_more_than_one_payout_type,
    round(100.0 * avg((providers > 1)::int), 1) as pct_more_than_one_provider,
    sum((countries > 1)::int) as ids_in_more_than_one_country
from b group by 1 order by 1;

-- Q1: can a cross-user link be built? ---------------------------------------

.print ## Q1.10 Users per payer and country (payer_destination_name looks like an institution)
with cell as (
    select payer_destination_name as payer, country, count(distinct user_id) as users, count(distinct beneficiary_id) as ids
    from attempts group by 1, 2
)
select case when users = 1 then '1 user' when users <= 5 then '2-5 users' when users <= 20 then '6-20 users' else '21+ users' end as users_in_cell,
    count(*) as payer_country_cells, sum(users) as users, sum(ids) as beneficiary_ids,
    sum(users * (users - 1) / 2) as user_pairs_sharing_cell
from cell group by 1 order by min(users);

.print ## Q1.11 Rare payer cells (2 to 20 users): do any user pairs look linked
create temp table rare as
select a.user_id, a.payer_destination_name as payer, a.country, a.destination_amount as amt, a.attempt_at as t, c.users
from attempts a
join (select payer_destination_name as payer, country, count(distinct user_id) as users from attempts group by 1, 2) c
    on c.payer = a.payer_destination_name and c.country = a.country
where c.users between 2 and 20 and a.is_primary_attempt;

with pr as (
    select a.users, a.user_id as ua, b.user_id as ub,
        min(abs(epoch(a.t) - epoch(b.t))) / 3600 as min_gap_hours,
        max((a.amt = b.amt)::int) as same_amount_ever,
        max((a.amt = b.amt and abs(epoch(a.t) - epoch(b.t)) <= 86400)::int) as same_amount_within_1d,
        max((abs(epoch(a.t) - epoch(b.t)) <= 3600)::int) as any_within_1h
    from rare a join rare b on a.payer = b.payer and a.country = b.country and a.user_id < b.user_id
    group by a.payer, a.country, a.users, a.user_id, b.user_id
)
select case when users <= 5 then '2-5 users' else '6-20 users' end as cell_size, count(*) as user_pairs,
    sum(same_amount_ever) as same_amount_ever, sum(same_amount_within_1d) as same_amount_within_1d,
    sum(any_within_1h) as any_payment_within_1h, round(median(min_gap_hours), 0) as median_closest_gap_hours
from pr group by 1 order by 1;

.print ## Q1.12 Candidate rule: same payer, country, type, exact local amount, within 10 minutes, different users
-- Observed pairs against a null that shuffles timestamps among payments in the same
-- payer, country and type within 3-hour blocks (3 seeds). The null keeps payer, amount mix, time of day
-- and traffic level, and breaks only the minute-level coincidence. Tiers rank how common the USD amount is.
create temp table pop as
select country, usd, count(*) * 1.0 / sum(count(*)) over (partition by country) as share
from d group by 1, 2;

create temp table d2 as
select d.*, floor(epoch(d.t) / 10800) as blk,
    case when share >= 0.02 then 'A common (2% or more of country)'
         when share >= 0.002 then 'B mid (0.2% to 2%)'
         when share >= 0.0002 then 'C rare (0.02% to 0.2%)'
         else 'D very rare (under 0.02%)' end as tier
from d join pop using (country, usd);

create temp table shuf as
with s as (select unnest([1, 2, 3]) as seed),
a as (
    select d2.rid, s.seed, d2.payer, d2.country, d2.ty, d2.blk,
        row_number() over (partition by d2.payer, d2.country, d2.ty, d2.blk, s.seed order by hash(d2.rid + s.seed * 1000003)) as k
    from d2 cross join s
),
b as (
    select s.seed, d2.t, d2.payer, d2.country, d2.ty, d2.blk,
        row_number() over (partition by d2.payer, d2.country, d2.ty, d2.blk, s.seed order by d2.rid) as k
    from d2 cross join s
)
select d2.rid, a.seed, d2.user_id, d2.payer, d2.country, d2.ty, d2.dest_amt, d2.tier, b.t
from d2
join a on a.rid = d2.rid
join b on b.seed = a.seed and b.payer = a.payer and b.country = a.country and b.ty = a.ty and b.blk = a.blk and b.k = a.k;

create temp table obs as
select x.tier, count(*) as pairs
from d2 x join d2 y on x.payer = y.payer and x.country = y.country and x.ty = y.ty and x.dest_amt = y.dest_amt
    and x.rid < y.rid and x.user_id <> y.user_id and abs(epoch(x.t) - epoch(y.t)) <= 600
group by x.tier;

create temp table nul as
select x.seed, x.tier, count(*) as pairs
from shuf x join shuf y on x.seed = y.seed and x.payer = y.payer and x.country = y.country and x.ty = y.ty and x.dest_amt = y.dest_amt
    and x.rid < y.rid and x.user_id <> y.user_id and abs(epoch(x.t) - epoch(y.t)) <= 600
group by x.seed, x.tier;

select o.tier, o.pairs as observed_pairs, round(avg(n.pairs)) as shuffled_pairs_avg,
    round(o.pairs / avg(n.pairs), 2) as observed_over_shuffled,
    round(100.0 * (o.pairs - avg(n.pairs)) / o.pairs, 1) as max_pct_real_links
from obs o join nul n using (tier) group by o.tier, o.pairs
union all
select 'ALL', sum(o.pairs), round((select avg(t) from (select sum(pairs) as t from nul group by seed))),
    round(sum(o.pairs) / (select avg(t) from (select sum(pairs) as t from nul group by seed)), 2),
    round(100.0 * (sum(o.pairs) - (select avg(t) from (select sum(pairs) as t from nul group by seed))) / sum(o.pairs), 1)
from obs o
order by 1;

.print ## Q1.13 Same rule, sensitivity to the width of the shuffle block (seed 1, 10-minute window)
create temp table sens as
with v as (select unnest(['1 hour', '3 hours', '1 day']) as variant, unnest([3600, 10800, 86400]) as width),
base as (select d2.*, v.variant, floor(epoch(d2.t) / v.width) as stratum from d2 cross join v),
a as (
    select rid, variant, row_number() over (partition by variant, payer, country, ty, stratum order by hash(rid + 1000003)) as k, payer, country, ty, stratum
    from base
),
b as (
    select variant, t, payer, country, ty, stratum, row_number() over (partition by variant, payer, country, ty, stratum order by rid) as k
    from base
),
sh as (
    select base.variant, base.rid, base.user_id, base.payer, base.country, base.ty, base.dest_amt, b.t
    from base join a on a.rid = base.rid and a.variant = base.variant
    join b on b.variant = a.variant and b.payer = a.payer and b.country = a.country and b.ty = a.ty and b.stratum = a.stratum and b.k = a.k
)
select x.variant, count(*) as shuffled_pairs
from sh x join sh y on x.variant = y.variant and x.payer = y.payer and x.country = y.country and x.ty = y.ty and x.dest_amt = y.dest_amt
    and x.rid < y.rid and x.user_id <> y.user_id and abs(epoch(x.t) - epoch(y.t)) <= 600
group by x.variant;

select s.variant as shuffle_block, s.shuffled_pairs, (select sum(pairs) from obs) as observed_pairs,
    round(100.0 * (1 - s.shuffled_pairs / (select sum(pairs) from obs)), 1) as max_pct_real_links
from sens s order by s.shuffled_pairs;

-- Q1: user-level signals relevant to fraud, AML and household purposes ------

.print ## Q1.14 Beneficiaries per user under three counting rules
with ub as (
    select user_id,
        count(distinct beneficiary_id) as ids_all_attempts,
        count(distinct case when attempt_number = 1 then beneficiary_id end) as ids_first_attempts,
        count(distinct case when is_primary_attempt then beneficiary_id end) as ids_delivered
    from attempts group by 1
)
select seg, sum((ids_all_attempts_seg = seg)::int) as all_attempts, sum((ids_first_seg = seg)::int) as first_attempts, sum((ids_delivered_seg = seg)::int) as delivered_primary
from (
    select s.seg,
        case when ids_all_attempts = 1 then '1' when ids_all_attempts <= 3 then '2-3' when ids_all_attempts <= 9 then '4-9' else '10+' end as ids_all_attempts_seg,
        case when ids_first_attempts = 1 then '1' when ids_first_attempts <= 3 then '2-3' when ids_first_attempts <= 9 then '4-9' else '10+' end as ids_first_seg,
        case when ids_delivered = 0 then '0' when ids_delivered = 1 then '1' when ids_delivered <= 3 then '2-3' when ids_delivered <= 9 then '4-9' else '10+' end as ids_delivered_seg
    from ub cross join (select unnest(['0', '1', '2-3', '4-9', '10+']) as seg) s
)
group by seg order by case seg when '0' then 0 when '1' then 1 when '2-3' then 2 when '4-9' then 3 else 4 end;

.print ## Q1.15 Users whose segment rises only because retries created new ids
with ub as (
    select user_id, count(distinct beneficiary_id) as ids_all,
        count(distinct case when attempt_number = 1 then beneficiary_id end) as ids_first
    from attempts group by 1
)
select count(*) as users, sum((ids_all > ids_first)::int) as users_with_extra_ids_from_retries,
    sum((ids_all >= 4)::int) as users_4plus_all_attempts, sum((ids_first >= 4)::int) as users_4plus_first_attempts,
    max(ids_all) as max_ids_all, max(ids_first) as max_ids_first
from ub;

.print ## Q1.16 Beneficiaries per user by corridor, first attempts
with uc as (
    select user_id, country, count(distinct beneficiary_id) as ids, count(distinct payment_id) as pays
    from attempts where attempt_number = 1 group by 1, 2
)
select country, count(*) as user_corridors, sum(pays) as payments, round(avg(ids), 2) as mean_ids,
    round(100.0 * avg((ids >= 2)::int), 1) as pct_2plus, round(100.0 * avg((ids >= 4)::int), 2) as pct_4plus, max(ids) as max_ids
from uc group by 1 order by 2 desc;

.print ## Q1.17 Users by number of destination countries
select countries, count(*) as users
from (select user_id, count(distinct country) as countries from attempts group by 1)
group by 1 order by 1;

.print ## Q1.18 Speed of new beneficiaries per user (users with 3 or more ids, first attempts)
create temp table fs as
select user_id, beneficiary_id, min(attempt_at) as first_at
from attempts where attempt_number = 1 group by 1, 2;

create temp table vel as
select user_id, max(c24) as max_24h, max(c7) as max_7d, max(c30) as max_30d
from (
    select a.user_id,
        (select count(*) from fs b where b.user_id = a.user_id and b.first_at >= a.first_at and b.first_at < a.first_at + interval 1 day) as c24,
        (select count(*) from fs b where b.user_id = a.user_id and b.first_at >= a.first_at and b.first_at < a.first_at + interval 7 day) as c7,
        (select count(*) from fs b where b.user_id = a.user_id and b.first_at >= a.first_at and b.first_at < a.first_at + interval 30 day) as c30
    from fs a where a.user_id in (select user_id from fs group by 1 having count(*) >= 3)
)
group by 1;

select 'users with 3+ ids' as measure, count(*) as users from vel
union all select 'new ids in any 24h: 3 or more', sum((max_24h >= 3)::int) from vel
union all select 'new ids in any 24h: 5 or more', sum((max_24h >= 5)::int) from vel
union all select 'new ids in any 7d: 5 or more', sum((max_7d >= 5)::int) from vel
union all select 'new ids in any 30d: 5 or more', sum((max_30d >= 5)::int) from vel
union all select 'new ids in any 30d: 10 or more', sum((max_30d >= 10)::int) from vel;

-- Y2: recurring definition ---------------------------------------------------

-- Consecutive delivered remittances per user, and per-user summaries.
create temp table g as
select user_id, id, t, country, mo, lag(t) over w as prev_t, epoch(t - lag(t) over w) / 86400.0 as gap_d
from dr window w as (partition by user_id order by t, id);

create temp table u as
select user_id, count(*) as n, count(distinct mo) as m, count(distinct cast(t as date)) as ndays,
    min(t) as first_t, max(t) as last_t, epoch(max(t) - min(t)) / 86400.0 as span_d
from dr group by 1;

create temp table endt as select max(created_at) as e from payments;

.print ## Y2.1 Users qualifying under each rule, full extract
select 'delivered users' as rule, count(*) as users, null as pct from u
union all select '2+ remittances', sum((n >= 2)::int), round(100.0 * avg((n >= 2)::int), 1) from u
union all select '2+ distinct UTC days', sum((ndays >= 2)::int), round(100.0 * avg((ndays >= 2)::int), 1) from u
union all select '2+ calendar months', sum((m >= 2)::int), round(100.0 * avg((m >= 2)::int), 1) from u
union all select '3+ calendar months', sum((m >= 3)::int), round(100.0 * avg((m >= 3)::int), 1) from u
union all select 'two sends at least 7 days apart', sum((span_d >= 7)::int), round(100.0 * avg((span_d >= 7)::int), 1) from u
union all select 'two sends at least 14 days apart', sum((span_d >= 14)::int), round(100.0 * avg((span_d >= 14)::int), 1) from u
union all select 'two sends at least 28 days apart', sum((span_d >= 28)::int), round(100.0 * avg((span_d >= 28)::int), 1) from u
union all select 'two sends at least 60 days apart', sum((span_d >= 60)::int), round(100.0 * avg((span_d >= 60)::int), 1) from u;

.print ## Y2.2 Gap between consecutive delivered remittances
select count(*) as gaps, round(quantile_cont(gap_d, 0.05), 2) as p05, round(quantile_cont(gap_d, 0.10), 2) as p10,
    round(quantile_cont(gap_d, 0.25), 1) as p25, round(median(gap_d), 1) as p50, round(quantile_cont(gap_d, 0.75), 1) as p75,
    round(quantile_cont(gap_d, 0.90), 1) as p90, round(100.0 * avg((gap_d < 1)::int), 1) as pct_under_1d,
    round(100.0 * avg((gap_d < 7)::int), 1) as pct_under_7d, round(100.0 * avg((gap_d < 14)::int), 1) as pct_under_14d
from g where gap_d is not null;

.print ## Y2.3 Gap histogram in days (gaps starting before 2026-03-01)
select cast(floor(gap_d) as int) as gap_day, count(*) as gaps
from g where gap_d is not null and prev_t < timestamptz '2026-03-01' and gap_d < 50
group by 1 order by 1;

.print ## Y2.4 Gap by corridor (corridor of the later remittance)
select country, count(*) as gaps, round(quantile_cont(gap_d, 0.25), 1) as p25, round(median(gap_d), 1) as p50,
    round(quantile_cont(gap_d, 0.75), 1) as p75, round(100.0 * avg((gap_d < 7)::int), 1) as pct_under_7d,
    round(100.0 * avg((gap_d < 28)::int), 1) as pct_under_28d
from g where gap_d is not null group by 1 order by 2 desc;

.print ## Y2.5 Gap by first-month cohort (shrinks for late cohorts because of censoring)
select cast(date_trunc('month', f.first_t) as date) as cohort, count(distinct g.user_id) as users_with_a_gap, count(*) as gaps,
    round(median(gap_d), 1) as median_gap_d, round(100.0 * avg((gap_d < 7)::int), 1) as pct_under_7d
from g join (select user_id, min(t) as first_t from dr group by 1) f using (user_id)
where gap_d is not null group by 1 order by 1;

.print ## Y2.6 Two-month qualifiers by span between first and last send
select 'qualify by 2+ calendar months' as measure, count(*) as users, null as pct from u where m >= 2
union all select '... span under 1 day', count(*), round(100.0 * count(*) / (select count(*) from u where m >= 2), 2) from u where m >= 2 and span_d < 1
union all select '... span under 3 days', count(*), round(100.0 * count(*) / (select count(*) from u where m >= 2), 2) from u where m >= 2 and span_d < 3
union all select '... span under 7 days', count(*), round(100.0 * count(*) / (select count(*) from u where m >= 2), 2) from u where m >= 2 and span_d < 7
union all select '... span under 14 days', count(*), round(100.0 * count(*) / (select count(*) from u where m >= 2), 2) from u where m >= 2 and span_d < 14
union all select '... span under 28 days', count(*), round(100.0 * count(*) / (select count(*) from u where m >= 2), 2) from u where m >= 2 and span_d < 28
union all select 'one month but span 28 days or more', count(*), null from u where m = 1 and span_d >= 28
union all select 'one month but span 14 days or more', count(*), null from u where m = 1 and span_d >= 14;

.print ## Y2.6b Users with exactly two delivered remittances: months and gap
select count(*) as two_send_users, sum((m = 2)::int) as in_two_months,
    sum((m = 2 and span_d < 3)::int) as two_months_gap_under_3d, sum((m = 2 and span_d < 7)::int) as two_months_gap_under_7d,
    sum((m = 1 and span_d >= 14)::int) as one_month_gap_14d_or_more
from u where n = 2;

.print ## Y2.7 Check of Y2.6 through summed gaps, and boundary-straddling pairs under 3 days
select (select count(*) from (
            select user_id from g group by 1
            having count(distinct mo) >= 2 and sum(gap_d) < 3)) as users_2_months_span_under_3d_via_gaps,
    (select count(distinct user_id) from g
     where gap_d < 3 and date_trunc('month', t) <> date_trunc('month', prev_t)) as users_with_any_month_straddling_pair_under_3d;

.print ## Y2.8 Rule share by first-month cohort, full extract (not comparable across cohorts)
select cast(date_trunc('month', first_t) as date) as cohort, count(*) as users,
    round(100.0 * avg((n >= 2)::int), 1) as pct_2plus_sends, round(100.0 * avg((m >= 2)::int), 1) as pct_2_months,
    round(100.0 * avg((m >= 3)::int), 1) as pct_3_months, round(100.0 * avg((span_d >= 14)::int), 1) as pct_span_14d,
    round(100.0 * avg((span_d >= 28)::int), 1) as pct_span_28d
from u group by 1 order by 1;

.print ## Y2.9 Rule share by first-month cohort in an equal window after the first send
create temp table win as
select w.days, d.user_id, f.first_t, date_trunc('month', f.first_t) as cohort,
    count(*) as n, count(distinct d.mo) as m, epoch(max(d.t) - f.first_t) / 86400.0 as span_d
from (select unnest([60, 90]) as days) w
cross join endt
join (select user_id, min(t) as first_t from dr group by 1) f on f.first_t <= endt.e - to_days(w.days)
join dr d on d.user_id = f.user_id and d.t <= f.first_t + to_days(w.days)
group by w.days, d.user_id, f.first_t;

select days as window_days, cast(cohort as date) as cohort, count(*) as users,
    round(100.0 * avg((n >= 2)::int), 1) as pct_2plus_sends, round(100.0 * avg((m >= 2)::int), 1) as pct_2_months,
    round(100.0 * avg((m >= 3)::int), 1) as pct_3_months, round(100.0 * avg((span_d >= 14)::int), 1) as pct_span_14d,
    round(100.0 * avg((span_d >= 28)::int), 1) as pct_span_28d
from win group by 1, 2 order by 1, 2;

.print ## Y2.10 Calendar phase effect: same 60-day window, by day of month of the first send
select case when day(first_t) <= 7 then 'a day 1-7' when day(first_t) <= 14 then 'b day 8-14' when day(first_t) <= 21 then 'c day 15-21'
        when day(first_t) <= 25 then 'd day 22-25' else 'e day 26-31' end as first_send_day_of_month,
    count(*) as users, round(100.0 * avg((n >= 2)::int), 1) as pct_2plus_sends, round(100.0 * avg((m >= 2)::int), 1) as pct_2_months,
    round(100.0 * avg((m >= 3)::int), 1) as pct_3_months, round(100.0 * avg((span_d >= 14)::int), 1) as pct_span_14d,
    round(100.0 * avg((m >= 2 and span_d < 14)::int), 2) as pct_2_months_but_span_under_14d
from win where days = 60 group by 1 order by 1;

.print ## Y2.11 Time to qualify, users whose first send is 150 or more days before the extract end
create temp table ev as
select d.user_id, epoch(d.t - f.first_t) / 86400.0 as dd,
    dense_rank() over (partition by d.user_id order by d.mo) as mrank,
    row_number() over (partition by d.user_id order by d.t, d.id) as rn
from dr d
join (select user_id, min(t) as first_t from dr group by 1) f using (user_id)
cross join endt where f.first_t <= endt.e - interval 150 day;

create temp table tq as
select user_id, min(case when rn = 2 then dd end) as t_n2, min(case when mrank = 2 then dd end) as t_m2,
    min(case when mrank = 3 then dd end) as t_m3, min(case when dd >= 14 then dd end) as t_s14
from ev group by 1;

select rule, count(*) as users,
    round(100.0 * avg(coalesce(tt <= 30, false)::int), 1) as by_day_30, round(100.0 * avg(coalesce(tt <= 60, false)::int), 1) as by_day_60,
    round(100.0 * avg(coalesce(tt <= 90, false)::int), 1) as by_day_90, round(100.0 * avg(coalesce(tt <= 120, false)::int), 1) as by_day_120,
    round(100.0 * avg(coalesce(tt <= 150, false)::int), 1) as by_day_150, round(100.0 * avg((tt is not null)::int), 1) as by_extract_end
from (
    select '2+ remittances' as rule, t_n2 as tt from tq
    union all select '2+ calendar months', t_m2 from tq
    union all select '3+ calendar months', t_m3 from tq
    union all select 'sends 14+ days apart', t_s14 from tq
)
group by rule order by rule;

.print ## Y2.12 Which rule predicts activity afterwards (rule fixed at day W, outcome in the next 60 days)
create temp table pred as
select p.w, f.user_id,
    count(*) filter (where d.t <= f.first_t + to_days(p.w)) as n,
    count(distinct d.mo) filter (where d.t <= f.first_t + to_days(p.w)) as m,
    epoch(max(d.t) filter (where d.t <= f.first_t + to_days(p.w)) - f.first_t) / 86400.0 as span_d,
    count(*) filter (where d.t > f.first_t + to_days(p.w) and d.t <= f.first_t + to_days(p.w + 60)) as fut
from (select unnest([30, 60, 90]) as w) p
cross join endt
join (select user_id, min(t) as first_t from dr group by 1) f on f.first_t <= endt.e - to_days(p.w + 60)
join dr d on d.user_id = f.user_id
group by p.w, f.user_id, f.first_t;

create temp table rules as
select w, '2+ remittances' as rule, n >= 2 as q, fut > 0 as act from pred
union all select w, '2+ calendar months', m >= 2, fut > 0 from pred
union all select w, '3+ calendar months', m >= 3, fut > 0 from pred
union all select w, '3+ remittances', n >= 3, fut > 0 from pred
union all select w, 'sends 7+ days apart', span_d >= 7, fut > 0 from pred
union all select w, 'sends 14+ days apart', span_d >= 14, fut > 0 from pred
union all select w, 'sends 28+ days apart', span_d >= 28, fut > 0 from pred;

select w as day_w, rule, count(*) as users, round(100.0 * avg(q::int), 1) as pct_qualify,
    round(100.0 * avg(act::int) filter (where q), 1) as active_if_qualify,
    round(100.0 * avg(act::int) filter (where not q), 1) as active_if_not,
    round(avg(act::int) filter (where q) / avg(act::int) filter (where not q), 2) as lift,
    round(100.0 * sum((q and act)::int) / sum(act::int), 1) as recall,
    round(100.0 * (sum((q and act)::int) / sum(act::int)::double + sum((not q and not act)::int) / sum((not act)::int)::double) / 2, 1) as balanced_accuracy
from rules group by w, rule order by w, balanced_accuracy desc;

.print ## Y2.13 Discordant groups: calendar-month rule against sends-apart rule (rule fixed at day W, next 60 days)
select w as day_w,
    case when n = 1 then '0 single send'
         when m >= 2 and span_d < 7 then '1 months 2+ but span under 7d'
         when m >= 2 and span_d < 14 then '2 months 2+ but span 7-14d'
         when m >= 2 then '3 months 2+ and span 14d+'
         when span_d >= 14 then '4 one month but span 14d+'
         when span_d < 7 then '5 one month, span under 7d'
         else '6 one month, span 7-14d' end as grp,
    count(*) as users, round(100.0 * avg((fut > 0)::int), 1) as pct_active_next_60d
from pred where w in (60, 90) group by all order by 1, 2;

-- Y3: top-user window --------------------------------------------------------

create temp table uv as
select user_id, sum(usd) as vol, count(*) as n, count(distinct mo) as m, min(mo) as first_mo from dr group by 1;

create temp table top_full as
with o as (
    select user_id, vol, sum(vol) over (order by vol desc, user_id rows between unbounded preceding and 1 preceding) as cum_before,
        sum(vol) over () as tot
    from uv
)
select user_id, vol from o where coalesce(cum_before, 0) < 0.5 * tot;

create temp table um as select user_id, mo, sum(usd) as vol, count(*) as n from dr group by 1, 2;

create temp table top_m as
with o as (
    select user_id, mo, vol,
        sum(vol) over (partition by mo order by vol desc, user_id rows between unbounded preceding and 1 preceding) as cum_before,
        sum(vol) over (partition by mo) as tot
    from um
)
select user_id, mo, vol from o where coalesce(cum_before, 0) < 0.5 * tot;

.print ## Y3.1 Full-extract top group against the rest
select (tf.user_id is not null) as in_top_50_pct, count(*) as users, round(sum(uv.vol), 0) as usd,
    round(avg(uv.n), 2) as avg_remittances, round(avg(uv.m), 2) as avg_months, round(100.0 * avg((uv.n = 1)::int), 1) as pct_single_send,
    round(100.0 * avg((uv.m >= 2)::int), 1) as pct_2_months, round(sum(uv.vol) / sum(uv.n), 0) as avg_ticket
from uv left join top_full tf using (user_id) group by 1 order by 1 desc;

.print ## Y3.2 Monthly top group size and threshold
select cast(mo as date) as month, count(*) as top_users, (select count(*) from um x where x.mo = t.mo) as active_users,
    round(100.0 * count(*) / (select count(*) from um x where x.mo = t.mo), 1) as pct_of_active, min(vol) as smallest_top_user_usd
from top_m t group by mo order by 1;

.print ## Y3.3 Overlap of consecutive monthly top groups
create temp table tm as select cast(mo as date) as mo, user_id from top_m;

select a.mo as month, count(distinct a.user_id) as top_users, count(b.user_id) as also_top_next_month,
    round(100.0 * count(b.user_id) / count(distinct a.user_id), 1) as pct_stay_top,
    round(100.0 * count(b.user_id) / (count(distinct a.user_id) + (select count(*) from tm where mo = cast(a.mo + interval 1 month as date)) - count(b.user_id)), 1) as jaccard_pct
from tm a left join tm b on b.user_id = a.user_id and b.mo = cast(a.mo + interval 1 month as date)
where a.mo < date '2026-09-01' group by a.mo order by 1;

.print ## Y3.4 Check of Y3.3 for January to February with flags per user
select count(*) filter (where jan and feb) as top_in_both, count(*) filter (where jan) as jan_top, count(*) filter (where feb) as feb_top
from (select user_id, bool_or(mo = date '2026-01-01') as jan, bool_or(mo = date '2026-02-01') as feb from tm group by 1);

.print ## Y3.5 Next-month behavior of monthly top users (January to August)
select case when exists (select 1 from top_m t where t.user_id = x.user_id and t.mo = x.mo) then 'top 50% in month' else 'rest' end as grp,
    count(*) as user_months, round(100.0 * avg((n.user_id is not null)::int), 1) as pct_active_next_month,
    round(100.0 * avg(exists (select 1 from top_m tn where tn.user_id = x.user_id and tn.mo = x.mo + interval 1 month)::int), 1) as pct_top_next_month
from um x left join um n on n.user_id = x.user_id and n.mo = x.mo + interval 1 month
where x.mo < timestamptz '2026-09-01' group by 1 order by 1 desc;

.print ## Y3.6 How monthly top users reach their volume
select case when u.n = 1 then '1 remittance' when u.n = 2 then '2 remittances' else '3+ remittances' end as remittances_in_month,
    count(*) as top_user_months, round(100.0 * count(*) / sum(count(*)) over (), 1) as pct, round(avg(t.vol), 0) as avg_month_usd
from top_m t join um u using (user_id, mo) group by 1 order by 1;

.print ## Y3.7 Monthly top groups against the full-extract top group
create temp table tf as select user_id from top_full;

select cast(t.mo as date) as month, count(*) as top_users, round(100.0 * avg((f.user_id is not null)::int), 1) as pct_in_full_top,
    round(100.0 * sum((f.user_id is not null)::int) / (select count(*) from tf), 1) as pct_of_full_top_covered,
    round(100.0 * (select sum(u.vol) from um u join tf using (user_id) where u.mo = t.mo) / (select sum(vol) from um where mo = t.mo), 1) as pct_month_volume_from_full_top
from top_m t left join tf f using (user_id) group by t.mo order by 1;

.print ## Y3.8 Users in a monthly top group at least once, against the full-extract group
select (select count(distinct user_id) from top_m) as ever_in_monthly_top, (select count(*) from tf) as full_top,
    (select count(distinct user_id) from top_m where user_id in (select user_id from tf)) as in_both,
    (select count(*) from tf where user_id not in (select user_id from top_m)) as full_top_never_in_monthly_top,
    (select count(distinct user_id) from top_m where user_id not in (select user_id from tf)) as monthly_top_not_in_full_top;

.print ## Y3.9 Months a full-extract top user spent in a monthly top group
select coalesce(k, 0) as months_in_monthly_top, count(*) as full_top_users
from tf left join (select user_id, count(*) as k from top_m group by 1) using (user_id) group by 1 order by 1;

.print ## Y3.10 Tenure: share of each first-month cohort in the full-extract top group
select cast(uv.first_mo as date) as cohort, count(*) as users, sum((tf.user_id is not null)::int) as top_users,
    round(100.0 * avg((tf.user_id is not null)::int), 1) as pct_of_cohort_in_top,
    round(100.0 * sum(uv.vol) / (select sum(vol) from uv), 1) as pct_of_total_volume,
    round(100.0 * count(*) / (select count(*) from uv), 1) as pct_of_users
from uv left join tf using (user_id) group by 1 order by 1;

.print ## Y3.11 Same test with equal exposure: rank by volume in the first 90 days after the first send
create temp table w90 as
select d.user_id, cast(date_trunc('month', f.first_t) as date) as cohort, sum(d.usd) as vol
from dr d
join (select user_id, min(t) as first_t from dr group by 1) f using (user_id)
cross join endt
where f.first_t <= endt.e - interval 90 day and d.t <= f.first_t + interval 90 day
group by 1, 2;

create temp table top90 as
with o as (
    select user_id, cohort, vol, sum(vol) over (order by vol desc, user_id rows between unbounded preceding and 1 preceding) as cum_before,
        sum(vol) over () as tot
    from w90
)
select user_id from o where coalesce(cum_before, 0) < 0.5 * tot;

select cohort, count(*) as users, round(100.0 * avg((t.user_id is not null)::int), 1) as pct_in_top_by_first_90_days
from w90 left join top90 t using (user_id) group by 1 order by 1;

.print ## Y3.12 Quarterly ranking, overlap of consecutive quarters (third quarter is partial and has no successor)
create temp table uq as select user_id, date_trunc('quarter', t) as q, sum(usd) as vol from dr group by 1, 2;

create temp table top_q as
with o as (
    select user_id, q, vol, sum(vol) over (partition by q order by vol desc, user_id rows between unbounded preceding and 1 preceding) as cum_before,
        sum(vol) over (partition by q) as tot
    from uq
)
select user_id, q from o where coalesce(cum_before, 0) < 0.5 * tot;

select cast(a.q as date) as quarter, count(*) as top_users, (select count(*) from uq x where x.q = a.q) as active_users,
    round(100.0 * count(*) / (select count(*) from uq x where x.q = a.q), 1) as pct_of_active,
    case when a.q < timestamptz '2026-07-01' then count(b.user_id) end as also_top_next_quarter,
    case when a.q < timestamptz '2026-07-01' then round(100.0 * count(b.user_id) / count(*), 1) end as pct_stay_top
from top_q a left join top_q b on b.user_id = a.user_id and b.q = a.q + interval 3 month
group by a.q order by 1;
