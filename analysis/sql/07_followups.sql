set timezone = 'UTC';

-- Questions raised by scripts 01 to 06.

.print ## Payment amounts with more than 2 decimal places
with extra as (
    select p.id, p.amount as txt, cast(p.amount as decimal(38, 12)) as exact_amount,
        round(cast(p.amount as decimal(38, 12)), 2) as rounded_amount,
        length(split_part(p.amount, '.', 2)) as decimal_places,
        p.type, left(p.created_at, 7) as month
    from raw_payments p
    where length(split_part(p.amount, '.', 2)) > 2
)
select decimal_places, count(*) as n,
    sum(exact_amount - rounded_amount) as net_rounding_effect,
    max(abs(exact_amount - rounded_amount)) as max_rounding_effect,
    sum((round(cast(rounded_amount as float)::double, 9) = round(cast(txt as double), 9))::int) as equals_float32_of_rounded,
    min(month) as first_month, max(month) as last_month
from extra group by 1 order by 1;

.print ## Payment type of amounts with more than 2 decimal places
select type, count(*) as n from raw_payments
where length(split_part(amount, '.', 2)) > 2 group by 1 order by n desc;

.print ## Does rounding to cents restore the payment identity?
select
    sum((p.amount = r.amount_charged + r.fee)::int) as exact_before_rounding,
    sum((round(p.amount, 2) = r.amount_charged + r.fee)::int) as exact_after_rounding,
    count(*) as joined_rows
from receipts r join payments p on p.id = r.payment_id;

.print ## Remaining payment identity gaps after rounding, by gap
select round(p.amount, 2) - (r.amount_charged + r.fee) as gap, count(*) as n
from receipts r join payments p on p.id = r.payment_id
where round(p.amount, 2) <> r.amount_charged + r.fee
group by 1 order by n desc limit 12;

.print ## Receipt destination amount compared with disbursement amount
select d.provider, r.destination_currency, count(*) as n,
    sum((d.amount is null)::int) as null_disbursement_amount,
    sum((abs(r.destination_amount - d.amount) > 0.005)::int) as differs,
    round(100.0 * sum((abs(r.destination_amount - d.amount) > 0.005)::int) / count(*), 2) as differs_pct,
    round(max(abs(r.destination_amount - d.amount) / nullif(r.destination_amount, 0)) * 100, 4) as max_relative_pct
from receipts r join disbursements d on d.id = r.disbursement_id
group by all having count(*) >= 500 order by n desc;

.print ## Largest relative receipt and disbursement amount gaps
select d.provider, r.destination_currency, r.destination_amount, d.amount as disbursement_amount, d.status, r.exchange_rate
from receipts r join disbursements d on d.id = r.disbursement_id
where d.amount is not null and r.destination_amount > 0
order by abs(r.destination_amount - d.amount) / r.destination_amount desc limit 10;

.print ## Null disbursement amount
select provider, status_lc, strftime(created_at, '%Y-%m') as month, count(*) as n
from disbursements where amount is null group by all order by n desc limit 15;

.print ## Null disbursement updated_at
select provider, status_lc, count(*) as n, min(created_at) as first_seen, max(created_at) as last_seen
from disbursements where updated_at is null group by all order by n desc limit 15;

.print ## Null disbursement country
select provider, type, status_lc, count(*) as n
from disbursements where destination_country is null group by all order by n desc limit 10;

.print ## Disbursements updated before created
select provider, status_lc, count(*) as n, min(epoch(updated_at - created_at)) as min_seconds
from disbursements where updated_at < created_at group by all order by n desc;

.print ## Receipt and disbursement creation gap
select case
        when abs(epoch(d.created_at - r.created_at)) <= 1 then 'a. within 1 second'
        when abs(epoch(d.created_at - r.created_at)) <= 60 then 'b. within 1 minute'
        when abs(epoch(d.created_at - r.created_at)) <= 3600 then 'c. within 1 hour'
        when abs(epoch(d.created_at - r.created_at)) <= 86400 then 'd. within 1 day'
        else 'e. over 1 day' end as gap,
    count(*) as n, sum((d.created_at > r.created_at)::int) as disbursement_later
