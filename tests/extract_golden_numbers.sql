{{ config(severity='warn') }}

with actual as (
    select 'payments' as metric, count(*) * 1.0 as value from {{ ref('fct_remittances') }}
    union all select 'delivered_remittances', count(*) from {{ ref('fct_remittances') }} where is_delivered_remittance
    union all select 'transacted_usd', round(sum(transacted_usd)) from {{ ref('fct_remittances') }}
    union all select 'top_users', count(*) from {{ ref('dim_users') }} where volume_class = 'top_50_pct_volume'
    union all select 'recurring_users', count(*) from {{ ref('dim_users') }} where is_recurring
    union all select 'chargebacks', sum(flagged_payments) from {{ ref('mart_chargeback_rate') }}
),

expected as (
    select 'payments' as metric, 788976 as value
    union all select 'delivered_remittances', 720630
    union all select 'transacted_usd', 237075837
    union all select 'top_users', 59511
    union all select 'recurring_users', 133760
    union all select 'chargebacks', 526
)

select a.metric, a.value as actual, e.value as expected
from actual as a
join expected as e using (metric)
where a.value <> e.value
