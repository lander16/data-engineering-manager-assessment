with users as (
    select distinct user_id
    from {{ ref('fct_remittances') }}
),

remittances as (
    select
        user_id,
        transacted_usd,
        created_at,
        extract_end_at,
        min(created_at) over (partition by user_id) as first_delivered_at,
        epoch(created_at - lag(created_at) over (partition by user_id order by created_at, payment_id)) / 86400.0 as gap_days
    from {{ ref('fct_remittances') }}
    where is_delivered_remittance
),

activity as (
    select
        user_id,
        count(*) as delivered_remittances,
        sum(transacted_usd) as transacted_usd,
        min(first_delivered_at) as first_delivered_at,
        max(created_at) as last_delivered_at,
        max(extract_end_at) as extract_end_at,
        coalesce(bool_or(gap_days > 1 and gap_days <= {{ var('recurring_window_days') }}), false) as is_recurring,
        bool_or(
            epoch(created_at - first_delivered_at) / 86400.0 > 1
            and epoch(created_at - first_delivered_at) / 86400.0 <= {{ var('recurring_window_days') }}
        ) as has_repeat_in_window
    from remittances
    group by 1
),

ranked as (
    select
        *,
        sum(transacted_usd) over (
            order by transacted_usd desc, user_id
            rows between unbounded preceding and current row
        ) as running_usd,
        sum(transacted_usd) over () as total_usd
    from activity
),

beneficiaries as (
    select user_id, count(*) as first_attempt_beneficiaries
    from {{ ref('int_user_beneficiaries') }}
    where is_on_first_attempt
    group by 1
)

select
    u.user_id,
    coalesce(r.delivered_remittances, 0) as delivered_remittances,
    coalesce(r.transacted_usd, 0) as transacted_usd,
    r.first_delivered_at,
    r.last_delivered_at,
    cast(date_trunc('month', r.first_delivered_at at time zone 'UTC') as date) as first_delivered_month,
    case
        when r.user_id is null then 'no_delivered_volume'
        when r.running_usd - r.transacted_usd < 0.5 * r.total_usd then 'top_50_pct_volume'
        else 'long_tail'
    end as volume_class,
    coalesce(r.is_recurring, false) as is_recurring,
    case
        when r.first_delivered_at + interval ({{ var('recurring_window_days') }}) day <= r.extract_end_at
            then r.has_repeat_in_window
    end as repeat_within_window,
    case
        when b.first_attempt_beneficiaries is null then 'none'
        when b.first_attempt_beneficiaries = 1 then '1'
        when b.first_attempt_beneficiaries <= 3 then '2-3'
        when b.first_attempt_beneficiaries <= 9 then '4-9'
        else '10+'
    end as beneficiary_segment
from users as u
left join ranked as r using (user_id)
left join beneficiaries as b using (user_id)
