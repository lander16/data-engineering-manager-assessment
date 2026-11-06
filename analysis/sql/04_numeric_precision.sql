set timezone = 'UTC';

-- All checks read the original text, so nothing here depends on a numeric cast.

.print ## Text shape of numeric fields
select field,
    count(*) as n,
    sum((not regexp_full_match(txt, '-?[0-9]+(\.[0-9]+)?'))::int) as not_plain_decimal,
    sum((txt ilike '%e%')::int) as scientific_notation,
    sum((txt like '-%')::int) as negative,
    sum((regexp_full_match(txt, '-?0+[0-9]+.*'))::int) as leading_zero,
    sum((txt like '%.%0')::int) as trailing_zero,
    sum((txt like '%,%')::int) as has_thousands_separator,
    sum((txt not like '%.%')::int) as no_decimal_point,
    max(length(split_part(ltrim(txt, '-'), '.', 1))) as max_integer_digits,
    max(case when txt like '%.%' then length(split_part(txt, '.', 2)) else 0 end) as max_decimal_places
from numeric_text group by 1 order by 1;

.print ## Decimal place distribution
select field,
    case when txt like '%.%' then length(split_part(txt, '.', 2)) else 0 end as decimal_places,
    count(*) as n,
    round(100.0 * count(*) / sum(count(*)) over (partition by field), 3) as pct,
    min(txt) as example
from numeric_text group by 1, 2 order by 1, 2;

.print ## Binary floating-point artifacts: more than 6 decimal places
select field, count(*) as n, min(txt) as example_min, max(txt) as example_max
from numeric_text
where case when txt like '%.%' then length(split_part(txt, '.', 2)) else 0 end > 6
group by 1 order by 1;

.print ## Lossless decimal scale checks
select field, count(*) as n,
    sum((try_cast(txt as decimal(38, 2)) is null)::int) as fail_decimal_38_2_cast,
    sum((cast(try_cast(txt as decimal(38, 12)) as decimal(38, 12)) <> cast(try_cast(txt as decimal(38, 2)) as decimal(38, 12)))::int) as changed_at_scale_2,
    sum((cast(try_cast(txt as decimal(38, 12)) as decimal(38, 12)) <> cast(try_cast(txt as decimal(38, 4)) as decimal(38, 12)))::int) as changed_at_scale_4,
    sum((cast(try_cast(txt as decimal(38, 12)) as decimal(38, 12)) <> cast(try_cast(txt as decimal(38, 6)) as decimal(38, 12)))::int) as changed_at_scale_6,
    sum((cast(try_cast(txt as decimal(38, 12)) as decimal(38, 12)) <> cast(try_cast(txt as decimal(38, 8)) as decimal(38, 12)))::int) as changed_at_scale_8
from numeric_text group by 1 order by 1;

.print ## Exact decimal totals compared with double totals
select field,
    sum(cast(txt as decimal(38, 12))) as exact_decimal_total,
    sum(cast(txt as double)) as double_total,
    abs(sum(cast(txt as decimal(38, 12)))::double - sum(cast(txt as double))) as absolute_difference
from numeric_text group by 1 order by 1;

.print ## Numeric range
select field, min(cast(txt as decimal(38, 12))) as min_value,
    quantile_disc(cast(txt as decimal(38, 12)), 0.5) as median,
    quantile_disc(cast(txt as decimal(38, 12)), 0.99) as p99,
    max(cast(txt as decimal(38, 12))) as max_value
from numeric_text group by 1 order by 1;

.print ## Non-positive values
select 'payments.amount' as field, status as context, count(*) as n, min(amount) as min_value, max(amount) as max_value
from payments where amount <= 0 group by 2
union all select 'receipts.amount_charged', promotion_amount > 0, count(*), min(amount_charged), max(amount_charged)
from receipts where amount_charged <= 0 group by 2
union all select 'receipts.destination_amount', 'all', count(*), min(destination_amount), max(destination_amount)
from receipts where destination_amount <= 0
union all select 'disbursements.amount', 'all', count(*), min(amount), max(amount)
from disbursements where amount <= 0;

