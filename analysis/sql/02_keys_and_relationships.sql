set timezone = 'UTC';

.print ## Primary key candidates
select 'payments.id' as key, count(*) as rows_, count(id) as non_null, count(distinct id) as distinct_values from raw_payments
union all select 'receipts.id', count(*), count(id), count(distinct id) from raw_receipts
union all select 'disbursements.id', count(*), count(id), count(distinct id) from raw_disbursements;

.print ## Duplicates after excluding the id column
select 'payments' as source_file, count(*) as duplicate_groups from (
    select * exclude (id) from raw_payments group by all having count(*) > 1)
union all select 'receipts', count(*) from (
    select * exclude (id) from raw_receipts group by all having count(*) > 1)
union all select 'disbursements', count(*) from (
    select * exclude (id) from raw_disbursements group by all having count(*) > 1);

.print ## Identifier format: expect 64 lowercase hex characters
select field, count(*) as n, sum((not regexp_full_match(v, '[0-9a-f]{64}'))::int) as invalid from (
    select 'payments.id' field, id v from raw_payments
    union all select 'payments.user_id', user_id from raw_payments
    union all select 'receipts.id', id from raw_receipts
    union all select 'receipts.user_id', user_id from raw_receipts
    union all select 'receipts.payment_id', payment_id from raw_receipts
    union all select 'receipts.disbursement_id', disbursement_id from raw_receipts
    union all select 'receipts.beneficiary_id', beneficiary_id from raw_receipts
    union all select 'disbursements.id', id from raw_disbursements
    union all select 'disbursements.user_id', user_id from raw_disbursements
) group by 1 order by 1;

.print ## Foreign key coverage
select
    (select count(*) from receipts r anti join payments p on r.payment_id = p.id) as receipts_without_payment,
    (select count(*) from receipts r anti join disbursements d on r.disbursement_id = d.id) as receipts_without_disbursement,
    (select count(*) from payments p anti join receipts r on r.payment_id = p.id) as payments_without_receipt,
    (select count(*) from disbursements d anti join receipts r on r.disbursement_id = d.id) as disbursements_without_receipt;

.print ## Receipts per payment
select receipts_per_payment, count(*) as payments from (
    select p.id, count(r.id) as receipts_per_payment
    from payments p left join receipts r on r.payment_id = p.id group by 1
) group by 1 order by 1;

.print ## Receipts per disbursement
select receipts_per_disbursement, count(*) as disbursements from (
    select disbursement_id, count(*) as receipts_per_disbursement from receipts group by 1
) group by 1 order by 1;

.print ## User consistency across files
select
    sum((r.user_id <> p.user_id)::int) as receipt_vs_payment,
    sum((r.user_id <> d.user_id)::int) as receipt_vs_disbursement
from receipts r
left join payments p on p.id = r.payment_id
left join disbursements d on d.id = r.disbursement_id;

.print ## Distinct users
select
    (select count(distinct user_id) from payments) as payment_users,
    (select count(distinct user_id) from receipts) as receipt_users,
    (select count(distinct user_id) from disbursements) as disbursement_users,
    (select count(distinct user_id) from payments where status = 'SUCCESSFUL') as successful_payment_users;

.print ## Beneficiary ownership
select count(*) as beneficiaries, sum((users > 1)::int) as shared_by_multiple_users
from (select beneficiary_id, count(distinct user_id) as users from receipts group by 1);

.print ## Beneficiaries per user
select beneficiary_bucket, count(*) as users from (
    select user_id, case
        when count(distinct beneficiary_id) = 1 then '1'
        when count(distinct beneficiary_id) <= 3 then '2-3'
        when count(distinct beneficiary_id) <= 9 then '4-9'
        else '10+' end as beneficiary_bucket
    from receipts group by 1
) group by 1 order by 2 desc;

.print ## Does one beneficiary use several countries or payout destinations?
select
    count(*) as beneficiaries,
    sum((countries > 1)::int) as multi_country,
    sum((payers > 1)::int) as multi_payer_destination,
    sum((types > 1)::int) as multi_payout_type
