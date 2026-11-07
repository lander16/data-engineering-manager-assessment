with payments as (
    select *
    from {{ ref('fct_remittances') }}
),

monthly as (
    select
        payment_month,
        count(case when is_delivered_remittance then 1 end) as delivered_remittances,
        sum(transacted_usd) as transacted_usd,
        sum(case when is_delivered_remittance then value_sent_usd end) as value_sent_usd,
        sum(case when is_delivered_remittance then fee_usd end) as fee_usd,
        sum(case when is_delivered_remittance then promotion_usd end) as promotion_usd,
        sum(case when is_successful_payment then customer_paid_usd end) as all_successful_payments_usd,
        max(extract_end_at) as extract_end_at
    from payments
    group by 1
),

user_months as (
    select
        user_id,
        payment_month,
        sum(transacted_usd) as transacted_usd
    from payments
    where is_delivered_remittance
    group by 1, 2
),

ranked as (
    select
        *,
        min(payment_month) over (partition by user_id) as first_month,
        sum(transacted_usd) over (
            partition by payment_month
            order by transacted_usd desc, user_id
            rows between unbounded preceding and current row
        ) as running_usd,
        sum(transacted_usd) over (partition by payment_month) as month_usd
    from user_months
),

senders as (
    select
        payment_month,
        count(*) as active_senders,
        count(case when payment_month = first_month then 1 end) as first_seen_senders,
        count(case when payment_month > first_month then 1 end) as returning_senders,
        count(case when running_usd - transacted_usd < 0.5 * month_usd then 1 end) * 1.0 / count(*) as top_50_pct_user_share
    from ranked
    group by 1
)

select
    m.payment_month,
    m.delivered_remittances,
    m.transacted_usd,
    m.value_sent_usd,
    m.fee_usd,
    m.promotion_usd,
    m.all_successful_payments_usd,
    s.active_senders,
    s.first_seen_senders,
    s.returning_senders,
    s.top_50_pct_user_share,
    cast(m.extract_end_at at time zone 'UTC' as date)
        <= cast({{ dbt.last_day('m.payment_month', 'month') }} as date) as is_partial_month
from monthly as m
left join senders as s using (payment_month)
