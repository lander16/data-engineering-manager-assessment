set timezone = 'UTC';

-- Checks on join fan-out, sub-cent amounts, timestamps, currency conflicts, and ACH payments.

.print ## Fan-out when joining successful payments to receipts
select sum(p.amount) as joined_usd,
    (select sum(amount) from payments where status = 'SUCCESSFUL') as correct_usd,
    sum(p.amount) - (select sum(amount) from payments where status = 'SUCCESSFUL') as overstatement_usd
from payments p join receipts r on r.payment_id = p.id
where p.status = 'SUCCESSFUL';

.print ## Payment amounts with 3 to 5 decimals, using the first receipt
with sub_cent as (
    select id, cast(amount as decimal(38, 9)) as amount
    from raw_payments
    where length(split_part(amount, '.', 2)) between 3 and 5
),
first_receipt as (
    select s.id, s.amount, r.fee, r.amount_charged, r.destination_amount, r.exchange_rate
    from sub_cent s left join receipts r on r.payment_id = s.id
    qualify row_number() over (partition by s.id order by r.created_at, r.id) = 1
)
select case
        when exchange_rate is null then 'no receipt'
        when exchange_rate = 1 then 'USD payout'
        else 'local currency payout' end as payout_group,
    count(*) as payments,
    sum((abs(amount - (amount_charged + fee)) < 0.006)::int) as ties_after_rounding,
    sum((exchange_rate <> 1 and abs(amount - (destination_amount / exchange_rate + fee)) < 0.001)::int) as exact_reverse_fx
from first_receipt group by 1 order by 2 desc;

.print ## updated_at before created_at
select count(*) as rows_,
    sum((date_trunc('second', d.created_at) = d.updated_at)::int) as equals_created_at_truncated_to_second,
    sum((r.updated_at not like '%.%')::int) as updated_at_has_no_fraction,
    min(epoch(d.updated_at - d.created_at)) as min_seconds,
    max(epoch(d.updated_at - d.created_at)) as max_seconds
from disbursements d join raw_disbursements r using (id)
where d.updated_at < d.created_at;

.print ## Whole-second updated_at by provider
select disbursement_provider, count(*) as n
from raw_disbursements
where updated_at is not null and updated_at not like '%.%'
group by 1 order by 2 desc;

.print ## Currency conflicts and USD receipts with a rate other than 1
select r.destination_country_code, r.destination_currency, d.destination_currency as disbursement_currency,
    r.exchange_rate, r.amount_charged, r.destination_amount, d.status as disbursement_status, p.status as payment_status
from receipts r
join disbursements d on d.id = r.disbursement_id
join payments p on p.id = r.payment_id
where r.destination_currency <> d.destination_currency
   or (r.destination_currency = 'USD' and r.exchange_rate <> 1)
order by 1, 4;

.print ## Delivered payouts on FAILED or REFUNDED payments
select p.status, p.detailed_status, p.type, p.amount, d.status as disbursement_status, d.provider,
    round(epoch(d.updated_at - d.created_at), 0) as payout_update_seconds,
    round(epoch(p.updated_at - p.created_at), 0) as payment_update_seconds,
    d.updated_at > p.updated_at as payout_updated_after_payment,
    p.has_chargeback
from payments p
join receipts r on r.payment_id = p.id
join disbursements d on d.id = r.disbursement_id
where p.status in ('FAILED', 'REFUNDED')
  and d.status_lc in ('paid', 'success', 'completed', 'delivered')
order by 1, 8;

.print ## ACH payments by status
select status, detailed_status, count(*) as n, sum(amount) as usd
from payments where type = 'ACH'
group by all order by n desc;

.print ## ACH payments pending settlement by payout result
select d.status_lc, count(*) as attempts
from payments p
join receipts r on r.payment_id = p.id
left join disbursements d on d.id = r.disbursement_id
where p.detailed_status = 'PENDING_USER_ACTION_ACH_SETTLEMENT'
group by 1 order by 2 desc;
