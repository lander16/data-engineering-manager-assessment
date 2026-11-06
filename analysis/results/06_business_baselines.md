## Payment outcome reconciliation
|       status        |    payout_outcome    | payments |         usd         |
|---------------------|----------------------|---------:|--------------------:|
| FAILED              | no_receipt           | 58684    | 27567825.155192383  |
| FAILED              | delivered            | 2        | 512.990000000       |
| FAILED              | all_attempts_failed  | 1        | 500.000000000       |
| PENDING_USER_ACTION | no_receipt           | 17       | 7039.400000000      |
| REFUNDED            | all_attempts_failed  | 6106     | 2653985.044491912   |
| REFUNDED            | no_receipt           | 86       | 33583.670000000     |
| REFUNDED            | in_flight_or_unknown | 20       | 13485.040000000     |
| REFUNDED            | delivered            | 7        | 1897.490000000      |
| STARTED             | no_receipt           | 1        | -0.900000000        |
| SUCCESSFUL          | delivered            | 720611   | 237070321.026685776 |
| SUCCESSFUL          | no_receipt           | 1961     | 40690.150000000     |
| SUCCESSFUL          | in_flight_or_unknown | 1279     | 563019.749999542    |
| SUCCESSFUL          | all_attempts_failed  | 182      | 50900.590010986     |
| SUCCESSFUL          | multiple_delivered   | 19       | 5515.890000000      |
## Outcome total check
| classified | payment_rows |
|-----------:|-------------:|
| 788976     | 788976       |
## Volume definitions
| definition | payments |         usd         |
|------------|---------:|--------------------:|
| all rows   | 788976   | 268009275.296380599 |
| SUCCESSFUL | 724052   | 237730447.406696304 |
| delivered  | 720630   | 237075836.916685776 |
## Monthly delivered volume
|  month  | remittances | active_users |        usd         |
|---------|------------:|-------------:|-------------------:|
| 2026-01 | 54755       | 48571        | 16679287.738697410 |
| 2026-02 | 60726       | 53763        | 19265512.559947657 |
| 2026-03 | 75052       | 65735        | 24753796.199430188 |
| 2026-04 | 77645       | 68082        | 25408575.707895777 |
| 2026-05 | 92746       | 80753        | 30303037.939352239 |
| 2026-06 | 89289       | 78247        | 30038057.871036566 |
| 2026-07 | 96149       | 83850        | 32372631.160644604 |
| 2026-08 | 101232      | 87848        | 33614832.568005530 |
| 2026-09 | 73036       | 66207        | 24640105.171675805 |
## Fee and promotion split on delivered attempts
| delivered_attempts |     charged      |      fee       |   promotion   |
|-------------------:|-----------------:|---------------:|--------------:|
| 720649             | 234186975.430000 | 2891406.770000 | 721094.720000 |
## Fees by corridor and payout type
| destination_country_code |  type  | attempts | min_fee  | median_fee |  max_fee  |
|--------------------------|--------|---------:|---------:|-----------:|----------:|
| MX                       | BANK   | 409744   | 0.000000 | 2.990000   | 7.990000  |
| MX                       | CASH   | 100944   | 0.000000 | 4.980000   | 8.990000  |
| GT                       | CASH   | 52037    | 0.000000 | 4.980000   | 4.980000  |
| HN                       | CASH   | 38496    | 0.000000 | 5.990000   | 27.990000 |
| GT                       | BANK   | 35121    | 0.000000 | 2.990000   | 7.140000  |
| CO                       | BANK   | 25976    | 0.000000 | 2.990000   | 2.990000  |
| HN                       | BANK   | 25228    | 0.000000 | 5.990000   | 27.990000 |
| CO                       | WALLET | 20118    | 0.000000 | 2.990000   | 2.990000  |
| SV                       | CASH   | 9249     | 0.000000 | 6.240000   | 41.870000 |
| NI                       | CASH   | 8887     | 0.000000 | 5.090000   | 36.550000 |
| SV                       | BANK   | 6918     | 0.000000 | 5.240000   | 40.950000 |
| NI                       | BANK   | 4052     | 0.000000 | 5.090000   | 36.550000 |
| DO                       | BANK   | 1762     | 0.000000 | 2.990000   | 30.690000 |
| EC                       | BANK   | 1756     | 0.000000 | 4.870000   | 36.440000 |
| CO                       | CASH   | 1280     | 0.000000 | 2.990000   | 2.990000  |
| PE                       | BANK   | 935      | 0.000000 | 2.990000   | 27.990000 |
| DO                       | CASH   | 709      | 0.000000 | 4.980000   | 33.980000 |
| EC                       | CASH   | 220      | 0.000000 | 5.090000   | 20.490000 |
| PE                       | CASH   | 107      | 0.000000 | 5.480000   | 15.980000 |
| BR                       | BANK   | 104      | 0.000000 | 0.000000   | 0.000000  |
## Successful payments without receipts by amount
|    amount    |  n  |
|-------------:|----:|
| 1.000000000  | 704 |
| 24.750000000 | 549 |
| 37.250000000 | 276 |
| 12.250000000 | 153 |
| 62.250000000 | 85  |
| 10.000000000 | 32  |
| 49.750000000 | 28  |
| 18.500000000 | 26  |
| 25.000000000 | 25  |
| 31.000000000 | 22  |
| 43.500000000 | 18  |
| 5.000000000  | 7   |
| 50.000000000 | 5   |
| 20.000000000 | 5   |
| 74.750000000 | 4   |
## Are no-receipt payment users also remittance users?
| users | also_have_receipts |
|------:|-------------------:|
| 1845  | 1255               |
## Payment failures by type
|    type    |   n    | failed | failed_pct |
|------------|-------:|-------:|-----------:|
| CARD       | 779400 | 57250  | 7.35       |
| APPLE_PAY  | 8211   | 843    | 10.27      |
| CASH       | 1145   | 532    | 46.46      |
| WALLET_POC | 126    | 29     | 23.02      |
| ACH        | 93     | 33     | 35.48      |
| NULL       | 1      | 0      | 0.0        |
## Users with only failed payments
| users  | never_successful |
|-------:|-----------------:|
| 421412 | 28905            |
## Provider failure variants
|  provider   | attempts | failed_or_cancelled_status_pct | strict_status_pct | strict_raw_status_pct | raw_cancelled_pct |
|-------------|---------:|-------------------------------:|------------------:|----------------------:|------------------:|
| PROVIDER 3  | 243048   | 1.44                           | 1.44              | 0.18                  | 1.26              |
| PROVIDER 12 | 206334   | 3.78                           | 1.33              | 1.33                  | 2.42              |
| PROVIDER 8  | 131807   | 4.75                           | 0.42              | 0.42                  | 4.33              |
| PROVIDER 11 | 65966    | 1.94                           | 1.94              | 1.94                  | 0.0               |
| PROVIDER 7  | 39819    | 3.32                           | 2.95              | 2.95                  | 0.37              |
| PROVIDER 5  | 24524    | 2.84                           | 2.8               | 2.8                   | 0.04              |
| PROVIDER 4  | 23426    | 2.0                            | 1.93              | 1.93                  | 0.0               |
| PROVIDER 9  | 5166     | 3.74                           | 3.74              | 3.74                  | 0.0               |
| PROVIDER 2  | 3396     | 7.48                           | 7.48              | 7.48                  | 0.0               |
| PROVIDER 6  | 268      | 10.07                          | 10.07             | 10.07                 | 0.0               |
| PROVIDER 10 | 6        | 66.67                          | 0.0               | 0.0                   | 66.67             |
| PROVIDER 1  | 3        | 66.67                          | 66.67             | 66.67                 | 0.0               |
## Provider attempt position
|  provider   | first_attempts | retry_attempts | first_attempt_strict_pct | retry_strict_pct |
|-------------|---------------:|---------------:|-------------------------:|-----------------:|
| PROVIDER 3  | 241034         | 2014           | 0.17                     | 0.99             |
| PROVIDER 12 | 200528         | 5806           | 1.04                     | 11.32            |
| PROVIDER 8  | 126785         | 5022           | 0.3                      | 3.52             |
| PROVIDER 11 | 65112          | 854            | 1.71                     | 19.2             |
| PROVIDER 7  | 39111          | 708            | 2.66                     | 18.93            |
| PROVIDER 5  | 24028          | 496            | 2.51                     | 16.73            |
| PROVIDER 4  | 22997          | 429            | 1.66                     | 16.08            |
| PROVIDER 9  | 5078           | 88             | 3.03                     | 44.32            |
| PROVIDER 2  | 3119           | 277            | 4.42                     | 41.88            |
| PROVIDER 6  | 257            | 11             | 8.95                     | 36.36            |
| PROVIDER 10 | 6              | 0              | 0.0                      | NULL             |
| PROVIDER 1  | 3              | 0              | 66.67                    | NULL             |
## Failed-attempt rescue
| payments_with_failed_attempt | later_delivered | never_delivered |
|-----------------------------:|----------------:|----------------:|
| 18313                        | 11975           | 6338            |
## Chargeback cohorts
|  month  | settled | chargebacks | count_pct | usd_pct |
|---------|--------:|------------:|----------:|--------:|
| 2026-01 | 55473   | 43          | 0.078     | 0.082   |
| 2026-02 | 61379   | 33          | 0.054     | 0.065   |
| 2026-03 | 75911   | 65          | 0.086     | 0.106   |
| 2026-04 | 78419   | 74          | 0.094     | 0.145   |
| 2026-05 | 93582   | 96          | 0.103     | 0.137   |
| 2026-06 | 90058   | 76          | 0.084     | 0.158   |
| 2026-07 | 97043   | 60          | 0.062     | 0.052   |
| 2026-08 | 102736  | 55          | 0.054     | 0.061   |
| 2026-09 | 75670   | 24          | 0.032     | 0.04    |
## Chargeback summary
| settled | chargebacks | count_pct |  chargeback_usd  | usd_pct |
|--------:|------------:|----------:|-----------------:|--------:|
| 730271  | 526         | 0.072     | 228497.930000000 | 0.095   |
## Chargebacks by payout outcome and type
|   status   |   payout_outcome    |   type    | chargebacks |       usd        |
|------------|---------------------|-----------|------------:|-----------------:|
| SUCCESSFUL | delivered           | CARD      | 513         | 222811.760000000 |
| SUCCESSFUL | all_attempts_failed | CARD      | 9           | 5458.690000000   |
| SUCCESSFUL | delivered           | APPLE_PAY | 2           | 101.990000000    |
| SUCCESSFUL | no_receipt          | CARD      | 1           | 19.000000000     |
| REFUNDED   | all_attempts_failed | APPLE_PAY | 1           | 106.490000000    |
## Chargeback timing proxy: updated_at lag in days
| median_days | p90_days | max_days |
|------------:|---------:|---------:|
| 0.0         | 0.0      | 3.8      |
## Top user concentration
| users_to_50_pct | users  | user_pct | lowest_included_before_crossing | highest_user_volume |
|----------------:|-------:|---------:|--------------------------------:|--------------------:|
| 59511           | 391244 | 15.21    | 1188.950000000                  | 12196.870000000     |
## Recurring definitions
| users  | two_plus_remittances | two_plus_months | three_plus_months | two_plus_months_pct |
|-------:|---------------------:|----------------:|------------------:|--------------------:|
| 391244 | 160590               | 144758          | 58727             | 37.0                |
## Recurring share by first delivered month
| first_month | users | recurring | recurring_pct |
|-------------|------:|----------:|--------------:|
| 2026-01     | 48571 | 29662     | 61.1          |
| 2026-02     | 44553 | 24661     | 55.4          |
| 2026-03     | 47986 | 23887     | 49.8          |
| 2026-04     | 44336 | 19807     | 44.7          |
| 2026-05     | 48911 | 18314     | 37.4          |
| 2026-06     | 42982 | 13780     | 32.1          |
| 2026-07     | 42965 | 9898      | 23.0          |
| 2026-08     | 41814 | 4749      | 11.4          |
| 2026-09     | 29126 | 0         | 0.0           |
## Gap between delivered remittances, in days
|  gaps  | p25  | p50  | p75  |  p90  |
|-------:|-----:|-----:|-----:|------:|
| 329386 | 13.6 | 33.0 | 68.0 | 112.1 |
