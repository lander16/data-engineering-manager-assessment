select
    first_delivered_month,
    count(*) as users,
    count(case when is_recurring then 1 end) as recurring_users,
    count(case when is_recurring then 1 end) * 1.0 / count(*) as recurring_share,
    count(repeat_within_window) as users_with_full_window,
    count(case when repeat_within_window then 1 end) as repeat_users,
    count(case when repeat_within_window then 1 end) * 1.0 / nullif(count(repeat_within_window), 0) as repeat_rate
from {{ ref('dim_users') }}
where first_delivered_month is not null
group by 1
