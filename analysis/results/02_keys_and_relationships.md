## Primary key candidates
|       key        | rows_  | non_null | distinct_values |
|------------------|-------:|---------:|----------------:|
| payments.id      | 788976 | 788976   | 788976          |
| receipts.id      | 743948 | 743948   | 743948          |
| disbursements.id | 743763 | 743763   | 743763          |
## Duplicates after excluding the id column
|  source_file  | duplicate_groups |
|---------------|-----------------:|
| payments      | 0                |
| receipts      | 0                |
| disbursements | 0                |
## Identifier format: expect 64 lowercase hex characters
|          field           |   n    | invalid |
|--------------------------|-------:|--------:|
| disbursements.id         | 743763 | 0       |
| disbursements.user_id    | 743763 | 0       |
| payments.id              | 788976 | 0       |
| payments.user_id         | 788976 | 0       |
| receipts.beneficiary_id  | 743948 | 0       |
| receipts.disbursement_id | 743948 | 0       |
| receipts.id              | 743948 | 0       |
| receipts.payment_id      | 743948 | 0       |
| receipts.user_id         | 743948 | 0       |
## Foreign key coverage
| receipts_without_payment | receipts_without_disbursement | payments_without_receipt | disbursements_without_receipt |
|-------------------------:|------------------------------:|-------------------------:|------------------------------:|
| 0                        | 185                           | 60749                    | 0                             |
## Receipts per payment
| receipts_per_payment | payments |
|---------------------:|---------:|
| 0                    | 60749    |
| 1                    | 715012   |
| 2                    | 11259    |
| 3                    | 1540     |
| 4                    | 312      |
| 5                    | 79       |
| 6                    | 21       |
| 7                    | 3        |
| 8                    | 1        |
## Receipts per disbursement
| receipts_per_disbursement | disbursements |
|--------------------------:|--------------:|
| 1                         | 743948        |
## User consistency across files
| receipt_vs_payment | receipt_vs_disbursement |
|-------------------:|------------------------:|
| 0                  | 0                       |
## Distinct users
| payment_users | receipt_users | disbursement_users | successful_payment_users |
|--------------:|--------------:|-------------------:|-------------------------:|
| 421412        | 394780        | 394776             | 392507                   |
## Beneficiary ownership
| beneficiaries | shared_by_multiple_users |
|--------------:|-------------------------:|
| 554117        | 0                        |
## Beneficiaries per user
| beneficiary_bucket | users  |
|--------------------|-------:|
| 1                  | 289700 |
| 2-3                | 92942  |
| 4-9                | 12044  |
| 10+                | 94     |
## Does one beneficiary use several countries or payout destinations?
| beneficiaries | multi_country | multi_payer_destination | multi_payout_type |
|--------------:|--------------:|------------------------:|------------------:|
| 554106        | 0             | 11698                   | 5307              |
## Retry chains
| multi_attempt_payments | receipts | changed_beneficiary | changed_provider | changed_country | changed_currency | changed_charged_amount | changed_fx | median_span_minutes | p90_span_minutes | max_span_minutes |
|-----------------------:|---------:|--------------------:|-----------------:|----------------:|-----------------:|-----------------------:|-----------:|--------------------:|-----------------:|-----------------:|
| 13215                  | 28936    | 2987                | 6318             | 1               | 26               | 1                      | 58         | 88.2                | 2654.1           | 99062.6          |
## Final attempt outcome compared with any attempt
| latest_attempt_status | payments |
|-----------------------|---------:|
| paid                  | 7518     |
| completed             | 2928     |
| success               | 1683     |
| cancelled             | 610      |
| failed                | 375      |
| rejected              | 59       |
| wire_released         | 14       |
| payable               | 11       |
| in_progress           | 8        |
| transmitted           | 5        |
| hold_by_payer         | 1        |
| NULL                  | 1        |
| hold_by_compliance    | 1        |
| on_hold               | 1        |
## Payments with more than one delivered attempt
| payments | delivered_attempts | different_beneficiary | different_provider | charged_sum  | payment_amount |
|---------:|-------------------:|----------------------:|-------------------:|-------------:|---------------:|
| 19       | 38                 | 1                     | 16                 | 10920.140000 | 5515.890000000 |
## Receipt and disbursement field agreement
| country_differs | disbursement_country_null | country_spelled_out | currency_differs | amount_differs_over_half_cent | amount_differs_over_one_unit |
|----------------:|--------------------------:|--------------------:|-----------------:|------------------------------:|-----------------------------:|
| 163             | 137                       | 25                  | 140              | 172010                        | 9971                         |
## Country disagreements that remain after standardizing
| destination_country_code | destination_country | destination_currency | disbursement_currency | n |
|--------------------------|---------------------|----------------------|-----------------------|--:|
| GT                       | MX                  | GTQ                  | MXN                   | 1 |
## Currency disagreements
| destination_country_code | destination_currency | disbursement_currency | n |
|--------------------------|----------------------|-----------------------|--:|
| PE                       | PEN                  | USD                   | 1 |
| DO                       | DOP                  | USD                   | 1 |
| GT                       | GTQ                  | MXN                   | 1 |
