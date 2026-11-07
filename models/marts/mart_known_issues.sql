with payments as (
    select *
    from {{ ref('fct_remittances') }}
),

attempts as (
    select *
    from {{ ref('int_payout_attempts') }}
),

raw_rows as (
    select
        (select count(*) from {{ source('raw', 'payments') }})
        + (select count(*) from {{ source('raw', 'receipts') }})
        + (select count(*) from {{ source('raw', 'disbursements') }}) as total_rows
),

staged_rows as (
    select
        (select count(*) from {{ ref('stg_payments') }})
        + (select count(*) from {{ ref('stg_receipts') }})
        + (select count(*) from {{ ref('stg_disbursements') }}) as total_rows
),

issues as (
    select 'duplicate_ids_removed' as issue, r.total_rows - s.total_rows as rows_affected, null as usd_affected, 0 as baseline_rows
    from raw_rows as r, staged_rows as s

    union all
    select 'missing_disbursement', count(*), sum(amount_charged_usd), 185
    from attempts where attempt_status = 'missing'

    union all
    select 'status_conflict', count(*), sum(amount_charged_usd), 3137
    from attempts where status_conflict_type is not null

    union all
    select 'multiple_delivered', count(*), sum(extra_delivered_value_usd), 19
    from payments where payout_outcome = 'multiple_delivered'

    union all
    select 'delivered_on_failed_payment', count(*), sum(customer_paid_usd), 2
    from payments where payment_status = 'FAILED' and payout_outcome in ('delivered', 'multiple_delivered')

    union all
    select 'delivered_on_refunded_payment', count(*), sum(customer_paid_usd), 7
    from payments where payment_status = 'REFUNDED' and payout_outcome in ('delivered', 'multiple_delivered')

    union all
    select 'charged_undelivered_unrefunded', count(*), sum(customer_paid_usd), 182
    from payments where is_successful_payment and payout_outcome = 'not_delivered'

    union all
    select 'cancelled_with_paid_raw_status', count(*), sum(customer_paid_usd), 37
    from payments
    where is_successful_payment
        and not is_delivered_remittance
        and payment_id in (select payment_id from attempts where status_conflict_type = 'cancelled_raw_paid')

    union all
    select 'cancelled_then_delivered', count(*), sum(customer_paid_usd), 23
    from payments
    where payment_id in (
        select payment_id from attempts
        where status_conflict_type = 'cancelled_raw_paid' and is_followed_by_delivery
    )

    union all
    select 'in_flight_over_30_days', count(*), sum(customer_paid_usd), 156
    from payments
    where is_successful_payment
        and payout_outcome in ('in_flight', 'missing_payout')
        and created_at < {{ dbt.dateadd('day', -30, 'extract_end_at') }}

    union all
    select 'ach_settlement_pending', count(*), sum(customer_paid_usd), 10
    from payments where is_successful_payment and detailed_status = 'PENDING_USER_ACTION_ACH_SETTLEMENT'

    union all
    select 'no_receipt_scheduled_amount', count(*), sum(customer_paid_usd), 1173
    from payments
    where is_successful_without_receipt
        and customer_paid_usd <> 1
        and (customer_paid_usd + 0.25) / 6.25 = round((customer_paid_usd + 0.25) / 6.25)

    union all
    select 'no_receipt_one_dollar', count(*), sum(customer_paid_usd), 704
    from payments where is_successful_without_receipt and customer_paid_usd = 1

    union all
    select 'no_receipt_other', count(*), sum(customer_paid_usd), 84
    from payments
    where is_successful_without_receipt
        and customer_paid_usd <> 1
        and (customer_paid_usd + 0.25) / 6.25 <> round((customer_paid_usd + 0.25) / 6.25)

    union all
    select 'non_positive_payment_amount', count(*), sum(customer_paid_usd), 134
    from payments where customer_paid_usd <= 0

    union all
    select 'negative_amount_charged', count(*), sum(amount_charged_usd), 1
    from attempts where amount_charged_usd < 0

    union all
    select 'currency_conflict', count(*), sum(amount_charged_usd), 5
    from attempts
    where currency <> disbursement_currency or (currency = 'USD' and exchange_rate <> 1 and attempt_status <> 'missing')

    union all
    select 'chronology_reversal', count(*), null, 0
    from attempts where disbursement_updated_at < {{ dbt.date_trunc('second', 'disbursement_created_at') }}

    union all
    select 'disbursement_before_receipt', count(*), null, 753
    from attempts where disbursement_created_at < {{ dbt.dateadd('minute', -1, 'attempt_at') }}

    union all
    select 'payment_primary_attempt_gap', count(*), sum(round(customer_paid_usd, 2) - round(value_sent_usd - promotion_usd + fee_usd, 2)), 887
    from payments
    where is_delivered_remittance
        and round(customer_paid_usd, 2) <> round(value_sent_usd - promotion_usd + fee_usd, 2)

    union all
    select 'chargeback_on_ineligible_payment', count(*), sum(customer_paid_usd), 0
    from payments where has_chargeback and not is_chargeback_eligible
)

select
    issue,
    rows_affected,
    cast(usd_affected as decimal(18, 2)) as usd_affected,
    baseline_rows
from issues
