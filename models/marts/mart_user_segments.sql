with labeled as (
    select 'volume_class' as segment_type, volume_class as segment, transacted_usd
    from {{ ref('dim_users') }}

    union all

    select
        'recurring_status',
        case
            when volume_class = 'no_delivered_volume' then 'no_delivered_volume'
            when is_recurring then 'recurring'
            else 'not_recurring'
        end,
        transacted_usd
    from {{ ref('dim_users') }}

    union all

    select 'beneficiary_segment', beneficiary_segment, transacted_usd
    from {{ ref('dim_users') }}
)

select
    segment_type,
    segment,
    count(*) as users,
    count(*) * 1.0 / sum(count(*)) over (partition by segment_type) as share_of_users,
    sum(transacted_usd) as transacted_usd,
    sum(transacted_usd) / sum(sum(transacted_usd)) over (partition by segment_type) as share_of_volume
from labeled
group by 1, 2
