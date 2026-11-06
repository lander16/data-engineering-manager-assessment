## Q5.1 Text signals: any dispute or chargeback wording in payment or payout statuses
|                        field                        | rows_matching |
|-----------------------------------------------------|--------------:|
| payments.status / detailed_status                   | 0             |
| disbursements.status / raw_status / provider_status | 0             |
## Q5.2 Flagged payments by payment status and detailed status
|   status   | detailed_status | payments | flagged |
|------------|-----------------|---------:|--------:|
| SUCCESSFUL | SUCCESSFUL      | 724042   | 525     |
| REFUNDED   | SUCCESSFUL      | 3475     | 0       |
| REFUNDED   | NULL            | 2744     | 1       |
## Q5.3 Flag rate by payout outcome (settled card and Apple Pay payments)
|   status   |   payout_outcome   | payments | flagged | flagged_pct |
|------------|--------------------|---------:|--------:|------------:|
| SUCCESSFUL | delivered          | 719849   | 515     | 0.072       |
| REFUNDED   | not_delivered      | 6102     | 1       | 0.016       |
| SUCCESSFUL | no_receipt         | 1961     | 1       | 0.051       |
| SUCCESSFUL | in_flight          | 1275     | 0       | 0.0         |
| SUCCESSFUL | not_delivered      | 179      | 9       | 5.028       |
| REFUNDED   | no_receipt         | 86       | 0       | 0.0         |
| SUCCESSFUL | multiple_delivered | 19       | 0       | 0.0         |
| REFUNDED   | missing_payout     | 15       | 0       | 0.0         |
| REFUNDED   | delivered          | 7        | 0       | 0.0         |
| REFUNDED   | in_flight          | 5        | 0       | 0.0         |
| SUCCESSFUL | missing_payout     | 3        | 0       | 0.0         |
## Q5.4 Refund share: flagged vs unflagged settled card and Apple Pay payments
| flagged | settled | refunded | refunded_pct |
|---------|--------:|---------:|-------------:|
| false   | 728975  | 6214     | 0.85         |
| true    | 526     | 1        | 0.19         |
## Q5.5 Payment updated_at lag in seconds: flagged vs unflagged successful card payments
| flagged | payments | p50_s | p90_s | p99_s |   max_s    | over_1h |
|---------|---------:|------:|------:|------:|-----------:|--------:|
| false   | 715456   | 1.49  | 4.52  | 7.88  | 560.518026 | 0       |
| true    | 523      | 1.49  | 2.94  | 82.36 | 169.045192 | 0       |
## Q5.6 Amount band and payment type (settled)
| amount_band | settled | flagged | flagged_pct |
|-------------|--------:|--------:|------------:|
| 1: under 50 | 113174  | 50      | 0.044       |
| 2: 50-99    | 125275  | 69      | 0.055       |
| 3: 100-199  | 169288  | 95      | 0.056       |
| 4: 200-499  | 161287  | 175     | 0.109       |
| 5: 500-999  | 90079   | 70      | 0.078       |
| 6: 1000+    | 70398   | 67      | 0.095       |
|    type    | settled | flagged | flagged_pct |
|------------|--------:|--------:|------------:|
| CARD       | 722133  | 523     | 0.072       |
| APPLE_PAY  | 7368    | 3       | 0.041       |
| CASH       | 613     | 0       | 0.0         |
| WALLET_POC | 97      | 0       | 0.0         |
| ACH        | 60      | 0       | 0.0         |
## Q5.7 First settled payment and promotion concentration (settled card and Apple Pay)
|       position        | settled | flagged | flagged_pct | share_of_flags_pct |
|-----------------------|--------:|--------:|------------:|-------------------:|
| later                 | 334650  | 128     | 0.038       | 24.3               |
| first settled payment | 394851  | 398     | 0.101       | 75.7               |
|     promo     | position | delivered | flagged | flagged_pct |
|---------------|----------|----------:|--------:|------------:|
| has promotion | later    | 4003      | 0       | 0.0         |
| no promotion  | later    | 326607    | 125     | 0.038       |
| has promotion | first    | 9341      | 6       | 0.064       |
| no promotion  | first    | 379905    | 384     | 0.101       |
## Q5.8 Repeat flags per user, against independence
| users_1_flag | users_2_flags | users_3plus_flags | expected_pairs_if_independent | observed_pairs |
|-------------:|--------------:|------------------:|------------------------------:|---------------:|
| 459          | 26            | 5                 | 0.39                          | 41.0           |
## Q5.9 Repeat flags: days between a user's flagged payments
| repeat_flags | p10_days | p50_days | p90_days | max_days | over_30_days |
|-------------:|---------:|---------:|---------:|---------:|-------------:|
| 36           | 0.09     | 7.62     | 35.49    | 80.6     | 6            |
## Q5.10 Activity after the flagged payment vs matched unflagged payments
| horizon_days | flagged_payments | unmatched | flagged_with_later_payment | expected_later_payment | flagged_with_later_success | expected_later_success | flagged_success_pct | expected_success_pct |
|-------------:|-----------------:|----------:|---------------------------:|-----------------------:|---------------------------:|-----------------------:|--------------------:|---------------------:|
| 7            | 526              | NULL      | 56                         | 71.6                   | 27                         | 70.2                   | 5.1                 | 13.3                 |
| 30           | 488              | NULL      | 93                         | 212.4                  | 54                         | 209.7                  | 11.1                | 43.0                 |
| 60           | 434              | NULL      | 90                         | 282.1                  | 56                         | 279.5                  | 12.9                | 64.4                 |
| 90           | 373              | NULL      | 79                         | 291.8                  | 52                         | 289.9                  | 13.9                | 77.7                 |
## Q5.11 Flagged payments: share of users with any successful payment in later windows, vs matched unflagged
| days_after_payment | flagged_payments | flagged_with_success | expected_with_success | ratio_flagged_to_expected |
|--------------------|-----------------:|---------------------:|----------------------:|--------------------------:|
| 0-7                | 299              | 13                   | 27.5                  | 0.47                      |
| 7-30               | 299              | 18                   | 78.3                  | 0.23                      |
| 30-60              | 299              | 6                    | 67.8                  | 0.09                      |
| 60-90              | 299              | 4                    | 47.7                  | 0.08                      |
| 90-120             | 299              | 0                    | 36.9                  | 0.0                       |
## Q5.12 Flagged payments followed by a successful payment more than 30 days later
| age_days | days_to_next_success | settled_seq | later_payment_also_flagged |
|---------:|---------------------:|------------:|----------------------------|
| 208.0    | 87.9                 | 1           | false                      |
| 164.0    | 80.6                 | 1           | true                       |
| 161.0    | 76.2                 | 3           | false                      |
| 249.0    | 69.9                 | 2           | true                       |
| 262.0    | 55.3                 | 1           | false                      |
| 239.0    | 54.5                 | 1           | true                       |
| 89.0     | 37.2                 | 1           | true                       |
| 123.0    | 35.2                 | 3           | false                      |
| 205.0    | 33.8                 | 1           | true                       |
| 68.0     | 33.0                 | 1           | true                       |
| 128.0    | 32.0                 | 1           | false                      |
| 170.0    | 31.0                 | 1           | false                      |
## Q5.13 Flagged payment is the user's last payment of any status, vs matched unflagged
| flagged_payments | flagged_is_last_payment | flagged_pct | expected_pct |
|-----------------:|------------------------:|------------:|-------------:|
| 299              | 240                     | 80.3        | 44.3         |
## Y6.1 Flag rate by payment month, settled card and Apple Pay payments
| payment_month | settled | flagged | count_pct | ci_low_pct | ci_high_pct | usd_pct | mean_age_days | min_age_days |
|---------------|--------:|--------:|----------:|-----------:|------------:|--------:|--------------:|-------------:|
| 2026-01-01    | 55429   | 43      | 0.078     | 0.054      | 0.101       | 0.082   | 248.0         | 234.0        |
| 2026-02-01    | 61333   | 33      | 0.054     | 0.035      | 0.072       | 0.065   | 219.0         | 206.0        |
| 2026-03-01    | 75874   | 65      | 0.086     | 0.065      | 0.106       | 0.106   | 190.0         | 175.0        |
| 2026-04-01    | 78369   | 74      | 0.094     | 0.073      | 0.116       | 0.145   | 159.0         | 145.0        |
| 2026-05-01    | 93495   | 96      | 0.103     | 0.082      | 0.123       | 0.137   | 129.0         | 114.0        |
| 2026-06-01    | 89950   | 76      | 0.084     | 0.065      | 0.103       | 0.159   | 98.0          | 84.0         |
| 2026-07-01    | 96905   | 60      | 0.062     | 0.046      | 0.078       | 0.052   | 68.0          | 53.0         |
| 2026-08-01    | 102586  | 55      | 0.054     | 0.039      | 0.068       | 0.061   | 37.0          | 22.0         |
| 2026-09-01    | 75560   | 24      | 0.032     | 0.019      | 0.044       | 0.04    | 11.0          | 0.0          |
## Y6.2 Flag rate by 14-day age band at the extract end (age = extract end minus payment time)
| age_band_days | settled | flagged | count_pct | ci_low_pct | ci_high_pct |
|---------------|--------:|--------:|----------:|-----------:|------------:|
| 00-07         | 28728   | 0       | 0.0       | 0.0        | 0.0         |
| 008-021       | 48610   | 25      | 0.051     | 0.031      | 0.072       |
| 022-035       | 47136   | 20      | 0.042     | 0.024      | 0.061       |
| 036-049       | 45083   | 25      | 0.055     | 0.034      | 0.077       |
| 050-063       | 43791   | 32      | 0.073     | 0.048      | 0.098       |
| 064-077       | 44071   | 30      | 0.068     | 0.044      | 0.092       |
| 078-091       | 43107   | 26      | 0.06      | 0.037      | 0.083       |
| 092-105       | 42910   | 30      | 0.07      | 0.045      | 0.095       |
| 106-119       | 39964   | 39      | 0.098     | 0.067      | 0.128       |
| 120-133       | 39785   | 54      | 0.136     | 0.1        | 0.172       |
| 134-147       | 44050   | 38      | 0.086     | 0.059      | 0.114       |
| 148-161       | 38198   | 39      | 0.102     | 0.07       | 0.134       |
| 162-175       | 34980   | 28      | 0.08      | 0.05       | 0.11        |
| 176-189       | 34761   | 21      | 0.06      | 0.035      | 0.086       |
| 190-203       | 34221   | 39      | 0.114     | 0.078      | 0.15        |
| 204-217       | 31498   | 19      | 0.06      | 0.033      | 0.087       |
| 218-231       | 30273   | 18      | 0.059     | 0.032      | 0.087       |
| 232-245       | 27194   | 19      | 0.07      | 0.038      | 0.101       |
| 246-259       | 24443   | 17      | 0.07      | 0.036      | 0.103       |
| 260-273       | 6698    | 7       | 0.105     | 0.027      | 0.182       |
## Y6.2b Flag rate by wide age band, with the rate relative to the oldest band
|    age_band     | settled | flagged | count_pct | ratio_to_176plus | ratio_to_106_175 |
|-----------------|--------:|--------:|----------:|-----------------:|-----------------:|
| 0: 0-7 days     | 28728   | 0       | 0.0       | 0.0              | 0.0              |
| 1: 8-49 days    | 140829  | 70      | 0.0497    | 0.67             | 0.49             |
| 2: 50-105 days  | 173879  | 118     | 0.0679    | 0.92             | 0.68             |
| 3: 106-175 days | 196977  | 198     | 0.1005    | 1.36             | 1.0              |
| 4: 176+ days    | 189088  | 140     | 0.074     | 1.0              | 0.74             |
## Y6.3 Youngest flagged payments: age in days at the extract end
| age_days | type | amount  | settled_seq |
|---------:|------|--------:|------------:|
| 8.7      | CARD | 854.98  | 2           |
| 9.5      | CARD | 180.00  | 1           |
| 12.5     | CARD | 151.99  | 1           |
| 12.6     | CARD | 1852.99 | 1           |
| 12.8     | CARD | 414.98  | 1           |
| 14.0     | CARD | 202.99  | 1           |
| 14.7     | CARD | 365.53  | 3           |
| 14.7     | CARD | 301.00  | 1           |
## Y6.4 Flagged payments in the youngest ages, against the volume at risk
| age_band_days | settled | flagged |
|---------------|--------:|--------:|
| 0-3           | 16193   | 0       |
| 4-7           | 12535   | 0       |
| 8-10          | 12557   | 2       |
| 11-14         | 12072   | 9       |
| 15+           | 51202   | 27      |
## Y6.5 Flag rate by payment week, settled card and Apple Pay payments
| week_start | settled | flagged | count_pct | mean_age_days |
|------------|--------:|--------:|----------:|--------------:|
| 2025-12-29 | 6048    | 7       | 0.116     | 262.0         |
| 2026-01-05 | 11842   | 8       | 0.068     | 257.0         |
| 2026-01-12 | 12574   | 9       | 0.072     | 250.0         |
| 2026-01-19 | 13273   | 6       | 0.045     | 243.0         |
| 2026-01-26 | 13866   | 13      | 0.094     | 236.0         |
| 2026-02-02 | 14218   | 7       | 0.049     | 229.0         |
| 2026-02-09 | 15906   | 10      | 0.063     | 222.0         |
| 2026-02-16 | 15538   | 6       | 0.039     | 215.0         |
| 2026-02-23 | 15909   | 14      | 0.088     | 208.0         |
| 2026-03-02 | 17066   | 23      | 0.135     | 201.0         |
| 2026-03-09 | 17202   | 14      | 0.081     | 194.0         |
| 2026-03-16 | 17560   | 14      | 0.08      | 187.0         |
| 2026-03-23 | 17111   | 8       | 0.047     | 180.0         |
| 2026-03-30 | 16982   | 11      | 0.065     | 173.0         |
| 2026-04-06 | 17937   | 17      | 0.095     | 166.0         |
| 2026-04-13 | 18862   | 24      | 0.127     | 159.0         |
| 2026-04-20 | 19320   | 15      | 0.078     | 152.0         |
| 2026-04-27 | 19416   | 18      | 0.093     | 145.0         |
| 2026-05-04 | 24623   | 21      | 0.085     | 137.0         |
| 2026-05-11 | 19785   | 26      | 0.131     | 131.0         |
| 2026-05-18 | 20082   | 28      | 0.139     | 124.0         |
| 2026-05-25 | 19380   | 12      | 0.062     | 117.0         |
| 2026-06-01 | 20423   | 24      | 0.118     | 110.0         |
| 2026-06-08 | 20184   | 23      | 0.114     | 103.0         |
| 2026-06-15 | 22709   | 10      | 0.044     | 96.0          |
| 2026-06-22 | 21343   | 16      | 0.075     | 89.0          |
| 2026-06-29 | 21986   | 8       | 0.036     | 82.0          |
| 2026-07-06 | 21157   | 15      | 0.071     | 75.0          |
| 2026-07-13 | 22675   | 17      | 0.075     | 68.0          |
| 2026-07-20 | 22301   | 12      | 0.054     | 61.0          |
| 2026-07-27 | 21520   | 19      | 0.088     | 54.0          |
| 2026-08-03 | 22139   | 19      | 0.086     | 47.0          |
| 2026-08-10 | 22831   | 6       | 0.026     | 40.0          |
| 2026-08-17 | 23426   | 10      | 0.043     | 33.0          |
| 2026-08-24 | 23678   | 9       | 0.038     | 26.0          |
| 2026-08-31 | 24141   | 16      | 0.066     | 19.0          |
| 2026-09-07 | 24458   | 11      | 0.045     | 12.0          |
| 2026-09-14 | 25344   | 0       | 0.0       | 5.0           |
| 2026-09-21 | 4686    | 0       | 0.0       | 1.0           |
## Y6.6 Card vs Apple Pay (Apple Pay first appears on 2026-06-08), same period
|   type    | settled | flagged | count_pct |
|-----------|--------:|--------:|----------:|
| APPLE_PAY | 7368    | 3       | 0.041     |
| CARD      | 335262  | 185     | 0.055     |
## Y6.7 First vs later settled payments by month (settled card and Apple Pay)
| payment_month | first_payments | first_share_pct | first_flag_pct | later_flag_pct |
|---------------|---------------:|----------------:|---------------:|---------------:|
| 2026-01-01    | 49125          | 88.6            | 0.079          | 0.063          |
| 2026-02-01    | 44956          | 73.3            | 0.056          | 0.049          |
| 2026-03-01    | 48437          | 63.8            | 0.118          | 0.029          |
| 2026-04-01    | 44656          | 57.0            | 0.114          | 0.068          |
| 2026-05-01    | 49195          | 52.6            | 0.157          | 0.043          |
| 2026-06-01    | 43175          | 48.0            | 0.116          | 0.056          |
| 2026-07-01    | 43138          | 44.5            | 0.093          | 0.037          |
| 2026-08-01    | 42181          | 41.1            | 0.095          | 0.025          |
| 2026-09-01    | 29988          | 39.7            | 0.063          | 0.011          |
## Y6.8 Risk-drift proxies available at payment time: card declines by month, against the flag count
|  month  | card_attempts | suspected_fraud_decline_pct | stolen_or_lost_decline_pct | flagged | flagged_per_100_fraud_declines |
|---------|--------------:|----------------------------:|---------------------------:|--------:|-------------------------------:|
| 2026-01 | 60721         | 2.28                        | 0.24                       | 43      | 3.1                            |
| 2026-02 | 66689         | 1.97                        | 0.27                       | 33      | 2.52                           |
| 2026-03 | 82313         | 1.79                        | 0.28                       | 65      | 4.41                           |
| 2026-04 | 84764         | 1.85                        | 0.31                       | 74      | 4.73                           |
| 2026-05 | 100775        | 1.66                        | 0.33                       | 96      | 5.74                           |
| 2026-06 | 96989         | 1.69                        | 0.28                       | 76      | 4.68                           |
| 2026-07 | 103763        | 1.53                        | 0.28                       | 60      | 3.8                            |
| 2026-08 | 109961        | 1.2                         | 0.25                       | 55      | 4.2                            |
| 2026-09 | 81636         | 1.28                        | 0.23                       | 24      | 2.31                           |
## Y6.9 Headline flag rate over the months that are mature under each assumed lag
| lag_days | mature_months |          months          | settled | flagged | count_pct | usd_pct |
|---------:|--------------:|--------------------------|--------:|--------:|----------:|--------:|
| 30       | 7             | 2026-01-01 to 2026-07-01 | 551355  | 447     | 0.0811    | 0.1093  |
| 60       | 6             | 2026-01-01 to 2026-06-01 | 454450  | 387     | 0.0852    | 0.1218  |
| 90       | 5             | 2026-01-01 to 2026-05-01 | 364500  | 311     | 0.0853    | 0.1124  |
| 120      | 4             | 2026-01-01 to 2026-04-01 | 271005  | 215     | 0.0793    | 0.1038  |
| 150      | 3             | 2026-01-01 to 2026-03-01 | 192636  | 141     | 0.0732    | 0.0864  |
| NULL     | 9             | all months               | 729501  | 526     | 0.0721    | 0.0951  |
## Y6.10 Each month's flag rate as a share of the pooled mature-month rate, for lags of 60, 90 and 120 days
| payment_month | settled | flagged | count_pct | pct_of_rate_lag60 | pct_of_rate_lag90 | pct_of_rate_lag120 |
|---------------|--------:|--------:|----------:|------------------:|------------------:|-------------------:|
| 2026-01-01    | 55429   | 43      | 0.078     | 91.0              | 91.0              | 98.0               |
| 2026-02-01    | 61333   | 33      | 0.054     | 63.0              | 63.0              | 68.0               |
| 2026-03-01    | 75874   | 65      | 0.086     | 101.0             | 100.0             | 108.0              |
| 2026-04-01    | 78369   | 74      | 0.094     | 111.0             | 111.0             | 119.0              |
| 2026-05-01    | 93495   | 96      | 0.103     | 121.0             | 120.0             | 129.0              |
| 2026-06-01    | 89950   | 76      | 0.084     | 99.0              | 99.0              | 107.0              |
| 2026-07-01    | 96905   | 60      | 0.062     | 73.0              | 73.0              | 78.0               |
| 2026-08-01    | 102586  | 55      | 0.054     | 63.0              | 63.0              | 68.0               |
| 2026-09-01    | 75560   | 24      | 0.032     | 37.0              | 37.0              | 40.0               |
## D7.1 Denominator comparison: count and USD flag rates
|                               denominator                                | payments | flagged | count_pct |    usd    | flagged_usd | usd_pct |
|--------------------------------------------------------------------------|---------:|--------:|----------:|----------:|------------:|--------:|
| A settled, all types (SUCCESSFUL + REFUNDED)                             | 730271   | 526     | 0.072     | 240433399 | 228498      | 0.095   |
| B settled, card + Apple Pay                                              | 729501   | 526     | 0.0721    | 240244115 | 228498      | 0.0951  |
| C settled, card + Apple Pay, excluding no-receipt SUCCESSFUL             | 727540   | 525     | 0.0722    | 240203425 | 228479      | 0.0951  |
| D SUCCESSFUL only, card + Apple Pay                                      | 723286   | 525     | 0.0726    | 237542217 | 228391      | 0.0961  |
| E delivered remittances (SUCCESSFUL with a delivered attempt), all types | 720630   | 515     | 0.0715    | 237075837 | 222914      | 0.094   |
| F delivered remittances, card + Apple Pay                                | 719868   | 515     | 0.0715    | 236890647 | 222914      | 0.0941  |
| G CARD type only, settled                                                | 722133   | 523     | 0.0724    | 238164815 | 228289      | 0.0959  |
| H all card + Apple Pay attempts, including FAILED                        | 787611   | 526     | 0.0668    | 267662653 | 228498      | 0.0854  |
## D7.2 No-receipt SUCCESSFUL payments by month and their effect on the card rate
| payment_month | settled_card_like | no_receipt_successful | no_receipt_pct | rate_with_pct | rate_without_pct |
|---------------|------------------:|----------------------:|---------------:|--------------:|-----------------:|
| 2026-01-01    | 55429             | 0                     | 0.0            | 0.0776        | 0.0776           |
| 2026-02-01    | 61333             | 0                     | 0.0            | 0.0538        | 0.0538           |
| 2026-03-01    | 75874             | 0                     | 0.0            | 0.0857        | 0.0857           |
| 2026-04-01    | 78369             | 0                     | 0.0            | 0.0944        | 0.0944           |
| 2026-05-01    | 93495             | 0                     | 0.0            | 0.1027        | 0.1027           |
| 2026-06-01    | 89950             | 29                    | 0.03           | 0.0845        | 0.0834           |
| 2026-07-01    | 96905             | 148                   | 0.15           | 0.0619        | 0.062            |
| 2026-08-01    | 102586            | 733                   | 0.71           | 0.0536        | 0.054            |
| 2026-09-01    | 75560             | 1051                  | 1.39           | 0.0318        | 0.0322           |
## D7.3 Flagged payments that sit outside the delivered-remittance denominator
|   status   | payout_outcome | flagged | usd  |
|------------|----------------|--------:|-----:|
| SUCCESSFUL | not_delivered  | 9       | 5459 |
| REFUNDED   | not_delivered  | 1       | 106  |
| SUCCESSFUL | no_receipt     | 1       | 19   |
## D7.4 Delivered denominator by month: rate on delivered remittances vs settled card payments
| payment_month | settled_card_pct | delivered_pct |
|---------------|-----------------:|--------------:|
| 2026-01-01    | 0.0776           | 0.0767        |
| 2026-02-01    | 0.0538           | 0.0543        |
| 2026-03-01    | 0.0857           | 0.0866        |
| 2026-04-01    | 0.0944           | 0.094         |
| 2026-05-01    | 0.1027           | 0.1014        |
| 2026-06-01    | 0.0845           | 0.0818        |
| 2026-07-01    | 0.0619           | 0.0593        |
| 2026-08-01    | 0.0536           | 0.0533        |
| 2026-09-01    | 0.0318           | 0.0329        |
## Check1 Flags in the youngest ages, recomputed from the raw text tables
| flagged_all | flagged_in_last_8_days | settled_card_in_last_8_days |
|------------:|-----------------------:|----------------------------:|
| 526         | 0                      | 28728                       |
## Check2 Flag rate of SUCCESSFUL card payments whose every payout failed or was cancelled, recomputed from receipts and disbursements
| payments | flagged | flagged_pct |
|---------:|--------:|------------:|
| 179      | 9       | 5.03        |
## Check3 Flagged payments with a successful payment by the same user in the following 90 days, by self-join
| flagged_with_90_days_follow_up | with_later_success |
|-------------------------------:|-------------------:|
| 373                            | 52                 |
