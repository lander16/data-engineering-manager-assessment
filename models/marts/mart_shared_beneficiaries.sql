select
    beneficiary_key,
    count(*) as users
from {{ ref('int_user_beneficiaries') }}
group by 1
having count(*) > 1
