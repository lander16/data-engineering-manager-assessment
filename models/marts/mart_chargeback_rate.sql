with monthly as (
    select
        payment_month,
        count(*) as settled_payments,
        count(case when has_chargeback then 1 end) as flagged_payments,
        sum(customer_paid_usd) as settled_value_usd,
        coalesce(sum(case when has_chargeback then customer_paid_usd end), 0) as flagged_payment_value_usd,
        max(extract_end_at) as extract_end_at
    from {{ ref('fct_remittances') }}
    where is_chargeback_eligible
    group by 1
)

select
    payment_month,
    settled_payments,
    flagged_payments,
    flagged_payments * 1.0 / settled_payments as count_rate,
    settled_value_usd,
    flagged_payment_value_usd,
    flagged_payment_value_usd / settled_value_usd as value_rate,
    cast({{ dbt.dateadd('day', var('chargeback_maturity_days'), dbt.last_day('payment_month', 'month')) }} as date)
        <= cast(extract_end_at at time zone 'UTC' as date) as is_mature
from monthly
