select
    user_id,
    beneficiary_key,
    {{ dbt.bool_or('attempt_number = 1') }} as is_on_first_attempt
from {{ ref('int_payout_attempts') }}
group by 1, 2
