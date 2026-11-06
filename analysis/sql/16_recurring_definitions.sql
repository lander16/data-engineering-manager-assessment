set timezone = 'UTC';

-- Compares calendar-month and day-window definitions of a recurring customer.
-- Gaps of 1 day or less don't count, so split same-day sends aren't treated as a habit.

create temp table sends as
select user_id, created_at, id,
    min(created_at) over (partition by user_id) as first_at,
    count(*) over (partition by user_id) as sends_total,
    epoch(created_at - lag(created_at) over (partition by user_id order by created_at, id)) / 86400 as gap_days
from remittances
where is_delivered_remittance;

create temp table extract_end as select max(created_at) as end_at from payments;

create temp table user_rules as
select user_id, min(first_at) as first_at, max(sends_total) as sends_total,
    count(distinct date_trunc('month', created_at)) as distinct_months,
    count(*) filter (where gap_days > 1 and gap_days <= 60) as gaps_within_60,
    count(*) filter (where gap_days > 1 and gap_days <= 90) as gaps_within_90,
    count(*) filter (where epoch(created_at - first_at) / 86400 > 1 and epoch(created_at - first_at) / 86400 <= 60) as repeats_60,
    count(*) filter (where epoch(created_at - first_at) / 86400 > 1 and epoch(created_at - first_at) / 86400 <= 90) as repeats_90
from sends
group by 1;

.print ## C1 Users under each definition
select count(*) as users,
    count(*) filter (where distinct_months >= 2) as two_calendar_months,
    count(*) filter (where gaps_within_60 > 0) as gap_within_60_days,
    count(*) filter (where gaps_within_90 > 0) as gap_within_90_days,
    count(*) filter (where sends_total >= 2) as two_sends
from user_rules;

.print ## C2 Gap distribution between delivered remittances
select round(quantile_cont(gap_days, 0.5), 1) as p50, round(quantile_cont(gap_days, 0.75), 1) as p75,
    round(quantile_cont(gap_days, 0.9), 1) as p90,
    round(100.0 * count(*) filter (where gap_days <= 60) / count(*), 1) as pct_within_60,
    round(100.0 * count(*) filter (where gap_days <= 90) / count(*), 1) as pct_within_90
from sends
where gap_days is not null;

.print ## C3 Calendar effect: rule met within 60 days, by week of the month of the first send
with eligible as (
    select *, least(4, (day(first_at at time zone 'UTC') - 1) // 7 + 1) as start_week
    from user_rules, extract_end
    where first_at + interval 60 day <= end_at
),
months_in_window as (
    select s.user_id, count(distinct date_trunc('month', s.created_at)) as months_60
    from sends s
    where epoch(s.created_at - s.first_at) / 86400 <= 60
    group by 1
)
select start_week, count(*) as users,
    round(100.0 * count(*) filter (where months_60 >= 2) / count(*), 1) as two_calendar_months_pct,
    round(100.0 * count(*) filter (where repeats_60 > 0) / count(*), 1) as repeat_within_60_pct
from eligible
join months_in_window using (user_id)
group by 1
order by 1;

.print ## C4 Share by first month, which shows right-censoring
select date_trunc('month', first_at)::date as first_month, count(*) as users,
    round(100.0 * count(*) filter (where distinct_months >= 2) / count(*), 1) as two_calendar_months_pct,
    round(100.0 * count(*) filter (where gaps_within_60 > 0) / count(*), 1) as gap_within_60_pct,
    round(100.0 * count(*) filter (where gaps_within_90 > 0) / count(*), 1) as gap_within_90_pct
from user_rules
group by 1
order by 1;

.print ## C5 Repeat rate among users with a full window
select 60 as window_days, count(*) as eligible, round(100.0 * count(*) filter (where repeats_60 > 0) / count(*), 1) as repeat_pct
from user_rules, extract_end
where first_at + interval 60 day <= end_at
union all
select 90, count(*), round(100.0 * count(*) filter (where repeats_90 > 0) / count(*), 1)
from user_rules, extract_end
where first_at + interval 90 day <= end_at;

.print ## C6 Where the 2-month and 90-day rules disagree
select distinct_months >= 2 as two_calendar_months, gaps_within_90 > 0 as gap_within_90_days, count(*) as users
from user_rules
group by 1, 2
order by 1, 2;

.print ## C7 Does the rule predict the next 60 days? Rule read on the first 90 days, for users first seen by May 20
with observed as (
    select s.user_id,
        count(distinct date_trunc('month', s.created_at)) filter (where s.created_at <= s.first_at + interval 90 day) as months_90,
        count(*) filter (where s.created_at <= s.first_at + interval 90 day and epoch(s.created_at - s.first_at) / 86400 > 1) as repeats,
        count(*) filter (where s.created_at > s.first_at + interval 90 day and s.created_at <= s.first_at + interval 150 day) as later_sends
    from sends s
    where s.first_at <= timestamptz '2026-05-20 00:00:00+00'
    group by 1
)
select 'two_calendar_months' as rule, round(100.0 * count(*) filter (where months_90 >= 2) / count(*), 1) as qualifies_pct,
    round(100.0 * count(*) filter (where months_90 >= 2 and later_sends > 0) / count(*) filter (where months_90 >= 2), 1) as active_if_qualified,
    round(100.0 * count(*) filter (where months_90 < 2 and later_sends > 0) / count(*) filter (where months_90 < 2), 1) as active_if_not
from observed
union all
select 'repeat_within_90_days', round(100.0 * count(*) filter (where repeats > 0) / count(*), 1),
    round(100.0 * count(*) filter (where repeats > 0 and later_sends > 0) / count(*) filter (where repeats > 0), 1),
    round(100.0 * count(*) filter (where repeats = 0 and later_sends > 0) / count(*) filter (where repeats = 0), 1)
from observed;

.print ## C8 Repeat within 90 days by first month, for users with a full window
select date_trunc('month', first_at)::date as first_month, count(*) as eligible,
    round(100.0 * count(*) filter (where repeats_90 > 0) / count(*), 1) as repeat_within_90_pct
from user_rules, extract_end
where first_at + interval 90 day <= end_at
group by 1
order by 1;

.print ## C9 Effect of $0 remittances on the 90-day rule
with positive as (
    select user_id,
        epoch(created_at - lag(created_at) over (partition by user_id order by created_at, id)) / 86400 as gap_days
    from remittances
    where is_delivered_remittance and amount > 0
)
select count(distinct user_id) filter (where gap_days > 1 and gap_days <= 90) as recurring_on_positive_amounts
from positive;
