{{ config(materialized='incremental', unique_key='receipt_id') }}

with typed as (
    select
        id as receipt_id,
        payment_id,
        user_id,
        disbursement_id,
        beneficiary_id as beneficiary_key,
        destination_country_code as country_code,
        destination_currency as currency,
        cast(amount_charged as decimal(18, 2)) as amount_charged_usd,
        cast(fee as decimal(18, 2)) as fee_usd,
        cast(promotion_amount as decimal(18, 2)) as promotion_usd,
        cast(exchange_rate as decimal(18, 4)) as exchange_rate,
        cast(destination_amount as decimal(18, 2)) as destination_amount,
        cast(created_at as timestamptz) as created_at,
        _source_file,
        _loaded_at
    from {{ source('raw', 'receipts') }}
    {% if is_incremental() %}
    where _loaded_at > (select max(_loaded_at) from {{ this }})
    {% endif %}
)

select *
from typed
qualify row_number() over (
    partition by receipt_id
    order by _source_file desc, created_at desc
) = 1
