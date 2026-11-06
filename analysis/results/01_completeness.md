## Row counts
|  source_file  | row_count |
|---------------|----------:|
| disbursements | 743763    |
| payments      | 788976    |
| receipts      | 743948    |
## Column completeness, cardinality, and text hygiene
|  source_file  |          column_name           | row_count | non_null | nulls  | null_pct | distinct_values | empty_strings | padded | null_like | min_len | max_len |
|---------------|--------------------------------|----------:|---------:|-------:|---------:|----------------:|--------------:|-------:|----------:|--------:|--------:|
| disbursements | amount                         | 743763    | 743195   | 568    | 0.076    | 135438          | 0             | 0      | 0         | 1       | 11      |
| disbursements | created_at                     | 743763    | 743763   | 0      | 0.0      | 743763          | 0             | 0      | 0         | 32      | 32      |
| disbursements | destination_country            | 743763    | 743626   | 137    | 0.018    | 12              | 0             | 0      | 0         | 2       | 10      |
| disbursements | destination_currency           | 743763    | 743626   | 137    | 0.018    | 9               | 0             | 0      | 0         | 3       | 3       |
| disbursements | disbursement_provider          | 743763    | 743763   | 0      | 0.0      | 12              | 0             | 0      | 0         | 10      | 11      |
| disbursements | id                             | 743763    | 743763   | 0      | 0.0      | 743763          | 0             | 0      | 0         | 64      | 64      |
| disbursements | payer_destination_name         | 743763    | 743763   | 0      | 0.0      | 213             | 0             | 0      | 0         | 13      | 15      |
| disbursements | provider_status                | 743763    | 164156   | 579607 | 77.929   | 32              | 0             | 0      | 0         | 3       | 43      |
| disbursements | raw_status                     | 743763    | 743763   | 0      | 0.0      | 26              | 0             | 0      | 0         | 4       | 28      |
| disbursements | status                         | 743763    | 743763   | 0      | 0.0      | 21              | 0             | 0      | 0         | 4       | 28      |
| disbursements | type                           | 743763    | 743763   | 0      | 0.0      | 4               | 0             | 0      | 0         | 4       | 13      |
| disbursements | updated_at                     | 743763    | 742947   | 816    | 0.11     | 742947          | 0             | 0      | 0         | 25      | 32      |
| disbursements | user_id                        | 743763    | 743763   | 0      | 0.0      | 394776          | 0             | 0      | 0         | 64      | 64      |
| payments      | amount                         | 788976    | 788976   | 0      | 0.0      | 34890           | 0             | 0      | 0         | 1       | 13      |
| payments      | created_at                     | 788976    | 788976   | 0      | 0.0      | 788976          | 0             | 0      | 0         | 32      | 32      |
| payments      | currency                       | 788976    | 788976   | 0      | 0.0      | 1               | 0             | 0      | 0         | 3       | 3       |
| payments      | detailed_status                | 788976    | 786231   | 2745   | 0.348    | 25              | 0             | 0      | 0         | 10      | 44      |
| payments      | has_dispute_chargeback         | 788976    | 788976   | 0      | 0.0      | 2               | 0             | 0      | 0         | 4       | 5       |
| payments      | id                             | 788976    | 788976   | 0      | 0.0      | 788976          | 0             | 0      | 0         | 64      | 64      |
| payments      | location_of_request_state_code | 788976    | 428      | 788548 | 99.946   | 42              | 0             | 0      | 0         | 2       | 5       |
| payments      | status                         | 788976    | 788976   | 0      | 0.0      | 5               | 0             | 0      | 0         | 6       | 19      |
| payments      | total_intents                  | 788976    | 16652    | 772324 | 97.889   | 1               | 0             | 0      | 0         | 1       | 1       |
| payments      | type                           | 788976    | 788975   | 1      | 0.0      | 5               | 0             | 0      | 0         | 3       | 10      |
| payments      | updated_at                     | 788976    | 788976   | 0      | 0.0      | 788976          | 0             | 0      | 0         | 25      | 32      |
| payments      | user_id                        | 788976    | 788976   | 0      | 0.0      | 421412          | 0             | 0      | 0         | 64      | 64      |
| receipts      | amount_charged                 | 743948    | 743948   | 0      | 0.0      | 24934           | 0             | 0      | 0         | 1       | 7       |
| receipts      | beneficiary_id                 | 743948    | 743948   | 0      | 0.0      | 554117          | 0             | 0      | 0         | 64      | 64      |
| receipts      | created_at                     | 743948    | 743948   | 0      | 0.0      | 743948          | 0             | 0      | 0         | 25      | 32      |
| receipts      | destination_amount             | 743948    | 743948   | 0      | 0.0      | 87296           | 0             | 0      | 0         | 1       | 11      |
| receipts      | destination_country_code       | 743948    | 743948   | 0      | 0.0      | 11              | 0             | 0      | 0         | 2       | 2       |
| receipts      | destination_currency           | 743948    | 743948   | 0      | 0.0      | 9               | 0             | 0      | 0         | 3       | 3       |
| receipts      | disbursement_id                | 743948    | 743948   | 0      | 0.0      | 743948          | 0             | 0      | 0         | 64      | 64      |
| receipts      | exchange_rate                  | 743948    | 743948   | 0      | 0.0      | 1922            | 0             | 0      | 0         | 1       | 7       |
| receipts      | fee                            | 743948    | 743948   | 0      | 0.0      | 1050            | 0             | 0      | 0         | 1       | 5       |
| receipts      | id                             | 743948    | 743948   | 0      | 0.0      | 743948          | 0             | 0      | 0         | 64      | 64      |
| receipts      | payment_id                     | 743948    | 743948   | 0      | 0.0      | 728227          | 0             | 0      | 0         | 64      | 64      |
| receipts      | promotion_amount               | 743948    | 743948   | 0      | 0.0      | 349             | 0             | 0      | 0         | 1       | 6       |
| receipts      | user_id                        | 743948    | 743948   | 0      | 0.0      | 394780          | 0             | 0      | 0         | 64      | 64      |
## Columns with no values at all
| source_file | column_name |
|-------------|-------------|
| payments    | reason      |
| payments    | error_code  |
## Null-like literal values found
| source_file | column_name | value | n |
|-------------|-------------|-------|--:|
