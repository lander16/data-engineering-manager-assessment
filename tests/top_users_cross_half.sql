with top_users as (
    select
        sum(transacted_usd) as top_usd,
        min(transacted_usd) as smallest_top_usd
    from {{ ref('dim_users') }}
    where volume_class = 'top_50_pct_volume'
),

everyone as (
    select sum(transacted_usd) as total_usd
    from {{ ref('dim_users') }}
)

select *
from top_users, everyone
where top_usd < 0.5 * total_usd
    or top_usd - smallest_top_usd >= 0.5 * total_usd
