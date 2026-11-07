with joined as (
    select
        r.receipt_id,
        r.payment_id,
        r.user_id,
        r.beneficiary_key,
        r.disbursement_id,
        r.country_code,
        r.currency,
        r.amount_charged_usd,
        r.fee_usd,
        r.promotion_usd,
        r.exchange_rate,
        r.destination_amount,
        r.created_at as attempt_at,
        d.country_code as disbursement_country_code,
        d.currency as disbursement_currency,
        d.status,
        d.raw_status,
        d.provider_status,
        d.provider,
        d.payer_name,
        d.payout_type,
        d.local_amount,
        d.created_at as disbursement_created_at,
        d.updated_at as disbursement_updated_at,
        case
            when d.disbursement_id is null then 'missing'
            when d.status = 'cancelled' then 'cancelled'
            when d.status in ('paid', 'success', 'completed', 'delivered') then 'delivered'
            when d.status in ('failed', 'rejected', 'error_sending_payout_request',
                              'payout_not_processed') then 'failed'
            when d.status in ('payable', 'wire_released', 'wire_confirmed', 'transmitted', 'in_progress',
                              'pending', 'to_be_processed', 'on_hold', 'hold_by_compliance',
                              'hold_by_payer', 'cancellation_in_progress') then 'in_flight'
            else 'unknown'
        end as attempt_status,
        case
            when d.status = 'failed' and d.raw_status = 'cancelled' then 'failed_raw_cancelled'
            when d.status = 'cancelled' and d.raw_status in ('paid', 'completed') then 'cancelled_raw_paid'
            when d.status = 'cancelled' and d.raw_status = 'created' then 'cancelled_raw_created'
        end as status_conflict_type
    from {{ ref('stg_receipts') }} as r
    left join {{ ref('stg_disbursements') }} as d using (disbursement_id)
),

ordered as (
    select
        *,
        row_number() over (partition by payment_id order by attempt_at, receipt_id) as attempt_number
    from joined
),

delivery as (
    select
        *,
        min(case when attempt_status = 'delivered' then attempt_number end)
            over (partition by payment_id) as first_delivered_number,
        max(case when attempt_status = 'delivered' then attempt_number end)
            over (partition by payment_id) as last_delivered_number
    from ordered
)

select
    * exclude (first_delivered_number, last_delivered_number),
    coalesce(attempt_number = first_delivered_number, false) as is_primary_attempt,
    coalesce(attempt_status in ('failed', 'cancelled') and last_delivered_number > attempt_number, false) as is_followed_by_delivery
from delivery
