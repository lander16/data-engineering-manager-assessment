with fact as (
    select
        sum(transacted_usd) as transacted_usd,
        count(case when is_delivered_remittance then 1 end) as delivered_remittances,
        sum(case when is_chargeback_eligible then customer_paid_usd end) as settled_value_usd,
        count(case when has_chargeback and is_chargeback_eligible then 1 end) as flagged_payments
    from {{ ref('fct_remittances') }}
),

volume as (
    select
        sum(transacted_usd) as transacted_usd,
        sum(delivered_remittances) as delivered_remittances,
        sum(all_successful_payments_usd) as all_successful_payments_usd
    from {{ ref('mart_monthly_volume') }}
),

chargebacks as (
    select
        sum(settled_value_usd) as settled_value_usd,
        sum(flagged_payments) as flagged_payments
    from {{ ref('mart_chargeback_rate') }}
),

staged as (
    select sum(amount_usd) as successful_usd
    from {{ ref('stg_payments') }}
    where payment_status = 'SUCCESSFUL'
),

user_count as (
    select count(*) as users
    from {{ ref('dim_users') }}
)

select 'monthly volume' as failed_check from fact, volume where fact.transacted_usd <> volume.transacted_usd
union all
select 'monthly remittances' from fact, volume where fact.delivered_remittances <> volume.delivered_remittances
union all
select 'successful payments' from volume, staged where volume.all_successful_payments_usd <> staged.successful_usd
union all
select 'chargeback value' from fact, chargebacks where fact.settled_value_usd <> chargebacks.settled_value_usd
union all
select 'chargeback flags' from fact, chargebacks where fact.flagged_payments <> chargebacks.flagged_payments
union all
select 'segment ' || segment_type
from (select segment_type, sum(users) as users from {{ ref('mart_user_segments') }} group by 1) as s, user_count
where s.users <> user_count.users
union all
select 'monthly senders ' || payment_month
from {{ ref('mart_monthly_volume') }}
where active_senders <> first_seen_senders + returning_senders
union all
select 'user volume'
from fact, (select sum(transacted_usd) as usd from {{ ref('dim_users') }}) as u
where fact.transacted_usd <> u.usd