from (
    select r.beneficiary_id,
        count(distinct r.destination_country_code) as countries,
        count(distinct d.payer_destination_name) as payers,
        count(distinct d.type) as types
    from receipts r join disbursements d on d.id = r.disbursement_id
    group by 1
);

.print ## Retry chains
with chains as (
    select r.payment_id, count(*) as attempts,
        count(distinct r.beneficiary_id) as beneficiaries,
        count(distinct d.provider) as providers,
        count(distinct r.destination_country_code) as countries,
        count(distinct r.destination_currency) as currencies,
        count(distinct r.amount_charged) as charged_values,
        count(distinct r.exchange_rate) as fx_values,
        epoch(max(r.created_at) - min(r.created_at)) / 60 as span_minutes
    from receipts r left join disbursements d on d.id = r.disbursement_id
    group by 1 having count(*) > 1
)
select count(*) as multi_attempt_payments, sum(attempts) as receipts,
    sum((beneficiaries > 1)::int) as changed_beneficiary,
    sum((providers > 1)::int) as changed_provider,
    sum((countries > 1)::int) as changed_country,
    sum((currencies > 1)::int) as changed_currency,
    sum((charged_values > 1)::int) as changed_charged_amount,
    sum((fx_values > 1)::int) as changed_fx,
    round(median(span_minutes), 1) as median_span_minutes,
    round(quantile_cont(span_minutes, 0.9), 1) as p90_span_minutes,
    round(max(span_minutes), 1) as max_span_minutes
from chains;

.print ## Final attempt outcome compared with any attempt
with ranked as (
    select r.payment_id, d.status_lc,
        row_number() over (partition by r.payment_id order by r.created_at desc, r.id) as reverse_rank
    from receipts r left join disbursements d on d.id = r.disbursement_id
    qualify count(*) over (partition by r.payment_id) > 1
)
select status_lc as latest_attempt_status, count(*) as payments
from ranked where reverse_rank = 1 group by 1 order by 2 desc;

.print ## Payments with more than one delivered attempt
with delivered as (
    select r.payment_id, count(*) as delivered_attempts, count(distinct r.beneficiary_id) as beneficiaries,
        count(distinct d.provider) as providers, sum(r.amount_charged) as charged_sum
    from receipts r join disbursements d on d.id = r.disbursement_id
    where d.status_lc in ('paid', 'success', 'completed', 'delivered')
    group by 1 having count(*) > 1
)
select count(*) as payments, sum(delivered_attempts) as delivered_attempts,
    sum((beneficiaries > 1)::int) as different_beneficiary,
    sum((providers > 1)::int) as different_provider,
    sum(delivered.charged_sum) as charged_sum,
    sum(p.amount) as payment_amount
from delivered join payments p on p.id = delivered.payment_id;

.print ## Receipt and disbursement field agreement
select
    sum((r.destination_country_code is distinct from d.destination_country)::int) as country_differs,
    sum((d.destination_country is null)::int) as disbursement_country_null,
    sum((d.destination_country = 'COSTA RICA')::int) as country_spelled_out,
    sum((r.destination_currency is distinct from d.destination_currency)::int) as currency_differs,
    sum((abs(r.destination_amount - d.amount) > 0.005)::int) as amount_differs_over_half_cent,
    sum((abs(r.destination_amount - d.amount) > 1)::int) as amount_differs_over_one_unit
from receipts r join disbursements d on d.id = r.disbursement_id;

.print ## Country disagreements that remain after standardizing
select r.destination_country_code, d.destination_country, r.destination_currency, d.destination_currency as disbursement_currency, count(*) as n
from receipts r join disbursements d on d.id = r.disbursement_id
where d.destination_country is not null
  and r.destination_country_code <> replace(d.destination_country, 'COSTA RICA', 'CR')
group by all order by n desc;

.print ## Currency disagreements
select r.destination_country_code, r.destination_currency, d.destination_currency as disbursement_currency, count(*) as n
from receipts r join disbursements d on d.id = r.disbursement_id
where r.destination_currency <> d.destination_currency
group by all order by n desc;
