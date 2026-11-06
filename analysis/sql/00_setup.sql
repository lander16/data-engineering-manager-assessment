-- Loads every CSV as text so that nothing is coerced before it has been inspected.
-- The source files are only read. All output goes to a disposable DuckDB file.

create or replace table raw_payments as
select * from read_csv('data/payments.csv',
    header = true, delim = ',', quote = '"', escape = '"',
    all_varchar = true, strict_mode = true, auto_detect = false,
    columns = {
        'id': 'VARCHAR', 'amount': 'VARCHAR', 'currency': 'VARCHAR', 'user_id': 'VARCHAR',
        'status': 'VARCHAR', 'detailed_status': 'VARCHAR', 'error_code': 'VARCHAR',
        'reason': 'VARCHAR', 'type': 'VARCHAR', 'total_intents': 'VARCHAR',
        'location_of_request_state_code': 'VARCHAR', 'has_dispute_chargeback': 'VARCHAR',
        'created_at': 'VARCHAR', 'updated_at': 'VARCHAR'
    });

create or replace table raw_receipts as
select * from read_csv('data/receipts.csv',
    header = true, delim = ',', quote = '"', escape = '"',
    all_varchar = true, strict_mode = true, auto_detect = false,
    columns = {
        'id': 'VARCHAR', 'destination_country_code': 'VARCHAR', 'destination_currency': 'VARCHAR',
        'amount_charged': 'VARCHAR', 'fee': 'VARCHAR', 'exchange_rate': 'VARCHAR',
        'promotion_amount': 'VARCHAR', 'destination_amount': 'VARCHAR', 'user_id': 'VARCHAR',
        'payment_id': 'VARCHAR', 'disbursement_id': 'VARCHAR', 'beneficiary_id': 'VARCHAR',
        'created_at': 'VARCHAR'
    });

create or replace table raw_disbursements as
select * from read_csv('data/disbursements.csv',
    header = true, delim = ',', quote = '"', escape = '"',
    all_varchar = true, strict_mode = true, auto_detect = false,
    columns = {
        'id': 'VARCHAR', 'user_id': 'VARCHAR', 'type': 'VARCHAR', 'status': 'VARCHAR',
        'raw_status': 'VARCHAR', 'provider_status': 'VARCHAR', 'amount': 'VARCHAR',
        'disbursement_provider': 'VARCHAR', 'payer_destination_name': 'VARCHAR',
        'destination_country': 'VARCHAR', 'destination_currency': 'VARCHAR',
        'created_at': 'VARCHAR', 'updated_at': 'VARCHAR'
    });

-- Long form of every column, used by the completeness profile.
create or replace table column_values as
select 'payments' as source_file, name as column_name, value
from (unpivot raw_payments on columns(*) into name name value value)
union all
select 'receipts', name, value
from (unpivot raw_receipts on columns(*) into name name value value)
union all
select 'disbursements', name, value
from (unpivot raw_disbursements on columns(*) into name name value value);

-- Row counts include nulls, which UNPIVOT drops.
create or replace table file_rows as
select 'payments' as source_file, count(*) as row_count from raw_payments
union all select 'receipts', count(*) from raw_receipts
union all select 'disbursements', count(*) from raw_disbursements;

-- Every numeric-looking field, still as text.
create or replace table numeric_text as
select 'payments.amount' as field, amount as txt from raw_payments where amount is not null
union all select 'payments.total_intents', total_intents from raw_payments where total_intents is not null
union all select 'receipts.amount_charged', amount_charged from raw_receipts where amount_charged is not null
union all select 'receipts.fee', fee from raw_receipts where fee is not null
union all select 'receipts.exchange_rate', exchange_rate from raw_receipts where exchange_rate is not null
union all select 'receipts.promotion_amount', promotion_amount from raw_receipts where promotion_amount is not null
union all select 'receipts.destination_amount', destination_amount from raw_receipts where destination_amount is not null
union all select 'disbursements.amount', amount from raw_disbursements where amount is not null;

-- Every timestamp field, still as text.
create or replace table timestamp_text as
select 'payments.created_at' as field, created_at as txt from raw_payments where created_at is not null
union all select 'payments.updated_at', updated_at from raw_payments where updated_at is not null
union all select 'receipts.created_at', created_at from raw_receipts where created_at is not null
union all select 'disbursements.created_at', created_at from raw_disbursements where created_at is not null
union all select 'disbursements.updated_at', updated_at from raw_disbursements where updated_at is not null;

-- Typed helpers for relationship checks. Decimal scales are confirmed by 04_numeric_precision.sql.
create or replace table payments as
select id, user_id, cast(amount as decimal(38, 9)) as amount, currency, status, detailed_status, type,
       has_dispute_chargeback = 'True' as has_chargeback,
       cast(created_at as timestamptz) as created_at, cast(updated_at as timestamptz) as updated_at
from raw_payments;

create or replace table receipts as
select id, user_id, payment_id, disbursement_id, beneficiary_id,
       destination_country_code, destination_currency,
       cast(amount_charged as decimal(18, 6)) as amount_charged,
       cast(fee as decimal(18, 6)) as fee,
       cast(exchange_rate as decimal(18, 8)) as exchange_rate,
       cast(promotion_amount as decimal(18, 6)) as promotion_amount,
       cast(destination_amount as decimal(24, 6)) as destination_amount,
       cast(created_at as timestamptz) as created_at
from raw_receipts;

create or replace table disbursements as
select id, user_id, type, status, lower(status) as status_lc, raw_status, lower(raw_status) as raw_status_lc,
       provider_status, cast(amount as decimal(24, 6)) as amount,
       disbursement_provider as provider, payer_destination_name,
       destination_country, destination_currency,
       cast(created_at as timestamptz) as created_at, cast(updated_at as timestamptz) as updated_at
from raw_disbursements;