.print ## Decimal places by currency for local amounts
select destination_currency,
    case when destination_amount like '%.%' then length(split_part(destination_amount, '.', 2)) else 0 end as decimal_places,
    count(*) as n
from raw_receipts group by all order by 1, 2;

.print ## Exchange rate by currency
select destination_country_code, destination_currency, count(*) as n,
    min(exchange_rate) as min_rate, quantile_disc(exchange_rate, 0.01) as p01,
    median(exchange_rate) as median_rate, quantile_disc(exchange_rate, 0.99) as p99,
    max(exchange_rate) as max_rate
from receipts group by all order by n desc;

.print ## Exchange rate decimal places by currency
select destination_currency,
    case when exchange_rate like '%.%' then length(split_part(exchange_rate, '.', 2)) else 0 end as decimal_places,
    count(*) as n
from raw_receipts group by all order by 1, 2;

.print ## Fee distribution
select fee, count(*) as n, round(100.0 * count(*) / sum(count(*)) over (), 2) as pct
from receipts group by 1 order by n desc limit 15;

.print ## Accounting identities, using exact decimals
select count(*) as joined_rows,
    sum((p.amount = r.amount_charged + r.fee)::int) as payment_equals_charged_plus_fee_exact,
    sum((abs(p.amount - (r.amount_charged + r.fee)) <= 0.01)::int) as within_one_cent,
    sum((abs(p.amount - (r.amount_charged + r.fee)) > 1)::int) as off_by_over_one_dollar
from receipts r join payments p on p.id = r.payment_id;

.print ## Payment identity failures by status and promotion
select p.status, r.promotion_amount > 0 as has_promotion, count(*) as n,
    min(p.amount - (r.amount_charged + r.fee)) as min_gap,
    max(p.amount - (r.amount_charged + r.fee)) as max_gap
from receipts r join payments p on p.id = r.payment_id
where abs(p.amount - (r.amount_charged + r.fee)) > 0.01
group by all order by n desc;

.print ## Value identity: destination amount compared with USD value times FX
with gaps as (
    select *, destination_amount - (amount_charged + promotion_amount) * exchange_rate as gap,
        abs(destination_amount - (amount_charged + promotion_amount) * exchange_rate) / nullif(destination_amount, 0) as relative_gap
    from receipts
)
select destination_currency, count(*) as n,
    sum((relative_gap <= 0.0001)::int) as within_1_bp,
    sum((relative_gap <= 0.01)::int) as within_1_pct,
    sum((relative_gap > 0.01)::int) as over_1_pct,
    max(relative_gap) as max_relative_gap
from gaps group by 1 order by n desc;

.print ## Rows breaking the value identity
select destination_country_code, destination_currency, amount_charged, fee, promotion_amount, exchange_rate, destination_amount,
    (amount_charged + promotion_amount) * exchange_rate as implied_destination
from receipts
where abs(destination_amount - (amount_charged + promotion_amount) * exchange_rate) / nullif(destination_amount, 0) > 0.01
order by abs(destination_amount - (amount_charged + promotion_amount) * exchange_rate) / nullif(destination_amount, 0) desc
limit 20;

.print ## Sender amount outliers
select bucket, count(*) as n, sum(amount) as usd from (
    select amount, case
        when amount < 0 then 'a. negative'
        when amount = 0 then 'b. zero'
        when amount < 5 then 'c. under 5'
        when amount < 100 then 'd. 5 to under 100'
        when amount < 500 then 'e. 100 to under 500'
        when amount < 1000 then 'f. 500 to under 1000'
        when amount < 3000 then 'g. 1000 to under 3000'
        else 'h. 3000 and above' end as bucket
    from payments where status = 'SUCCESSFUL'
) group by 1 order by 1;
