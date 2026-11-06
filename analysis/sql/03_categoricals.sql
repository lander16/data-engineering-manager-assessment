set timezone = 'UTC';

.print ## Payment status and detailed status
select status, detailed_status, count(*) as n, sum(amount) as usd
from payments group by all order by n desc;

.print ## Payment type by status
select type, status, count(*) as n from payments group by all order by type, n desc;

.print ## Payment currency
select currency, count(*) as n from payments group by 1;

.print ## Chargeback flag values
select has_dispute_chargeback, count(*) as n from raw_payments group by 1;

.print ## total_intents by payment type
select type, total_intents, count(*) as n from raw_payments group by all order by n desc;

.print ## total_intents by month
select left(created_at, 7) as month, count(total_intents) as populated, count(*) as rows_
from raw_payments group by 1 order by 1;

.print ## Disbursement status, raw status, and provider status
select status, raw_status, provider_status, count(*) as n
from raw_disbursements group by all order by n desc;

.print ## Status vocabulary by provider
select disbursement_provider, status, count(*) as n
from raw_disbursements group by all order by 1, n desc;

.print ## Normalized status and raw status disagreements
select disbursement_provider, status, raw_status, count(*) as n
from raw_disbursements where lower(status) <> lower(raw_status)
group by all order by n desc;

.print ## Payout type
select type, count(*) as n from raw_disbursements group by 1 order by n desc;

.print ## Country and currency: disbursements
select destination_country, destination_currency, count(*) as n
from raw_disbursements group by all order by n desc;

.print ## Country and currency: receipts
select destination_country_code, destination_currency, count(*) as n
from raw_receipts group by all order by n desc;

.print ## Provider by payout type and country
select disbursement_provider, type, destination_country, count(*) as n
from raw_disbursements group by all order by 1, n desc;

.print ## Payer destination concentration
select count(distinct payer_destination_name) as destinations,
    max(n) as largest_destination_rows,
    median(n) as median_destination_rows
from (select payer_destination_name, count(*) as n from raw_disbursements group by 1);

.print ## Do payer destinations span countries?
select countries, count(*) as payer_destinations from (
    select payer_destination_name, count(distinct destination_country) as countries
    from raw_disbursements group by 1
) group by 1 order by 1;

.print ## State code population
select count(location_of_request_state_code) as populated, count(distinct location_of_request_state_code) as states
from raw_payments;
