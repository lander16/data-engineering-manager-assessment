## Payment amounts with more than 2 decimal places
| decimal_places |  n  | net_rounding_effect | max_rounding_effect | equals_float32_of_rounded | first_month | last_month |
|---------------:|----:|--------------------:|--------------------:|--------------------------:|-------------|------------|
| 3              | 94  | -0.379000000000     | 0.005000000000      | 0                         | 2026-01     | 2026-09    |
| 4              | 39  | 0.005100000000      | 0.004100000000      | 0                         | 2026-01     | 2026-09    |
| 5              | 5   | 0.000710000000      | 0.003910000000      | 0                         | 2026-01     | 2026-08    |
| 8              | 4   | 0.002754810000      | 0.002755420000      | 3                         | 2026-02     | 2026-09    |
| 9              | 685 | -0.003184211000     | 0.001943794000      | 684                       | 2026-01     | 2026-09    |
## Payment type of amounts with more than 2 decimal places
|   type    |  n  |
|-----------|----:|
| CASH      | 687 |
| CARD      | 139 |
| APPLE_PAY | 1   |
## Does rounding to cents restore the payment identity?
| exact_before_rounding | exact_after_rounding | joined_rows |
|----------------------:|---------------------:|------------:|
| 742465                | 742978               | 743948      |
## Remaining payment identity gaps after rounding, by gap
|    gap    |  n  |
|----------:|----:|
| 2.990000  | 420 |
| 4.980000  | 158 |
| -1.000000 | 141 |
| 6.490000  | 37  |
| 5.990000  | 28  |
| 0.010000  | 23  |
| 1.990000  | 12  |
| 0.760000  | 8   |
| 0.380000  | 7   |
| 0.190000  | 6   |
| 3.800000  | 6   |
| 5.700000  | 6   |
## Receipt destination amount compared with disbursement amount
|  provider   | destination_currency |   n    | null_disbursement_amount | differs | differs_pct | max_relative_pct |
|-------------|----------------------|-------:|-------------------------:|--------:|------------:|-----------------:|
| PROVIDER 3  | MXN                  | 243048 | 137                      | 0       | 0.0         | 0.0              |
| PROVIDER 12 | MXN                  | 146460 | 294                      | 49974   | 34.12       | 0.8671           |
| PROVIDER 11 | MXN                  | 47519  | 0                        | 0       | 0.0         | 0.0              |
| PROVIDER 8  | MXN                  | 46627  | 0                        | 43659   | 93.63       | 0.927            |
| PROVIDER 8  | HNL                  | 33936  | 0                        | 32911   | 96.98       | 0.7937           |
| PROVIDER 8  | GTQ                  | 30842  | 0                        | 25996   | 84.29       | 0.9021           |
| PROVIDER 12 | GTQ                  | 27575  | 66                       | 4655    | 16.88       | 0.5038           |
| PROVIDER 4  | COP                  | 20117  | 0                        | 0       | 0.0         | 0.0              |
| PROVIDER 7  | MXN                  | 19862  | 0                        | 0       | 0.0         | 0.0              |
| PROVIDER 5  | HNL                  | 18107  | 0                        | 0       | 0.0         | 0.0              |
| PROVIDER 12 | USD                  | 17210  | 29                       | 28      | 0.16        | 0.2              |
| PROVIDER 7  | GTQ                  | 16206  | 0                        | 0       | 0.0         | 0.0              |
| PROVIDER 8  | COP                  | 11779  | 0                        | 10223   | 86.79       | 1.0041           |
| PROVIDER 11 | GTQ                  | 10824  | 0                        | 0       | 0.0         | 0.0              |
| PROVIDER 12 | HNL                  | 9407   | 24                       | 1230    | 13.08       | 0.1863           |
| PROVIDER 8  | USD                  | 6934   | 0                        | 0       | 0.0         | 0.0              |
| PROVIDER 9  | COP                  | 5166   | 0                        | 0       | 0.0         | 0.0              |
| PROVIDER 12 | COP                  | 4675   | 18                       | 1027    | 21.97       | 0.9509           |
| PROVIDER 5  | USD                  | 4224   | 0                        | 0       | 0.0         | 0.0              |
| PROVIDER 11 | COP                  | 3426   | 0                        | 0       | 0.0         | 0.0              |
| PROVIDER 2  | MXN                  | 3396   | 0                        | 0       | 0.0         | 0.0              |
| PROVIDER 4  | MXN                  | 3309   | 0                        | 0       | 0.0         | 0.0              |
| PROVIDER 7  | COP                  | 2211   | 0                        | 0       | 0.0         | 0.0              |
| PROVIDER 11 | HNL                  | 2132   | 0                        | 0       | 0.0         | 0.0              |
| PROVIDER 11 | USD                  | 2065   | 0                        | 0       | 0.0         | 0.0              |
| PROVIDER 5  | GTQ                  | 1714   | 0                        | 0       | 0.0         | 0.0              |
| PROVIDER 8  | DOP                  | 1689   | 0                        | 1636    | 96.86       | 0.795            |
| PROVIDER 7  | USD                  | 1398   | 0                        | 0       | 0.0         | 0.0              |
| PROVIDER 12 | PEN                  | 658    | 0                        | 402     | 61.09       | 0.9174           |
## Largest relative receipt and disbursement amount gaps
|  provider   | destination_currency | destination_amount | disbursement_amount |  status   | exchange_rate |
|-------------|----------------------|-------------------:|--------------------:|-----------|--------------:|
| PROVIDER 8  | COP                  | 3685.000000        | 3722.000000         | CANCELLED | 3684.78000000 |
| PROVIDER 12 | COP                  | 3155.000000        | 3185.000000         | FAILED    | 3155.00000000 |
| PROVIDER 8  | MXN                  | 17.260000          | 17.420000           | CANCELLED | 17.17000000   |
| PROVIDER 12 | PEN                  | 3.270000           | 3.300000            | PAID      | 3.27030000    |
| PROVIDER 8  | MXN                  | 17.490000          | 17.650000           | CANCELLED | 17.49000000   |
| PROVIDER 8  | GTQ                  | 7.760000           | 7.830000            | PAID      | 7.76000000    |
| PROVIDER 8  | COP                  | 3600.000000        | 3632.000000         | PAID      | 3600.00000000 |
| PROVIDER 12 | MXN                  | 17.300000          | 17.450000           | COMPLETED | 17.30000000   |
| PROVIDER 12 | MXN                  | 17.330000          | 17.480000           | COMPLETED | 17.33000000   |
| PROVIDER 8  | MXN                  | 17.650000          | 17.800000           | CANCELLED | 17.65000000   |
## Null disbursement amount
|  provider   | status_lc |  month  |  n  |
|-------------|-----------|---------|----:|
| PROVIDER 12 | failed    | 2026-03 | 106 |
| PROVIDER 12 | failed    | 2026-04 | 87  |
| PROVIDER 12 | failed    | 2026-05 | 79  |
| PROVIDER 12 | failed    | 2026-02 | 68  |
| PROVIDER 12 | failed    | 2026-01 | 63  |
| PROVIDER 3  | failed    | 2026-04 | 36  |
| PROVIDER 3  | failed    | 2026-06 | 22  |
| PROVIDER 12 | failed    | 2026-06 | 21  |
| PROVIDER 3  | failed    | 2026-07 | 20  |
| PROVIDER 3  | failed    | 2026-03 | 20  |
| PROVIDER 3  | failed    | 2026-05 | 14  |
| PROVIDER 3  | failed    | 2026-02 | 14  |
| PROVIDER 3  | failed    | 2026-01 | 6   |
| PROVIDER 12 | failed    | 2026-07 | 4   |
| PROVIDER 12 | failed    | 2026-08 | 3   |
## Null disbursement updated_at
|  provider  |  status_lc  |  n  |          first_seen           |           last_seen           |
|------------|-------------|----:|-------------------------------|-------------------------------|
| PROVIDER 5 | rejected    | 661 | 2026-01-03 15:05:02.508611+00 | 2026-09-22 09:34:30.176396+00 |
| PROVIDER 3 | failed      | 135 | 2026-01-08 12:31:13.532511+00 | 2026-08-12 01:03:20.752991+00 |
| PROVIDER 5 | cancelled   | 10  | 2026-01-13 12:26:21.50944+00  | 2026-05-31 14:57:19.861531+00 |
| PROVIDER 6 | failed      | 4   | 2026-05-21 11:01:14.179883+00 | 2026-05-23 04:54:51.13817+00  |
| PROVIDER 3 | pending     | 2   | 2026-01-19 21:58:51.622451+00 | 2026-01-19 21:58:54.891278+00 |
| PROVIDER 5 | delivered   | 2   | 2026-05-07 14:04:30.086506+00 | 2026-09-21 18:16:33.935829+00 |
| PROVIDER 8 | cancelled   | 1   | 2026-09-17 08:30:15.329152+00 | 2026-09-17 08:30:15.329152+00 |
| PROVIDER 6 | in_progress | 1   | 2026-09-22 03:18:16.754205+00 | 2026-09-22 03:18:16.754205+00 |
## Null disbursement country
|  provider  | type | status_lc |  n  |
|------------|------|-----------|----:|
| PROVIDER 3 | BANK | failed    | 135 |
| PROVIDER 3 | BANK | pending   | 2   |
## Disbursements updated before created
|  provider  | status_lc | n  | min_seconds |
|------------|-----------|---:|------------:|
| PROVIDER 3 | success   | 14 | -0.604596   |
| PROVIDER 3 | failed    | 2  | -0.491494   |
| PROVIDER 3 | pending   | 2  | -0.241856   |
## Receipt and disbursement creation gap
|        gap         |   n    | disbursement_later |
|--------------------|-------:|-------------------:|
| a. within 1 second | 399184 | 226087             |
| b. within 1 minute | 342885 | 234531             |
| c. within 1 hour   | 1584   | 882                |
| d. within 1 day    | 106    | 58                 |
| e. over 1 day      | 4      | 1                  |
## Delivered status that is followed by another attempt
| latest_status | payments |
|---------------|---------:|
| cancelled     | 8        |
| NULL          | 1        |
## Rows where status says cancelled but raw status says otherwise
|  provider   |  status   | raw_status | provider_status | payment_status | n  |
|-------------|-----------|------------|-----------------|----------------|---:|
| PROVIDER 12 | CANCELLED | PAID       | NULL            | SUCCESSFUL     | 42 |
| PROVIDER 4  | CANCELLED | COMPLETED  | completed       | SUCCESSFUL     | 18 |
| PROVIDER 12 | CANCELLED | PAID       | NULL            | REFUNDED       | 4  |
| PROVIDER 8  | CANCELLED | CREATED    | NULL            | SUCCESSFUL     | 3  |
## Provider status contradicting normalized status
| status_lc | provider_status |  n  |
|-----------|-----------------|----:|
| completed | HOLD:11102002   | 604 |
| cancelled | completed       | 18  |
## Promotion amount distribution
|      bucket       |   n    | promotion_usd | charged_zero |
|-------------------|-------:|--------------:|-------------:|
| a. none           | 729965 | 0.000000      | 0            |
| b. up to 5        | 1550   | 7476.440000   | 33           |
| c. over 5 to 20   | 7786   | 145629.280000 | 340          |
| d. over 20 to 100 | 3115   | 194250.390000 | 1345         |
| e. over 100       | 1532   | 399123.000000 | 1235         |
## Promotions on delivered attempts by attempt status
| payment_status |   status_lc   |  n   | promotion_usd |
|----------------|---------------|-----:|--------------:|
| SUCCESSFUL     | success       | 1130 | 180749.180000 |
| SUCCESSFUL     | completed     | 909  | 128276.190000 |
| SUCCESSFUL     | paid          | 810  | 115873.220000 |
| SUCCESSFUL     | failed        | 38   | 6057.520000   |
| SUCCESSFUL     | cancelled     | 27   | 3310.000000   |
| REFUNDED       | cancelled     | 12   | 521.230000    |
| REFUNDED       | failed        | 11   | 1072.500000   |
| SUCCESSFUL     | rejected      | 6    | 430.000000    |
| SUCCESSFUL     | wire_released | 3    | 300.000000    |
| SUCCESSFUL     | in_progress   | 3    | 1050.000000   |
## Fully funded by promotion: does the user have an earlier refund?
| receipts | user_has_earlier_refund | earlier_refund_similar_amount |
|---------:|------------------------:|------------------------------:|
| 2953     | 20                      | 4                             |
## Promotion by user delivery sequence
| position |   n    | with_promotion | over_100 | promotion_usd |
|----------|-------:|---------------:|---------:|--------------:|
| later    | 329410 | 3955           | 882      | 349178.520000 |
| first    | 391248 | 9414           | 611      | 371916.200000 |
## Volume with promotions: customer paid compared with value sent
| customer_paid_on_delivered_attempts |    value_sent    |     charged      |      fee       |   promotion   |
|------------------------------------:|-----------------:|-----------------:|---------------:|--------------:|
| 237078382.200000                    | 234908070.150000 | 234186975.430000 | 2891406.770000 | 721094.720000 |
## Successful payments without receipts by month and type
|  month  |   type    |  n   |   usd    |
|---------|-----------|-----:|---------:|
| 2026-06 | CARD      | 29   | 539.00   |
| 2026-07 | CARD      | 148  | 2301.75  |
| 2026-08 | CARD      | 731  | 13289.75 |
| 2026-08 | APPLE_PAY | 2    | 2.00     |
| 2026-09 | CARD      | 1051 | 24557.65 |
## Age of unresolved successful payments at the extract end
|       outcome        | payments |       usd        | under_2_days | days_2_to_30 | over_30_days | chargebacks |
|----------------------|---------:|-----------------:|-------------:|-------------:|-------------:|------------:|
| all_attempts_failed  | 182      | 50900.590010986  | 20           | 52           | 110          | 9           |
| in_flight_or_unknown | 1279     | 563019.749999542 | 755          | 368          | 156          | 0           |
## Receipts without a disbursement record
|  month  | n  |
|---------|---:|
| 2026-01 | 4  |
| 2026-02 | 39 |
| 2026-03 | 3  |
| 2026-04 | 63 |
| 2026-05 | 16 |
| 2026-06 | 14 |
| 2026-07 | 7  |
| 2026-08 | 14 |
| 2026-09 | 25 |
## Payment status for receipts without disbursement
|   status   |  n  |
|------------|----:|
| REFUNDED   | 15  |
| SUCCESSFUL | 170 |
## total_intents and state code population by type and status
|   status   | type | total_intents_populated | state_populated |   n    |
|------------|------|------------------------:|----------------:|-------:|
| SUCCESSFUL | CARD | 8290                    | 0               | 715979 |
| FAILED     | CARD | 8249                    | 0               | 57250  |
| REFUNDED   | CARD | 64                      | 0               | 6154   |
| SUCCESSFUL | CASH | 0                       | 172             | 610    |
| FAILED     | CASH | 0                       | 252             | 532    |
| SUCCESSFUL | ACH  | 47                      | 2               | 59     |
| FAILED     | ACH  | 2                       | 0               | 33     |
| REFUNDED   | CASH | 0                       | 2               | 3      |
## State code values longer than 2 characters
| location_of_request_state_code | n  |
|--------------------------------|---:|
| ROO                            | 10 |
| CMX                            | 4  |
| MEX                            | 2  |
| CHH                            | 1  |
| US-FL                          | 1  |
| ENG                            | 1  |
| US-TX                          | 1  |
| US-IL                          | 1  |
## Activity around the largest payment gap
|  source_file  | rows_in_gap |
|---------------|------------:|
| payments      | 0           |
| receipts      | 2           |
| disbursements | 2           |
## Refund timing
| refunded_payments | median_hours_to_refund_update |
|------------------:|------------------------------:|
| 6219              | 11.7                          |
## Do null disbursement fields fall on the same rows?
|  provider   |  status_lc  | amount_null | updated_at_null | country_null | currency_null |  n  |
|-------------|-------------|-------------|-----------------|--------------|---------------|----:|
| PROVIDER 5  | rejected    | false       | true            | false        | false         | 661 |
| PROVIDER 12 | failed      | true        | false           | false        | false         | 431 |
| PROVIDER 3  | failed      | true        | true            | true         | true          | 135 |
| PROVIDER 5  | cancelled   | false       | true            | false        | false         | 10  |
| PROVIDER 6  | failed      | false       | true            | false        | false         | 4   |
| PROVIDER 5  | delivered   | false       | true            | false        | false         | 2   |
| PROVIDER 3  | pending     | true        | true            | true         | true          | 2   |
| PROVIDER 6  | in_progress | false       | true            | false        | false         | 1   |
| PROVIDER 8  | cancelled   | false       | true            | false        | false         | 1   |