from receipts r join disbursements d on d.id = r.disbursement_id
group by 1 order by 1;

.print ## Delivered status that is followed by another attempt
with ordered as (
    select r.payment_id, d.status_lc,
        d.status_lc in ('paid', 'success', 'completed', 'delivered') as is_delivered,
        row_number() over (partition by r.payment_id order by r.created_at desc, r.id) as reverse_rank
    from receipts r left join disbursements d on d.id = r.disbursement_id
),
summary as (
    select payment_id,
        bool_or(is_delivered) as any_delivered,
        bool_or(is_delivered and reverse_rank = 1) as latest_delivered,
        max(status_lc) filter (where reverse_rank = 1) as latest_status
    from ordered group by 1
)
select latest_status, count(*) as payments
from summary where any_delivered and not latest_delivered
group by 1 order by 2 desc;

.print ## Rows where status says cancelled but raw status says otherwise
select d.provider, d.status, d.raw_status, d.provider_status, p.status as payment_status, count(*) as n
from disbursements d
left join receipts r on r.disbursement_id = d.id
left join payments p on p.id = r.payment_id
where d.status_lc = 'cancelled' and d.raw_status_lc <> 'cancelled'
group by all order by n desc;

.print ## Provider status contradicting normalized status
select status_lc, provider_status, count(*) as n
from disbursements
where (status_lc in ('paid', 'success', 'completed', 'delivered')
        and regexp_matches(lower(provider_status), 'fail|reject|cancel|refund|hold|error'))
   or (status_lc in ('failed', 'rejected', 'cancelled')
        and regexp_matches(lower(provider_status), 'complete|paid|success'))
group by all order by n desc;

.print ## Promotion amount distribution
select case
        when promotion_amount = 0 then 'a. none'
        when promotion_amount <= 5 then 'b. up to 5'
        when promotion_amount <= 20 then 'c. over 5 to 20'
        when promotion_amount <= 100 then 'd. over 20 to 100'
        else 'e. over 100' end as bucket,
    count(*) as n, sum(promotion_amount) as promotion_usd, sum((amount_charged = 0)::int) as charged_zero
from receipts group by 1 order by 1;

.print ## Promotions on delivered attempts by attempt status
select p.status as payment_status, d.status_lc, count(*) as n, sum(r.promotion_amount) as promotion_usd
from receipts r
join payments p on p.id = r.payment_id
left join disbursements d on d.id = r.disbursement_id
where r.amount_charged = 0 and r.promotion_amount > 0
group by all order by n desc limit 10;

.print ## Fully funded by promotion: does the user have an earlier refund?
with zero_charged as (
    select r.id, r.user_id, r.created_at, r.promotion_amount from receipts r
    where r.amount_charged = 0 and r.promotion_amount > 0
)
select count(*) as receipts,
    sum((exists (
        select 1 from payments p
        where p.user_id = z.user_id and p.status = 'REFUNDED' and p.updated_at <= z.created_at
    ))::int) as user_has_earlier_refund,
    sum((exists (
        select 1 from payments p
        where p.user_id = z.user_id and p.status = 'REFUNDED' and p.updated_at <= z.created_at
          and abs(p.amount - z.promotion_amount) <= 10
    ))::int) as earlier_refund_similar_amount
from zero_charged z;

.print ## Promotion by user delivery sequence
with delivered_attempts as (
    select r.user_id, r.promotion_amount, r.amount_charged,
        row_number() over (partition by r.user_id order by r.created_at, r.id) as sequence
    from receipts r join disbursements d on d.id = r.disbursement_id
    where d.status_lc in ('paid', 'success', 'completed', 'delivered')
)
select case when sequence = 1 then 'first' else 'later' end as position,
    count(*) as n, sum((promotion_amount > 0)::int) as with_promotion,
    sum((promotion_amount > 100)::int) as over_100, sum(promotion_amount) as promotion_usd
from delivered_attempts group by 1;

