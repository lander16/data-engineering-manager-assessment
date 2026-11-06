set timezone = 'UTC';

-- Helper tables for the assumption research in scripts 11 to 14.
-- They use the status rule from before the research, where raw `cancelled` overrode `status`.
-- Script 15 applies the adopted rule. Payout outcomes don't change, but Provider 3's rates do.

create or replace table attempts as
with joined as (
    select r.id as receipt_id, r.payment_id, r.user_id, r.beneficiary_id, r.disbursement_id,
        r.destination_country_code as country, r.destination_currency as currency,
        r.amount_charged, r.fee, r.promotion_amount, r.exchange_rate, r.destination_amount,
        r.created_at as attempt_at,
        d.id as matched_disbursement_id, d.status, d.status_lc, d.raw_status, d.raw_status_lc,
        d.provider_status, d.provider, d.type as payout_type, d.payer_destination_name,
        d.amount as disbursement_amount, d.created_at as disbursement_created_at,
        d.updated_at as disbursement_updated_at
    from receipts r
    left join disbursements d on d.id = r.disbursement_id
),
classified as (
    select *,
        case
            when matched_disbursement_id is null then 'missing'
            when status_lc = 'cancelled' or raw_status_lc = 'cancelled' then 'cancelled'
            when status_lc in ('paid', 'success', 'completed', 'delivered') then 'delivered'
            when status_lc in ('failed', 'rejected', 'error_sending_payout_request', 'payout_not_processed') then 'failed'
            when status_lc in ('payable', 'wire_released', 'wire_confirmed', 'transmitted', 'in_progress', 'pending',
                'to_be_processed', 'on_hold', 'hold_by_compliance', 'hold_by_payer', 'cancellation_in_progress') then 'in_flight'
            else 'unknown'
        end as attempt_status
    from joined
),
ordered as (
    select *, row_number() over (partition by payment_id order by attempt_at, receipt_id) as attempt_number
    from classified
)
select *,
    attempt_status = 'delivered'
        and attempt_number = min(case when attempt_status = 'delivered' then attempt_number end)
            over (partition by payment_id) as is_primary_attempt
from ordered;

create or replace table remittances as
with rollup as (
    select payment_id,
        count(*) as attempt_count,
        sum((attempt_status = 'delivered')::int) as delivered_attempts,
        sum((attempt_status = 'in_flight')::int) as in_flight_attempts,
        sum((attempt_status = 'missing')::int) as missing_attempts,
        max(case when is_primary_attempt then amount_charged + promotion_amount end) as value_sent_usd,
        max(case when is_primary_attempt then fee end) as fee_usd,
        max(case when is_primary_attempt then promotion_amount end) as promotion_usd
    from attempts
    group by 1
)
select p.*, coalesce(r.attempt_count, 0) as attempt_count, r.value_sent_usd, r.fee_usd, r.promotion_usd,
    cast(date_trunc('month', p.created_at at time zone 'UTC') as date) as payment_month,
    case
        when r.payment_id is null then 'no_receipt'
        when r.delivered_attempts >= 2 then 'multiple_delivered'
        when r.delivered_attempts = 1 then 'delivered'
        when r.in_flight_attempts > 0 then 'in_flight'
        when r.missing_attempts > 0 then 'missing_payout'
        else 'not_delivered'
    end as payout_outcome,
    p.status = 'SUCCESSFUL' and coalesce(r.delivered_attempts, 0) >= 1 as is_delivered_remittance
from payments p
left join rollup r on r.payment_id = p.id;
