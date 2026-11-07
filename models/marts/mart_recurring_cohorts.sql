select
    first_delivered_month,
    count(*) as users,
    count(*) filter (where is_recurring) as recurring_users,
    count(*) filter (where is_recurring) * 1.0 / count(*) as recurring_share,
    count(repeat_within_window) as users_with_full_window,
    count(*) filter (where repeat_within_window) as repeat_users,
    count(*) filter (where repeat_within_window) * 1.0 / nullif(count(repeat_within_window), 0) as repeat_rate
from {{ ref('dim_users') }}
where first_delivered_month is not null
group by 1
