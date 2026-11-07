with typed as (
    select
        id as disbursement_id,
        user_id,
        type as payout_type,
        lower(status) as status,
        lower(raw_status) as raw_status,
        provider_status,
        disbursement_provider as provider,
        payer_destination_name as payer_name,
        case when destination_country = 'COSTA RICA' then 'CR' else destination_country end as country_code,
        destination_currency as currency,
        cast(amount as decimal(18, 2)) as local_amount,
        cast(created_at as timestamptz) as created_at,
        cast(updated_at as timestamptz) as updated_at,
        _source_file,
        _loaded_at
    from {{ source('raw', 'disbursements') }}
)

select *
from typed
qualify row_number() over (
    partition by disbursement_id
    order by _source_file desc, coalesce(updated_at, created_at) desc
) = 1
