with typed as (
    select
        id as payment_id,
        user_id,
        status as payment_status,
        detailed_status,
        type as payment_type,
        currency,
        cast(amount as decimal(18, 9)) as amount_usd,
        has_dispute_chargeback = 'True' as has_chargeback,
        cast(created_at as timestamptz) as created_at,
        cast(updated_at as timestamptz) as updated_at,
        _source_file,
        _loaded_at
    from {{ source('raw', 'payments') }}
)

select
    *,
    cast(date_trunc('month', created_at at time zone 'UTC') as date) as payment_month
from typed
qualify row_number() over (
    partition by payment_id
    order by _source_file desc, coalesce(updated_at, created_at) desc
) = 1
