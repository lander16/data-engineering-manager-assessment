## Fan-out when joining successful payments to receipts
|     joined_usd      |     correct_usd     | overstatement_usd |
|--------------------:|--------------------:|------------------:|
| 244268337.894168989 | 237730447.406696304 | 6537890.487472685 |
## Payment amounts with 3 to 5 decimals, using the first receipt
|     payout_group      | payments | ties_after_rounding | exact_reverse_fx |
|-----------------------|---------:|--------------------:|-----------------:|
| USD payout            | 102      | 102                 | 0                |
| local currency payout | 23       | 23                  | 23               |
| no receipt            | 13       | NULL                | NULL             |
## updated_at before created_at
| rows_ | equals_created_at_truncated_to_second | updated_at_has_no_fraction | min_seconds | max_seconds |
|------:|--------------------------------------:|---------------------------:|------------:|------------:|
| 18    | 18                                    | 18                         | -0.604596   | -0.055595   |
## Whole-second updated_at by provider
| disbursement_provider | n  |
|-----------------------|---:|
| PROVIDER 3            | 98 |
| PROVIDER 7            | 1  |
## Currency conflicts and USD receipts with a rate other than 1
| destination_country_code | destination_currency | disbursement_currency | exchange_rate | amount_charged | destination_amount | disbursement_status | payment_status |
|--------------------------|----------------------|-----------------------|--------------:|---------------:|-------------------:|---------------------|----------------|
| DO                       | USD                  | USD                   | 56.24000000   | 60.000000      | 3374.400000        | CANCELLED           | REFUNDED       |
| DO                       | DOP                  | USD                   | 57.46000000   | 100.000000     | 5746.000000        | FAILED              | SUCCESSFUL     |
| DO                       | USD                  | USD                   | 58.27000000   | 80.000000      | 4661.600000        | CANCELLED           | REFUNDED       |
| GT                       | GTQ                  | MXN                   | 7.48000000    | 50.000000      | 374.000000         | CANCELLED           | REFUNDED       |
| PE                       | PEN                  | USD                   | 3.29000000    | 50.000000      | 164.500000         | FAILED              | REFUNDED       |
## Delivered payouts on FAILED or REFUNDED payments
|  status  |         detailed_status          | type |    amount     | disbursement_status |  provider  | payout_update_seconds | payment_update_seconds | payout_updated_after_payment | has_chargeback |
|----------|----------------------------------|------|--------------:|---------------------|------------|----------------------:|-----------------------:|------------------------------|----------------|
| FAILED   | FAILED_DUE_TO_INSUFFICIENT_FUNDS | ACH  | 10.000000000  | Success             | PROVIDER 3 | 5.0                   | 170325.0               | false                        | false          |
| FAILED   | FAILED_DUE_TO_INSUFFICIENT_FUNDS | ACH  | 502.990000000 | COMPLETED           | PROVIDER 9 | 3.0                   | 408503.0               | false                        | false          |
| REFUNDED | SUCCESSFUL                       | CARD | 102.990000000 | Success             | PROVIDER 3 | 28.0                  | 1946.0                 | true                         | false          |
| REFUNDED | NULL                             | CARD | 502.990000000 | Success             | PROVIDER 3 | 16.0                  | 2569.0                 | true                         | false          |
| REFUNDED | NULL                             | CARD | 49.770000000  | Success             | PROVIDER 3 | 10.0                  | 4281.0                 | true                         | false          |
| REFUNDED | SUCCESSFUL                       | CARD | 407.990000000 | PAID                | PROVIDER 8 | 9130.0                | 4925.0                 | true                         | false          |
| REFUNDED | SUCCESSFUL                       | CARD | 52.990000000  | Success             | PROVIDER 3 | 4.0                   | 13545.0                | false                        | false          |
| REFUNDED | SUCCESSFUL                       | CARD | 763.240000000 | PAID                | PROVIDER 8 | 214304.0              | 18280.0                | true                         | false          |
| REFUNDED | SUCCESSFUL                       | CARD | 17.520000000  | Success             | PROVIDER 3 | 5.0                   | 1452646.0              | false                        | false          |
## ACH payments by status
|   status   |               detailed_status                | n  |       usd       |
|------------|----------------------------------------------|---:|----------------:|
| SUCCESSFUL | SUCCESSFUL                                   | 49 | 15953.170000000 |
| FAILED     | FAILED_DUE_TO_EARLY_INSUFFICIENT_FUNDS_CHECK | 22 | 16860.590000000 |
| SUCCESSFUL | PENDING_USER_ACTION_ACH_SETTLEMENT           | 10 | 3941.640000000  |
| FAILED     | FAILED_DUE_TO_BALANCE_STALE                  | 7  | 3044.990000000  |
| FAILED     | FAILED_DUE_TO_BALANCE_NOT_PRESENT            | 2  | 1515.000000000  |
| FAILED     | FAILED_DUE_TO_INSUFFICIENT_FUNDS             | 2  | 512.990000000   |
| REFUNDED   | NULL                                         | 1  | 604.980000000   |
## ACH payments pending settlement by payout result
| status_lc | attempts |
|-----------|---------:|
| completed | 7        |
| paid      | 2        |
| rejected  | 2        |
| failed    | 1        |
| success   | 1        |
