{{ config(severity='warn') }}

with actual as (
    select 'payments' as metric, count(*) * 1.0 as value from {{ ref('fct_remittances') }}
    union all select 'delivered_remittances', count(*) from {{ ref('fct_remittances') }} where is_delivered_remittance
    union all select 'transacted_usd', round(sum(transacted_usd)) from {{ ref('fct_remittances') }}
    union all select 'top_users', count(*) from {{ ref('dim_users') }} where volume_class = 'top_50_pct_volume'
    union all select 'recurring_users', count(*) from {{ ref('dim_users') }} where is_recurring
    union all select 'chargebacks', sum(flagged_payments) from {{ ref('mart_chargeback_rate') }}
    union all select 'mature_chargeback_months', count(*) from {{ ref('mart_chargeback_rate') }} where is_mature
),

expected as (
    select 'payments' as metric, 788976 as value
    union all select 'delivered_remittances', 720630
    union all select 'transacted_usd', 237075837
    union all select 'top_users', 59511
    union all select 'recurring_users', 133760
    union all select 'chargebacks', 526
    union all select 'mature_chargeback_months', 4
),

actual_classes as (
    select provider, failure_class || ' / ' || unsuccessful_class as classes
    from {{ ref('mart_provider_failures') }}
),

expected_classes as (
    select 'PROVIDER 1' as provider, 'insufficient_volume / insufficient_volume' as classes
    union all select 'PROVIDER 2', 'high / high'
    union all select 'PROVIDER 3', 'medium / medium'
    union all select 'PROVIDER 4', 'medium / medium'
    union all select 'PROVIDER 5', 'medium / medium'
    union all select 'PROVIDER 6', 'insufficient_volume / insufficient_volume'
    union all select 'PROVIDER 7', 'medium / high'
    union all select 'PROVIDER 8', 'low / high'
    union all select 'PROVIDER 9', 'high / high'
    union all select 'PROVIDER 10', 'insufficient_volume / insufficient_volume'
    union all select 'PROVIDER 11', 'medium / medium'
    union all select 'PROVIDER 12', 'medium / high'
)

select a.metric, cast(a.value as {{ dbt.type_string() }}) as actual, cast(e.value as {{ dbt.type_string() }}) as expected
from actual as a
join expected as e using (metric)
where a.value <> e.value

union all

select coalesce(a.provider, e.provider), a.classes, e.classes
from actual_classes as a
full outer join expected_classes as e on a.provider = e.provider
where a.classes is null or e.classes is null or a.classes <> e.classes
