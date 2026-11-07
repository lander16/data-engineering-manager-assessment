with attempt_rollup as (
    select
        payment_id,
        count(*) as attempt_count,
        count(*) filter (where attempt_status = 'delivered') as delivered_attempts,
        count(*) filter (where attempt_status = 'in_flight') as in_flight_attempts,
        count(*) filter (where attempt_status = 'missing') as missing_attempts,
        max(case when is_primary_attempt then amount_charged_usd + promotion_usd end) as value_sent_usd,
        max(case when is_primary_attempt then fee_usd end) as fee_usd,
        max(case when is_primary_attempt then promotion_usd end) as promotion_usd,
        sum(case when attempt_status = 'delivered' and not is_primary_attempt
                 then amount_charged_usd + promotion_usd end) as extra_delivered_value_usd
    from {{ ref('int_payout_attempts') }}
    group by 1
),

classified as (
    select
        p.payment_id,
        p.user_id,
        p.payment_status,
        p.detailed_status,
        p.payment_type,
        p.payment_month,
        p.created_at,
        p.updated_at,
        p.has_chargeback,
        p.amount_usd as customer_paid_usd,
        r.value_sent_usd,
        r.fee_usd,
        r.promotion_usd,
        r.extra_delivered_value_usd,
        coalesce(r.attempt_count, 0) as attempt_count,
        case
            when r.payment_id is null then 'no_receipt'
            when r.delivered_attempts >= 2 then 'multiple_delivered'
            when r.delivered_attempts = 1 then 'delivered'
            when r.in_flight_attempts > 0 then 'in_flight'
            when r.missing_attempts > 0 then 'missing_payout'
            else 'not_delivered'
        end as payout_outcome
    from {{ ref('stg_payments') }} as p
    left join attempt_rollup as r using (payment_id)
),

flagged as (
    select
        *,
        payment_status = 'SUCCESSFUL' as is_successful_payment,
        payment_status = 'SUCCESSFUL' and payout_outcome in ('delivered', 'multiple_delivered') as is_delivered_remittance,
        payment_status in ('SUCCESSFUL', 'REFUNDED') as is_chargeback_eligible,
        payment_status = 'SUCCESSFUL' and payout_outcome = 'no_receipt' as is_successful_without_receipt
    from classified
)

select
    *,
    case when is_delivered_remittance then {{ var('transacted_measure') }} end as transacted_usd,
    max(created_at) over () as extract_end_at
from flagged
