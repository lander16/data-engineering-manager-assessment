-- Each staged money or rate column equals its raw text cast at full precision, so a narrower cast fails.
-- Rows join on ID, file, and version time, which `no_conflicting_versions` makes unique.

with payments as (
    select
        s.payment_id as id,
        cast(r.amount as decimal(38, 18)) as raw_amount_usd,
        s.amount_usd
    from {{ ref('stg_payments') }} as s
    join {{ source('raw', 'payments') }} as r
        on r.id = s.payment_id
        and r._source_file = s._source_file
        and cast(coalesce(r.updated_at, r.created_at) as timestamptz) = coalesce(s.updated_at, s.created_at)
),

receipts as (
    select
        s.receipt_id as id,
        cast(r.amount_charged as decimal(38, 18)) as raw_amount_charged_usd,
        cast(r.fee as decimal(38, 18)) as raw_fee_usd,
        cast(r.promotion_amount as decimal(38, 18)) as raw_promotion_usd,
        cast(r.exchange_rate as decimal(38, 18)) as raw_exchange_rate,
        cast(r.destination_amount as decimal(38, 18)) as raw_destination_amount,
        s.amount_charged_usd,
        s.fee_usd,
        s.promotion_usd,
        s.exchange_rate,
        s.destination_amount
    from {{ ref('stg_receipts') }} as s
    join {{ source('raw', 'receipts') }} as r
        on r.id = s.receipt_id
        and r._source_file = s._source_file
        and cast(r.created_at as timestamptz) = s.created_at
),

disbursements as (
    select
        s.disbursement_id as id,
        cast(r.amount as decimal(38, 18)) as raw_local_amount,
        s.local_amount
    from {{ ref('stg_disbursements') }} as s
    join {{ source('raw', 'disbursements') }} as r
        on r.id = s.disbursement_id
        and r._source_file = s._source_file
        and cast(coalesce(r.updated_at, r.created_at) as timestamptz) = coalesce(s.updated_at, s.created_at)
)

select 'stg_payments.amount_usd' as failed_column, id from payments where raw_amount_usd is distinct from amount_usd
union all
select 'stg_receipts.amount_charged_usd', id from receipts where raw_amount_charged_usd is distinct from amount_charged_usd
union all
select 'stg_receipts.fee_usd', id from receipts where raw_fee_usd is distinct from fee_usd
union all
select 'stg_receipts.promotion_usd', id from receipts where raw_promotion_usd is distinct from promotion_usd
union all
select 'stg_receipts.exchange_rate', id from receipts where raw_exchange_rate is distinct from exchange_rate
union all
select 'stg_receipts.destination_amount', id from receipts where raw_destination_amount is distinct from destination_amount
union all
select 'stg_disbursements.local_amount', id from disbursements where raw_local_amount is distinct from local_amount