.print ## Volume with promotions: customer paid compared with value sent
select sum(r.amount_charged + r.fee) as customer_paid_on_delivered_attempts,
    sum(r.amount_charged + r.promotion_amount) as value_sent,
    sum(r.amount_charged) as charged,
    sum(r.fee) as fee,
    sum(r.promotion_amount) as promotion
from receipts r
join disbursements d on d.id = r.disbursement_id
join payments p on p.id = r.payment_id
where p.status = 'SUCCESSFUL' and d.status_lc in ('paid', 'success', 'completed', 'delivered');

.print ## Successful payments without receipts by month and type
select left(p.created_at, 7) as month, p.type, count(*) as n, sum(cast(p.amount as decimal(18, 2))) as usd
from raw_payments p
where p.status = 'SUCCESSFUL' and not exists (select 1 from raw_receipts r where r.payment_id = p.id)
group by all order by 1, 3 desc;

.print ## Age of unresolved successful payments at the extract end
with attempts as (
    select r.payment_id,
        sum((d.status_lc in ('paid', 'success', 'completed', 'delivered'))::int) as delivered,
        sum((d.status_lc in ('failed', 'rejected', 'cancelled', 'error_sending_payout_request', 'payout_not_processed'))::int) as failed,
        count(*) as attempts
    from receipts r left join disbursements d on d.id = r.disbursement_id group by 1
),
unresolved as (
    select p.*, case when coalesce(a.failed, 0) = a.attempts then 'all_attempts_failed' else 'in_flight_or_unknown' end as outcome
    from payments p join attempts a on a.payment_id = p.id
    where p.status = 'SUCCESSFUL' and coalesce(a.delivered, 0) = 0
),
extract_end as (select max(created_at) as extract_at from payments)
select outcome, count(*) as payments, sum(amount) as usd,
    sum((created_at >= extract_at - interval 2 day)::int) as under_2_days,
    sum((created_at < extract_at - interval 2 day and created_at >= extract_at - interval 30 day)::int) as days_2_to_30,
    sum((created_at < extract_at - interval 30 day)::int) as over_30_days,
    sum(has_chargeback::int) as chargebacks
from unresolved, extract_end group by 1;

.print ## Receipts without a disbursement record
select left(r.created_at, 7) as month, count(*) as n
from raw_receipts r
where not exists (select 1 from raw_disbursements d where d.id = r.disbursement_id)
group by 1 order by 1;

.print ## Payment status for receipts without disbursement
select p.status, count(*) as n
from receipts r join payments p on p.id = r.payment_id
anti join disbursements d on d.id = r.disbursement_id
group by 1;

.print ## total_intents and state code population by type and status
select status, type, count(total_intents) as total_intents_populated, count(location_of_request_state_code) as state_populated, count(*) as n
from raw_payments group by all having count(total_intents) > 0 or count(location_of_request_state_code) > 0 order by n desc;

.print ## State code values longer than 2 characters
select location_of_request_state_code, count(*) as n
from raw_payments where length(location_of_request_state_code) > 2 group by 1 order by n desc;

.print ## Activity around the largest payment gap
select 'payments' as source_file, count(*) as rows_in_gap from payments
where created_at > timestamptz '2026-06-12 14:06:06+00' and created_at < timestamptz '2026-06-12 16:55:23+00'
union all select 'receipts', count(*) from receipts
where created_at > timestamptz '2026-06-12 14:06:06+00' and created_at < timestamptz '2026-06-12 16:55:23+00'
union all select 'disbursements', count(*) from disbursements
where created_at > timestamptz '2026-06-12 14:06:06+00' and created_at < timestamptz '2026-06-12 16:55:23+00';

.print ## Refund timing
select count(*) as refunded_payments,
    round(median(epoch(p.updated_at - p.created_at)) / 3600, 1) as median_hours_to_refund_update
from payments p
where p.status = 'REFUNDED';

.print ## Do null disbursement fields fall on the same rows?
select provider, status_lc,
    amount is null as amount_null,
    updated_at is null as updated_at_null,
    destination_country is null as country_null,
    destination_currency is null as currency_null,
    count(*) as n
from disbursements
where amount is null or updated_at is null or destination_country is null or destination_currency is null
group by all order by n desc;
