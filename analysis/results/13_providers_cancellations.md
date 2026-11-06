## Q0.1 Where status and raw_status differ, by provider
|  provider   |       status       | raw_status  | disbursements |
|-------------|--------------------|-------------|--------------:|
| PROVIDER 3  | Success            | complete    | 239520        |
| PROVIDER 3  | Failed             | cancelled   | 3070          |
| PROVIDER 7  | PAYABLE            | IN_PROGRESS | 231           |
| PROVIDER 11 | PAYABLE            | IN_PROGRESS | 203           |
| PROVIDER 12 | CANCELLED          | PAID        | 46            |
| PROVIDER 4  | CANCELLED          | COMPLETED   | 18            |
| PROVIDER 3  | Pending            | processing  | 13            |
| PROVIDER 8  | CANCELLED          | CREATED     | 3             |
| PROVIDER 7  | HOLD_BY_COMPLIANCE | ON_HOLD     | 3             |
## Q0.2 Provider 12, Provider 4 and Provider 8: status against raw_status for the paid, completed and created raw values
|  provider   |  status   | raw_status | disbursements |
|-------------|-----------|------------|--------------:|
| PROVIDER 12 | PAID      | PAID       | 172809        |
| PROVIDER 12 | COMPLETED | COMPLETED  | 25290         |
| PROVIDER 12 | CANCELLED | PAID       | 46            |
| PROVIDER 4  | COMPLETED | COMPLETED  | 22956         |
| PROVIDER 4  | CANCELLED | COMPLETED  | 18            |
| PROVIDER 8  | PAID      | PAID       | 125160        |
| PROVIDER 8  | CANCELLED | CREATED    | 3             |
## Q1.1 Delivered, failed and cancelled attempts by provider and payout type
|  provider   |  payout_type  | delivered | failed | cancelled | cancelled_per_failed |
|-------------|---------------|----------:|-------:|----------:|---------------------:|
| PROVIDER 1  | WALLET        | 1         | 2      | 0         | 0.0                  |
| PROVIDER 10 | CASH          | 2         | 0      | 4         | NULL                 |
| PROVIDER 11 | BANK          | 47250     | 639    | 0         | 0.0                  |
| PROVIDER 11 | CASH          | 17235     | 639    | 0         | 0.0                  |
| PROVIDER 12 | BANK          | 113246    | 1992   | 2485      | 1.2                  |
| PROVIDER 12 | CASH          | 84825     | 758    | 2557      | 3.4                  |
| PROVIDER 12 | CASH DELIVERY | 28        | 1      | 0         | 0.0                  |
| PROVIDER 2  | BANK          | 3141      | 254    | 0         | 0.0                  |
| PROVIDER 3  | BANK          | 239520    | 435    | 3070      | 7.1                  |
| PROVIDER 4  | BANK          | 3144      | 147    | 18        | 0.1                  |
| PROVIDER 4  | WALLET        | 19812     | 304    | 0         | 0.0                  |
| PROVIDER 5  | BANK          | 23820     | 694    | 10        | 0.0                  |
| PROVIDER 6  | CASH          | 240       | 27     | 0         | 0.0                  |
| PROVIDER 7  | BANK          | 21986     | 774    | 0         | 0.0                  |
| PROVIDER 7  | CASH          | 16277     | 400    | 147       | 0.4                  |
| PROVIDER 8  | BANK          | 40878     | 496    | 2340      | 4.7                  |
| PROVIDER 8  | CASH          | 84282     | 61     | 3370      | 55.2                 |
| PROVIDER 9  | BANK          | 4970      | 193    | 0         | 0.0                  |
## Q1.2 Share of attempts with a provider_status, by provider and attempt status
|  provider   | attempt_status | attempts | pct_with_provider_status |
|-------------|----------------|---------:|-------------------------:|
| PROVIDER 1  | delivered      | 1        | 100.0                    |
| PROVIDER 1  | failed         | 2        | 0.0                      |
| PROVIDER 10 | cancelled      | 4        | 0.0                      |
| PROVIDER 10 | delivered      | 2        | 0.0                      |
| PROVIDER 11 | delivered      | 64485    | 100.0                    |
| PROVIDER 11 | failed         | 1278     | 100.0                    |
| PROVIDER 12 | cancelled      | 5042     | 0.0                      |
| PROVIDER 12 | delivered      | 198099   | 12.8                     |
| PROVIDER 12 | failed         | 2751     | 37.9                     |
| PROVIDER 2  | delivered      | 3141     | 100.0                    |
| PROVIDER 2  | failed         | 254      | 95.3                     |
| PROVIDER 3  | cancelled      | 3070     | 0.0                      |
| PROVIDER 3  | delivered      | 239520   | 0.0                      |
| PROVIDER 3  | failed         | 435      | 0.0                      |
| PROVIDER 4  | cancelled      | 18       | 100.0                    |
| PROVIDER 4  | delivered      | 22956    | 100.0                    |
| PROVIDER 4  | failed         | 451      | 90.7                     |
| PROVIDER 5  | cancelled      | 10       | 0.0                      |
| PROVIDER 5  | delivered      | 23820    | 0.0                      |
| PROVIDER 5  | failed         | 694      | 0.0                      |
| PROVIDER 6  | delivered      | 240      | 100.0                    |
| PROVIDER 6  | failed         | 27       | 85.2                     |
| PROVIDER 7  | cancelled      | 147      | 100.0                    |
| PROVIDER 7  | delivered      | 38263    | 100.0                    |
| PROVIDER 7  | failed         | 1174     | 58.9                     |
| PROVIDER 8  | cancelled      | 5710     | 0.0                      |
| PROVIDER 8  | delivered      | 125160   | 0.0                      |
| PROVIDER 8  | failed         | 557      | 0.0                      |
| PROVIDER 9  | delivered      | 4971     | 100.0                    |
| PROVIDER 9  | failed         | 193      | 97.4                     |
## Q1.3 provider_status codes on failed and cancelled attempts (10 or more)
|  provider   | attempt_status |               provider_status               | attempts |
|-------------|----------------|---------------------------------------------|---------:|
| PROVIDER 11 | failed         | TRANSFER_HAS_BEEN_REJECTED                  | 633      |
| PROVIDER 11 | failed         | TRANSFER_HAS_BEEN_CANCELED                  | 380      |
| PROVIDER 11 | failed         | TRANSFER_REQUEST_HAS_BEEN_CANCELLED         | 178      |
| PROVIDER 11 | failed         | TRANSFER_REQUEST_HAS_EXPIRED                | 43       |
| PROVIDER 11 | failed         | TRANSMITTER_PAYER_COMBINATION_NOT_PERMITTED | 21       |
| PROVIDER 11 | failed         | 503                                         | 10       |
| PROVIDER 12 | cancelled      | NULL                                        | 5042     |
| PROVIDER 12 | failed         | NULL                                        | 1708     |
| PROVIDER 12 | failed         | 00000000                                    | 892      |
| PROVIDER 12 | failed         | HOLD:11102002                               | 143      |
| PROVIDER 2  | failed         | REFUNDED                                    | 200      |
| PROVIDER 2  | failed         | FAILED                                      | 42       |
| PROVIDER 2  | failed         | NULL                                        | 12       |
| PROVIDER 3  | cancelled      | NULL                                        | 3070     |
| PROVIDER 3  | failed         | NULL                                        | 435      |
| PROVIDER 4  | cancelled      | completed                                   | 18       |
| PROVIDER 4  | failed         | rejected                                    | 362      |
| PROVIDER 4  | failed         | failed                                      | 47       |
| PROVIDER 4  | failed         | NULL                                        | 42       |
| PROVIDER 5  | cancelled      | NULL                                        | 10       |
| PROVIDER 5  | failed         | NULL                                        | 694      |
| PROVIDER 6  | failed         | CANCELLED                                   | 23       |
| PROVIDER 7  | cancelled      | CANCELLED                                   | 147      |
| PROVIDER 7  | failed         | refunded                                    | 692      |
| PROVIDER 7  | failed         | NULL                                        | 482      |
| PROVIDER 8  | cancelled      | NULL                                        | 5710     |
| PROVIDER 8  | failed         | NULL                                        | 557      |
| PROVIDER 9  | failed         | rejected                                    | 188      |
## Q1.4 Time from disbursement creation to last update, by provider, payout type and status
|  provider   | payout_type | attempt_status | attempts | p10_minutes | p50_minutes | p90_minutes | p99_days |
|-------------|-------------|----------------|---------:|------------:|------------:|------------:|---------:|
| PROVIDER 11 | BANK        | delivered      | 47250    | 4.3         | 5.2         | 27.3        | 0.34     |
| PROVIDER 11 | BANK        | failed         | 639      | 0.4         | 1.1         | 1180.8      | 4.78     |
| PROVIDER 11 | CASH        | delivered      | 17235    | 64.7        | 818.0       | 3101.7      | 7.01     |
| PROVIDER 11 | CASH        | failed         | 639      | 15.5        | 771.8       | 8273.7      | 30.81    |
| PROVIDER 12 | BANK        | cancelled      | 2485     | 26.2        | 179.3       | 2720.1      | 14.17    |
| PROVIDER 12 | BANK        | delivered      | 113246   | 5.6         | 7.0         | 18.3        | 0.37     |
| PROVIDER 12 | BANK        | failed         | 1992     | 0.0         | 14.0        | 1358.1      | 7.13     |
| PROVIDER 12 | CASH        | cancelled      | 2557     | 15.6        | 402.9       | 5714.9      | 28.0     |
| PROVIDER 12 | CASH        | delivered      | 84825    | 68.5        | 813.9       | 3246.1      | 7.78     |
| PROVIDER 12 | CASH        | failed         | 758      | 0.0         | 194.4       | 4387.6      | 28.1     |
| PROVIDER 3  | BANK        | cancelled      | 3070     | 0.2         | 0.5         | 2.6         | 0.02     |
| PROVIDER 3  | BANK        | delivered      | 239520   | 0.1         | 0.1         | 0.3         | 0.0      |
| PROVIDER 3  | BANK        | failed         | 300      | 0.2         | 0.4         | 2.6         | 0.11     |
| PROVIDER 4  | BANK        | delivered      | 3144     | 0.6         | 1.1         | 7.3         | 0.09     |
| PROVIDER 4  | BANK        | failed         | 147      | 0.0         | 0.5         | 232.2       | 1.71     |
| PROVIDER 4  | WALLET      | delivered      | 19812    | 0.1         | 0.1         | 0.1         | 0.0      |
| PROVIDER 4  | WALLET      | failed         | 304      | 0.0         | 0.1         | 0.4         | 0.75     |
| PROVIDER 5  | BANK        | delivered      | 23818    | 0.9         | 2.1         | 5.1         | 0.16     |
| PROVIDER 7  | BANK        | delivered      | 21986    | 5.9         | 7.6         | 34.4        | 0.49     |
| PROVIDER 7  | BANK        | failed         | 774      | 0.0         | 0.1         | 95.5        | 4.0      |
| PROVIDER 7  | CASH        | cancelled      | 147      | 19.9        | 732.3       | 5934.6      | 22.47    |
| PROVIDER 7  | CASH        | delivered      | 16277    | 60.2        | 784.0       | 3087.6      | 7.01     |
| PROVIDER 7  | CASH        | failed         | 400      | 2.9         | 888.0       | 12807.9     | 31.78    |
| PROVIDER 8  | BANK        | cancelled      | 2339     | 10.7        | 49.0        | 2975.6      | 5.17     |
| PROVIDER 8  | BANK        | delivered      | 40878    | 12.2        | 24.4        | 466.9       | 1.01     |
| PROVIDER 8  | BANK        | failed         | 496      | 0.0         | 0.0         | 0.1         | 0.0      |
| PROVIDER 8  | CASH        | cancelled      | 3370     | 16.1        | 313.8       | 7316.7      | 30.11    |
| PROVIDER 8  | CASH        | delivered      | 84282    | 64.1        | 747.0       | 3203.7      | 7.83     |
## Q1.5 Share of failed and cancelled attempts by time to last update
|            grp             | attempts | a_under_1m | b_1_5m | c_5_15m | d_15_60m | e_1_3h | f_3_12h | g_12_24h | h_1_3d | i_3d_plus |
|----------------------------|---------:|-----------:|-------:|--------:|---------:|-------:|--------:|---------:|-------:|----------:|
| OTHER BANK cancelled       | 18       | 11.1       | 88.9   | NULL    | NULL     | NULL   | NULL    | NULL     | NULL   | NULL      |
| OTHER BANK failed          | 2040     | 58.3       | 22.7   | 5.4     | 2.1      | 1.9    | 2.5     | 1.4      | 2.3    | 3.5       |
| OTHER CASH cancelled       | 151      | NULL       | NULL   | 7.3     | 16.6     | 12.6   | 12.6    | 16.6     | 16.6   | 17.9      |
| OTHER CASH failed          | 1062     | 2.0        | 5.6    | 5.1     | 9.5      | 12.5   | 13.5    | 15.6     | 17.9   | 18.3      |
| PROVIDER 12 BANK cancelled | 2485     | 0.1        | 1.5    | 4.8     | 13.6     | 30.3   | 25.5    | 9.7      | 6.3    | 8.2       |
| PROVIDER 12 BANK failed    | 1992     | 15.0       | 0.5    | 35.0    | 4.9      | 13.3   | 16.1    | 5.5      | 5.3    | 4.3       |
| PROVIDER 12 CASH cancelled | 2557     | 0.4        | 3.3    | 5.8     | 13.6     | 16.5   | 16.6    | 15.4     | 16.0   | 12.5      |
| PROVIDER 12 CASH failed    | 758      | 20.4       | 1.5    | 3.8     | 9.9      | 12.9   | 15.2    | 12.5     | 13.3   | 10.4      |
| PROVIDER 3 BANK cancelled  | 3070     | 66.4       | 28.7   | 2.8     | 1.3      | 0.6    | 0.1     | 0.0      | 0.0    | NULL      |
| PROVIDER 3 BANK failed     | 300      | 83.0       | 9.3    | 2.3     | 1.0      | 4.3    | NULL    | NULL     | NULL   | NULL      |
| PROVIDER 8 BANK cancelled  | 2339     | 0.1        | 1.8    | 18.1    | 33.6     | 10.7   | 13.3    | 7.7      | 8.0    | 6.7       |
| PROVIDER 8 BANK failed     | 496      | 99.4       | 0.4    | NULL    | NULL     | NULL   | 0.2     | NULL     | NULL   | NULL      |
| PROVIDER 8 CASH cancelled  | 3370     | 0.1        | 1.6    | 7.4     | 19.9     | 15.3   | 14.2    | 12.7     | 13.4   | 15.5      |
| PROVIDER 8 CASH failed     | 61       | 96.7       | NULL   | 1.6     | NULL     | NULL   | 1.6     | NULL     | NULL   | NULL      |
## Q1.6 Cash attempts by whole days from creation to last update
| days | p8_cancelled | p12_cancelled | p7_cancelled | p11_failed_expired_code | all_cash_failed | all_cash_delivered |
|-----:|-------------:|--------------:|-------------:|------------------------:|----------------:|-------------------:|
| 0    | 2396         | 1830          | 98           | 0                       | 1317            | 149349             |
| 1    | 294          | 267           | 17           | 0                       | 192             | 28991              |
| 2    | 157          | 141           | 6            | 0                       | 99              | 11309              |
| 3    | 100          | 66            | 10           | 0                       | 66              | 5225               |
| 4    | 80           | 27            | 6            | 0                       | 35              | 2847               |
| 5    | 32           | 25            | 1            | 0                       | 17              | 1639               |
| 6    | 25           | 11            | 1            | 0                       | 9               | 1017               |
| 7    | 14           | 10            | 1            | 0                       | 16              | 668                |
| 8    | 10           | 7             | 1            | 0                       | 6               | 418                |
| 9    | 10           | 9             | 0            | 0                       | 6               | 297                |
| 10   | 22           | 14            | 1            | 0                       | 4               | 280                |
| 11   | 14           | 10            | 1            | 0                       | 3               | 235                |
| 12   | 6            | 3             | 1            | 0                       | 1               | 138                |
| 13   | 4            | 1             | 0            | 0                       | 5               | 75                 |
| 14   | 6            | 2             | 0            | 0                       | 1               | 74                 |
| 15   | 4            | 8             | 0            | 0                       | 2               | 49                 |
| 16   | 5            | 2             | 0            | 0                       | 0               | 45                 |
| 17   | 2            | 1             | 0            | 0                       | 2               | 25                 |
| 18   | 2            | 1             | 0            | 0                       | 1               | 21                 |
| 19   | 3            | 0             | 0            | 0                       | 0               | 20                 |
| 20   | 1            | 1             | 0            | 0                       | 0               | 19                 |
| 21   | 7            | 1             | 0            | 0                       | 5               | 17                 |
| 22   | 2            | 1             | 2            | 0                       | 0               | 12                 |
| 23   | 24           | 27            | 1            | 0                       | 3               | 25                 |
| 24   | 25           | 25            | 0            | 0                       | 1               | 41                 |
| 25   | 14           | 19            | 0            | 0                       | 0               | 12                 |
| 26   | 9            | 18            | 0            | 0                       | 2               | 5                  |
| 27   | 7            | 4             | 0            | 0                       | 3               | 5                  |
| 28   | 6            | 2             | 0            | 0                       | 2               | 3                  |
| 29   | 41           | 7             | 0            | 0                       | 0               | 0                  |
| 30   | 45           | 1             | 0            | 43                      | 55              | 0                  |
| 31   | 2            | 1             | 0            | 0                       | 21              | 0                  |
| 32   | 0            | 2             | 0            | 0                       | 2               | 0                  |
| 33   | 0            | 1             | 0            | 0                       | 0               | 0                  |
| 34   | 0            | 2             | 0            | 0                       | 2               | 0                  |
| 35   | 0            | 1             | 0            | 0                       | 0               | 0                  |
| 36   | 0            | 2             | 0            | 0                       | 0               | 0                  |
| 38   | 0            | 1             | 0            | 0                       | 0               | 0                  |
| 39   | 0            | 1             | 0            | 0                       | 1               | 0                  |
| 40   | 0            | 2             | 0            | 0                       | 1               | 0                  |
| 42   | 0            | 0             | 0            | 0                       | 1               | 0                  |
## Q1.7 Cancelled and failed rate by UTC hour of creation (3-hour buckets)
|  provider   | utc_hour_from | attempts | cancelled_pct | failed_pct |
|-------------|--------------:|---------:|--------------:|-----------:|
| PROVIDER 12 | 0             | 39307    | 2.55          | 1.33       |
| PROVIDER 12 | 3             | 17092    | 2.95          | 1.39       |
| PROVIDER 12 | 6             | 2993     | 3.68          | 1.97       |
| PROVIDER 12 | 9             | 6659     | 1.59          | 1.29       |
| PROVIDER 12 | 12            | 23618    | 1.85          | 1.31       |
| PROVIDER 12 | 15            | 40033    | 2.25          | 1.32       |
| PROVIDER 12 | 18            | 38143    | 2.58          | 1.32       |
| PROVIDER 12 | 21            | 38047    | 2.63          | 1.32       |
| PROVIDER 3  | 0             | 50119    | 1.26          | 0.44       |
| PROVIDER 3  | 3             | 25973    | 1.46          | 0.1        |
| PROVIDER 3  | 6             | 5501     | 1.65          | 0.56       |
| PROVIDER 3  | 9             | 5992     | 1.12          | 0.28       |
| PROVIDER 3  | 12            | 20150    | 1.15          | 0.23       |
| PROVIDER 3  | 15            | 41094    | 1.17          | 0.05       |
| PROVIDER 3  | 18            | 45578    | 1.19          | 0.09       |
| PROVIDER 3  | 21            | 48618    | 1.32          | 0.07       |
| PROVIDER 8  | 0             | 24015    | 4.62          | 0.46       |
| PROVIDER 8  | 3             | 9360     | 4.73          | 0.45       |
| PROVIDER 8  | 6             | 1577     | 4.88          | 1.08       |
| PROVIDER 8  | 9             | 4024     | 3.35          | 0.27       |
| PROVIDER 8  | 12            | 16119    | 3.82          | 0.4        |
| PROVIDER 8  | 15            | 26879    | 4.06          | 0.37       |
| PROVIDER 8  | 18            | 24891    | 4.55          | 0.45       |
| PROVIDER 8  | 21            | 24562    | 4.5           | 0.4        |
## Q1.8 Batch check: failed and cancelled attempts per minute of last update
|  provider   | attempt_status | attempts | distinct_minutes | max_in_one_minute |
|-------------|----------------|---------:|-----------------:|------------------:|
| PROVIDER 11 | failed         | 1278     | 1255             | 6                 |
| PROVIDER 12 | cancelled      | 5042     | 4850             | 4                 |
| PROVIDER 12 | failed         | 2751     | 2671             | 4                 |
| PROVIDER 2  | failed         | 254      | 249              | 3                 |
| PROVIDER 3  | cancelled      | 3070     | 3039             | 4                 |
| PROVIDER 3  | failed         | 300      | 250              | 5                 |
| PROVIDER 4  | failed         | 451      | 426              | 9                 |
| PROVIDER 7  | cancelled      | 147      | 146              | 2                 |
| PROVIDER 7  | failed         | 1174     | 1137             | 4                 |
| PROVIDER 8  | cancelled      | 5709     | 5351             | 4                 |
| PROVIDER 8  | failed         | 557      | 549              | 2                 |
| PROVIDER 9  | failed         | 193      | 193              | 1                 |
## Q1.9 What happens after a failed or cancelled attempt
| provider_group | attempt_status | attempts | pct_retried | pct_same_provider | pct_other_provider | pct_next_delivered | pct_next_same_status | pct_payment_delivered | pct_payment_refunded |
|----------------|----------------|---------:|------------:|------------------:|-------------------:|-------------------:|---------------------:|----------------------:|---------------------:|
| OTHER          | cancelled      | 179      | 83.8        | 34.1              | 49.7               | 88.0               | 5.0                  | 78.2                  | 19.6                 |
| OTHER          | failed         | 4073     | 77.6        | 31.4              | 46.2               | 74.3               | 14.5                 | 70.5                  | 28.3                 |
| PROVIDER 12    | cancelled      | 5042     | 69.8        | 41.1              | 28.7               | 80.5               | 11.8                 | 64.2                  | 34.5                 |
| PROVIDER 12    | failed         | 2751     | 71.9        | 44.4              | 27.5               | 75.0               | 12.8                 | 65.0                  | 33.2                 |
| PROVIDER 3     | cancelled      | 3070     | 70.7        | 40.6              | 30.2               | 78.9               | 10.1                 | 65.9                  | 33.4                 |
| PROVIDER 3     | failed         | 435      | 76.8        | 37.7              | 39.1               | 87.4               | 6.7                  | 75.6                  | 23.9                 |
| PROVIDER 8     | cancelled      | 5710     | 64.7        | 40.3              | 24.4               | 78.4               | 12.0                 | 58.2                  | 40.9                 |
| PROVIDER 8     | failed         | 557      | 88.5        | 33.8              | 54.8               | 51.3               | 28.0                 | 72.7                  | 25.3                 |
## Q1.10 Retry timing and beneficiary change after a failed or cancelled attempt
| provider_group | attempt_status | retried_attempts | p10_minutes_to_next | p50_minutes_to_next | p90_minutes_to_next | pct_next_created_before_close | pct_beneficiary_changed |
|----------------|----------------|-----------------:|--------------------:|--------------------:|--------------------:|------------------------------:|------------------------:|
| OTHER          | cancelled      | 150              | 1.2                 | 210.5               | 4421.1              | 0.0                           | 26.0                    |
| OTHER          | failed         | 3161             | 2.5                 | 26.8                | 1696.8              | 0.1                           | 17.6                    |
| PROVIDER 12    | cancelled      | 3518             | 15.4                | 139.0               | 2709.3              | 17.8                          | 19.1                    |
| PROVIDER 12    | failed         | 1978             | 3.4                 | 41.3                | 1748.4              | 17.2                          | 19.1                    |
| PROVIDER 3     | cancelled      | 2172             | 3.6                 | 13.9                | 179.7               | 0.0                           | 28.0                    |
| PROVIDER 3     | failed         | 334              | 1.7                 | 13.8                | 168.2               | 0.0                           | 9.6                     |
| PROVIDER 8     | cancelled      | 3694             | 23.7                | 182.0               | 4067.2              | 0.1                           | 20.8                    |
| PROVIDER 8     | failed         | 493              | 0.8                 | 4.8                 | 89.7                | 0.0                           | 6.3                     |
## Q1.11 Refund timing after the last attempt of a refunded payment
| provider_group | payout_type | attempt_status | attempts | p10_hours | p50_hours | p90_hours | pct_refunded_before_close |
|----------------|-------------|----------------|---------:|----------:|----------:|----------:|--------------------------:|
| OTHER          | BANK        | failed         | 570      | 0.07      | 3.51      | 77.67     | 0.0                       |
| OTHER          | CASH        | failed         | 242      | 0.01      | 0.06      | 221.3     | 0.0                       |
| OTHER          | WALLET      | failed         | 65       | 0.05      | 0.63      | 45.48     | 0.0                       |
| PROVIDER 12    | BANK        | cancelled      | 752      | -4.23     | 0.01      | 18.61     | 30.1                      |
| PROVIDER 12    | BANK        | failed         | 562      | -2.96     | 0.57      | 64.14     | 20.8                      |
| PROVIDER 12    | CASH        | cancelled      | 713      | 0.0       | 0.01      | 1.73      | 1.8                       |
| PROVIDER 12    | CASH        | failed         | 181      | 0.0       | 0.02      | 27.38     | 1.1                       |
| PROVIDER 3     | BANK        | cancelled      | 879      | 0.02      | 1.17      | 43.67     | 0.0                       |
| PROVIDER 3     | BANK        | failed         | 92       | 0.04      | 0.89      | 72.0      | 0.0                       |
| PROVIDER 8     | BANK        | cancelled      | 851      | 0.01      | 0.99      | 37.56     | 0.1                       |
| PROVIDER 8     | BANK        | failed         | 54       | 0.14      | 19.66     | 125.5     | 0.0                       |
| PROVIDER 8     | CASH        | cancelled      | 1124     | 0.01      | 0.19      | 54.15     | 0.1                       |
## Q1.12 Does the user send again after a non-delivered last attempt?
|                  grp                   | attempts | pct_new_payment_7d | pct_same_beneficiary_7d | pct_same_beneficiary_30d |
|----------------------------------------|---------:|-------------------:|------------------------:|-------------------------:|
| OTHER cancelled                        | 28       | 7.1                | 3.6                     | 3.6                      |
| OTHER delivered (10% sample)           | 15756    | 7.0                | 2.9                     | 9.9                      |
| OTHER failed                           | 912      | 6.8                | 1.2                     | 3.0                      |
| PROVIDER 12 cancelled                  | 1481     | 5.8                | 1.1                     | 2.4                      |
| PROVIDER 12 cancelled, status conflict | 40       | 5.0                | 5.0                     | 10.0                     |
| PROVIDER 12 delivered (10% sample)     | 20000    | 5.7                | 2.1                     | 8.4                      |
| PROVIDER 12 failed                     | 772      | 5.2                | 1.0                     | 2.6                      |
| PROVIDER 3 cancelled                   | 896      | 7.7                | 2.7                     | 5.4                      |
| PROVIDER 3 delivered (10% sample)      | 23900    | 7.7                | 3.7                     | 13.5                     |
| PROVIDER 3 failed                      | 95       | 8.4                | 4.2                     | 11.6                     |
| PROVIDER 8 cancelled                   | 2009     | 5.5                | 1.3                     | 3.4                      |
| PROVIDER 8 delivered (10% sample)      | 12610    | 5.8                | 2.0                     | 7.7                      |
| PROVIDER 8 failed                      | 64       | 6.3                | 1.6                     | 1.6                      |
## Q1.13 Monthly share of attempts that are cancelled or failed (UTC month of the receipt)
|  provider   |  month  | attempts | cancelled_pct | failed_pct | non_delivery_pct |
|-------------|---------|---------:|--------------:|-----------:|-----------------:|
| PROVIDER 12 | 2026-01 | 24841    | 3.21          | 0.31       | 3.51             |
| PROVIDER 12 | 2026-02 | 28916    | 3.1           | 0.29       | 3.39             |
| PROVIDER 12 | 2026-03 | 31451    | 3.11          | 0.48       | 3.59             |
| PROVIDER 12 | 2026-04 | 27834    | 2.12          | 1.49       | 3.61             |
| PROVIDER 12 | 2026-05 | 25469    | 2.67          | 1.53       | 4.19             |
| PROVIDER 12 | 2026-06 | 18974    | 2.78          | 1.43       | 4.22             |
| PROVIDER 12 | 2026-07 | 17813    | 2.55          | 1.63       | 4.19             |
| PROVIDER 12 | 2026-08 | 17649    | 0.67          | 3.51       | 4.19             |
| PROVIDER 12 | 2026-09 | 12945    | 0.0           | 3.49       | 3.49             |
| PROVIDER 3  | 2026-01 | 18907    | 1.57          | 0.19       | 1.76             |
| PROVIDER 3  | 2026-02 | 22239    | 1.26          | 0.19       | 1.45             |
| PROVIDER 3  | 2026-03 | 26755    | 1.44          | 0.24       | 1.68             |
| PROVIDER 3  | 2026-04 | 26572    | 0.94          | 0.23       | 1.17             |
| PROVIDER 3  | 2026-05 | 31135    | 1.1           | 0.19       | 1.29             |
| PROVIDER 3  | 2026-06 | 30099    | 1.12          | 0.26       | 1.38             |
| PROVIDER 3  | 2026-07 | 32108    | 1.36          | 0.15       | 1.51             |
| PROVIDER 3  | 2026-08 | 31994    | 1.49          | 0.1        | 1.59             |
| PROVIDER 3  | 2026-09 | 23216    | 1.13          | 0.07       | 1.2              |
| PROVIDER 8  | 2026-01 | 8366     | 4.89          | 0.57       | 5.46             |
| PROVIDER 8  | 2026-02 | 8774     | 5.14          | 0.63       | 5.77             |
| PROVIDER 8  | 2026-03 | 15365    | 4.74          | 0.55       | 5.28             |
| PROVIDER 8  | 2026-04 | 17687    | 4.96          | 0.58       | 5.54             |
| PROVIDER 8  | 2026-05 | 19980    | 4.26          | 0.49       | 4.74             |
| PROVIDER 8  | 2026-06 | 16268    | 3.94          | 0.29       | 4.23             |
| PROVIDER 8  | 2026-07 | 16735    | 4.03          | 0.17       | 4.21             |
| PROVIDER 8  | 2026-08 | 17744    | 3.98          | 0.2        | 4.19             |
| PROVIDER 8  | 2026-09 | 10508    | 3.52          | 0.56       | 4.08             |
## Q1.14 Provider 12 by week: cancelled and failed labels and provider_status coverage
|    week    | attempts | cancelled | failed_no_provider_status | failed_with_provider_status | non_delivery_pct | pct_any_provider_status |
|------------|---------:|----------:|--------------------------:|----------------------------:|-----------------:|------------------------:|
| 2026-06-01 | 4809     | 126       | 64                        | 0                           | 3.95             | 0.0                     |
| 2026-06-08 | 4727     | 117       | 60                        | 0                           | 3.74             | 0.0                     |
| 2026-06-15 | 4675     | 133       | 63                        | 0                           | 4.19             | 0.0                     |
| 2026-06-22 | 3905     | 131       | 74                        | 0                           | 5.25             | 0.0                     |
| 2026-06-29 | 3837     | 97        | 46                        | 0                           | 3.73             | 0.0                     |
| 2026-07-06 | 3874     | 99        | 63                        | 1                           | 4.21             | 0.1                     |
| 2026-07-13 | 4349     | 123       | 60                        | 6                           | 4.35             | 2.1                     |
| 2026-07-20 | 4239     | 95        | 64                        | 20                          | 4.22             | 4.6                     |
| 2026-07-27 | 3728     | 84        | 37                        | 28                          | 4.0              | 7.6                     |
| 2026-08-03 | 3798     | 76        | 38                        | 52                          | 4.37             | 17.6                    |
| 2026-08-10 | 3915     | 21        | 5                         | 155                         | 4.62             | 91.3                    |
| 2026-08-17 | 3885     | 0         | 5                         | 156                         | 4.14             | 99.9                    |
| 2026-08-24 | 4186     | 0         | 1                         | 152                         | 3.66             | 100.0                   |
| 2026-08-31 | 4402     | 0         | 4                         | 162                         | 3.77             | 99.9                    |
| 2026-09-07 | 4262     | 0         | 3                         | 152                         | 3.64             | 99.9                    |
| 2026-09-14 | 4320     | 0         | 5                         | 137                         | 3.29             | 99.9                    |
| 2026-09-21 | 804      | 0         | 0                         | 22                          | 2.74             | 100.0                   |
## Q1.15 Provider 12 non-delivery before and after the labelling change
|     era      | payout_type | attempt_status | attempts | p10_minutes | p50_minutes | p90_minutes | pct_under_10s |
|--------------|-------------|----------------|---------:|------------:|------------:|------------:|--------------:|
| 1_before     | BANK        | cancelled      | 2281     | 26.3        | 179.7       | 2742.1      | 0.0           |
| 1_before     | BANK        | failed         | 1126     | 0.0         | 93.8        | 1355.2      | 21.1          |
| 2_transition | BANK        | cancelled      | 204      | 16.2        | 167.7       | 1814.7      | 0.0           |
| 2_transition | BANK        | failed         | 376      | 5.7         | 22.5        | 903.5       | 2.1           |
| 3_after      | BANK        | failed         | 490      | 5.3         | 6.7         | 1824.6      | 3.3           |
| 1_before     | CASH        | cancelled      | 2332     | 15.3        | 405.0       | 5794.5      | 0.0           |
| 1_before     | CASH        | failed         | 337      | 0.0         | 20.9        | 4370.4      | 41.8          |
| 2_transition | CASH        | cancelled      | 225      | 19.5        | 390.7       | 5465.0      | 0.0           |
| 2_transition | CASH        | failed         | 113      | 26.3        | 384.3       | 5788.5      | 0.0           |
| 3_after      | CASH        | failed         | 308      | 17.6        | 424.7       | 3955.3      | 0.0           |
## Q1.16 Provider 12 non-delivery rate by amount band and beneficiary history, before and after
|   era    |             segment             | attempts | cancelled_pct | failed_pct | non_delivery_pct |
|----------|---------------------------------|---------:|--------------:|-----------:|-----------------:|
| 1_before | amount 1_under_250              | 84860    | 2.9           | 0.92       | 3.81             |
| 1_before | amount 2_250_1000               | 55949    | 2.13          | 0.6        | 2.72             |
| 1_before | amount 3_1000_2000              | 19180    | 3.73          | 1.07       | 4.81             |
| 1_before | amount 4_2000_plus              | 3058     | 8.11          | 4.77       | 12.88            |
| 1_before | beneficiary no_prior_delivery   | 137853   | 3.16          | 0.97       | 4.13             |
| 1_before | beneficiary with_prior_delivery | 25194    | 1.0           | 0.52       | 1.52             |
| 3_after  | amount 1_under_250              | 10781    | 0.0           | 3.59       | 3.59             |
| 3_after  | amount 2_250_1000               | 7643     | 0.0           | 3.47       | 3.47             |
| 3_after  | amount 3_1000_2000              | 2746     | 0.0           | 4.37       | 4.37             |
| 3_after  | amount 4_2000_plus              | 348      | 0.0           | 7.47       | 7.47             |
| 3_after  | beneficiary no_prior_delivery   | 15303    | 0.0           | 4.72       | 4.72             |
| 3_after  | beneficiary with_prior_delivery | 6215     | 0.0           | 1.21       | 1.21             |
## Q1.17 Cancelled and failed rate by charged amount band (before 2026-07-11)
|  provider   | amount_usd  | attempts | cancelled_pct | failed_pct |
|-------------|-------------|---------:|--------------:|-----------:|
| PROVIDER 12 | 1_under_250 | 84859    | 2.9           | 0.92       |
| PROVIDER 12 | 2_250_1000  | 55949    | 2.13          | 0.6        |
| PROVIDER 12 | 3_1000_1500 | 14204    | 3.53          | 0.99       |
| PROVIDER 12 | 4_1500_2000 | 4976     | 4.3           | 1.31       |
| PROVIDER 12 | 5_2000_2750 | 2534     | 6.91          | 1.07       |
| PROVIDER 12 | 6_2750_plus | 524      | 13.93         | 22.71      |
| PROVIDER 3  | 1_under_250 | 113610   | 0.92          | 0.21       |
| PROVIDER 3  | 2_250_1000  | 40283    | 1.53          | 0.23       |
| PROVIDER 3  | 3_1000_1500 | 7618     | 2.28          | 0.28       |
| PROVIDER 3  | 4_1500_2000 | 2572     | 3.62          | 0.39       |
| PROVIDER 3  | 5_2000_2750 | 1234     | 3.97          | 0.08       |
| PROVIDER 3  | 6_2750_plus | 610      | 2.79          | 0.0        |
| PROVIDER 8  | 1_under_250 | 70435    | 3.94          | 0.5        |
| PROVIDER 8  | 2_250_1000  | 15144    | 4.11          | 0.32       |
| PROVIDER 8  | 3_1000_1500 | 2406     | 8.73          | 0.58       |
| PROVIDER 8  | 4_1500_2000 | 1828     | 11.82         | 0.49       |
| PROVIDER 8  | 5_2000_2750 | 821      | 16.81         | 0.49       |
| PROVIDER 8  | 6_2750_plus | 871      | 21.35         | 1.03       |
## Q1.18 Same check in local currency: MXN disbursement amount bands (before 2026-07-11)
|  provider   | amount_mxn | disbursements | cancelled_pct | failed_pct |
|-------------|------------|--------------:|--------------:|-----------:|
| PROVIDER 12 | 1_under_1k | 15258         | 3.77          | 0.34       |
| PROVIDER 12 | 2_1k_5k    | 48000         | 2.26          | 0.27       |
| PROVIDER 12 | 3_5k_10k   | 23208         | 2.08          | 0.16       |
| PROVIDER 12 | 4_10k_20k  | 18470         | 2.79          | 0.19       |
| PROVIDER 12 | 5_20k_40k  | 6941          | 4.7           | 0.3        |
| PROVIDER 12 | 6_40k_plus | 538           | 9.67          | 0.56       |
| PROVIDER 3  | 1_under_1k | 45652         | 0.87          | 0.15       |
| PROVIDER 3  | 2_1k_5k    | 71825         | 0.96          | 0.13       |
| PROVIDER 3  | 3_5k_10k   | 24715         | 1.39          | 0.16       |
| PROVIDER 3  | 4_10k_20k  | 16777         | 2.04          | 0.17       |
| PROVIDER 3  | 5_20k_40k  | 5805          | 3.14          | 0.19       |
| PROVIDER 3  | 6_40k_plus | 1041          | 3.55          | 0.0        |
| PROVIDER 8  | 1_under_1k | 6350          | 5.26          | 0.2        |
| PROVIDER 8  | 2_1k_5k    | 21916         | 3.12          | 0.09       |
| PROVIDER 8  | 3_5k_10k   | 2912          | 3.43          | 0.38       |
| PROVIDER 8  | 4_10k_20k  | 750           | 8.4           | 1.33       |
| PROVIDER 8  | 5_20k_40k  | 678           | 11.21         | 1.33       |
| PROVIDER 8  | 6_40k_plus | 470           | 15.96         | 1.28       |
## Q1.19 Cancelled and failed rate by beneficiary history (before 2026-07-11)
|  provider   |     beneficiary     | attempts | cancelled_pct | failed_pct |
|-------------|---------------------|---------:|--------------:|-----------:|
| PROVIDER 12 | no_prior_delivery   | 137853   | 3.16          | 0.97       |
| PROVIDER 12 | with_prior_delivery | 25194    | 1.0           | 0.52       |
| PROVIDER 3  | no_prior_delivery   | 123237   | 1.36          | 0.22       |
| PROVIDER 3  | with_prior_delivery | 42690    | 0.74          | 0.19       |
| PROVIDER 8  | no_prior_delivery   | 77152    | 5.05          | 0.53       |
| PROVIDER 8  | with_prior_delivery | 14353    | 1.8           | 0.22       |
## Q1.20 What follows cancelled and failed attempts of USD 1,000 or more
|  provider   | attempt_status | amount_usd | attempts | pct_no_retry | pct_payment_delivered | pct_payment_refunded | p50_minutes_to_close |
|-------------|----------------|------------|---------:|-------------:|----------------------:|---------------------:|---------------------:|
| PROVIDER 12 | cancelled      | 1000_plus  | 1037     | 24.4         | 67.7                  | 31.1                 | 226.0                |
| PROVIDER 12 | cancelled      | under_1000 | 4005     | 31.7         | 63.3                  | 35.4                 | 222.0                |
| PROVIDER 12 | failed         | 1000_plus  | 556      | 20.1         | 71.9                  | 27.7                 | 7.0                  |
| PROVIDER 12 | failed         | under_1000 | 2195     | 30.1         | 63.3                  | 34.5                 | 77.0                 |
| PROVIDER 3  | cancelled      | 1000_plus  | 524      | 26.5         | 67.9                  | 31.9                 | 1.0                  |
| PROVIDER 3  | cancelled      | under_1000 | 2546     | 29.8         | 65.4                  | 33.7                 | 0.0                  |
| PROVIDER 3  | failed         | 1000_plus  | 40       | 17.5         | 82.5                  | 17.5                 | 0.0                  |
| PROVIDER 3  | failed         | under_1000 | 395      | 23.8         | 74.9                  | 24.6                 | 0.0                  |
| PROVIDER 8  | cancelled      | 1000_plus  | 929      | 42.6         | 42.6                  | 56.9                 | 486.0                |
| PROVIDER 8  | cancelled      | under_1000 | 4781     | 33.9         | 61.2                  | 37.8                 | 118.0                |
| PROVIDER 8  | failed         | 1000_plus  | 56       | 17.9         | 50.0                  | 46.4                 | 0.0                  |
| PROVIDER 8  | failed         | under_1000 | 501      | 10.8         | 75.2                  | 23.0                 | 0.0                  |
## Q1.21 Same country and payout type, different providers (2026-05-01 to 2026-07-10)
| country | payout_type |  provider   | attempts | cancelled_pct | failed_pct | non_delivery_pct |
|---------|-------------|-------------|---------:|--------------:|-----------:|-----------------:|
| GT      | BANK        | PROVIDER 8  | 6142     | 2.34          | 1.63       | 3.97             |
| GT      | BANK        | PROVIDER 12 | 2462     | 1.83          | 4.79       | 6.62             |
| GT      | CASH        | PROVIDER 8  | 4392     | 2.87          | 0.02       | 2.89             |
| GT      | CASH        | PROVIDER 12 | 6030     | 1.67          | 0.63       | 2.31             |
| GT      | CASH        | PROVIDER 7  | 3128     | 0.06          | 2.97       | 3.04             |
| GT      | CASH        | PROVIDER 11 | 1884     | 0.0           | 1.96       | 1.96             |
| MX      | BANK        | PROVIDER 12 | 19445    | 2.36          | 0.91       | 3.27             |
| MX      | BANK        | PROVIDER 3  | 71454    | 1.09          | 0.21       | 1.31             |
| MX      | BANK        | PROVIDER 11 | 19029    | 0.0           | 1.12       | 1.12             |
| MX      | BANK        | PROVIDER 7  | 7770     | 0.0           | 2.07       | 2.07             |
| MX      | CASH        | PROVIDER 12 | 13180    | 3.82          | 0.26       | 4.08             |
| MX      | CASH        | PROVIDER 8  | 14036    | 3.56          | 0.11       | 3.66             |
| MX      | CASH        | PROVIDER 11 | 1918     | 0.0           | 6.2        | 6.2              |
## Q1.22 Provider 3 raw cancelled against Provider 3 failed
|                 p3_group                 | attempts | pct_under_1m | pct_under_5m | pct_created_00_03_utc | pct_retried | pct_retried_on_other_provider | pct_beneficiary_changed_on_retry | pct_payment_delivered | pct_payment_refunded |
|------------------------------------------|---------:|-------------:|-------------:|----------------------:|------------:|------------------------------:|---------------------------------:|----------------------:|---------------------:|
| cancelled (status Failed, raw cancelled) | 3070     | 66.4         | 95.1         | 20.7                  | 70.7        | 30.2                          | 28.0                             | 65.9                  | 33.4                 |
| failed                                   | 435      | 83.0         | 92.3         | 50.8                  | 76.8        | 39.1                          | 9.6                              | 75.6                  | 23.9                 |
## Q1.23 Rule-based classes of cancelled attempts (first matching rule)
|  provider   |         class          | attempts |
|-------------|------------------------|---------:|
| PROVIDER 10 | 5_async_origin_unknown | 4        |
| PROVIDER 12 | 1_status_conflict      | 46       |
| PROVIDER 12 | 2_instant_under_5m     | 135      |
| PROVIDER 12 | 3_expiry_like_cash     | 89       |
| PROVIDER 12 | 4_refund_before_close  | 281      |
| PROVIDER 12 | 5_async_origin_unknown | 4491     |
| PROVIDER 3  | 2_instant_under_5m     | 2921     |
| PROVIDER 3  | 5_async_origin_unknown | 149      |
| PROVIDER 4  | 1_status_conflict      | 18       |
| PROVIDER 5  | 6_no_updated_at        | 10       |
| PROVIDER 7  | 5_async_origin_unknown | 147      |
| PROVIDER 8  | 1_status_conflict      | 3        |
| PROVIDER 8  | 2_instant_under_5m     | 98       |
| PROVIDER 8  | 3_expiry_like_cash     | 86       |
| PROVIDER 8  | 4_refund_before_close  | 1        |
| PROVIDER 8  | 5_async_origin_unknown | 5521     |
| PROVIDER 8  | 6_no_updated_at        | 1        |
## Q1.24 Expiry-spike excess over the neighbouring days
|  provider   | spike_days | in_window | background_per_day | excess | cash_cancelled |
|-------------|------------|----------:|-------------------:|-------:|---------------:|
| PROVIDER 12 | 23-26      | 89        | 2.4                | 79.0   | 2557           |
| PROVIDER 8  | 29-30      | 86        | 7.6                | 71.0   | 3370           |
## Q1.25 Cancellations above the rate seen under USD 1,000 (before 2026-07-11)
|  provider   | attempts_1000_plus | cancelled_1000_plus | cancelled_pct_under_1000 | cancelled_pct_1000_plus | excess_cancelled | excess_pct_of_provider_cancellations |
|-------------|-------------------:|--------------------:|-------------------------:|------------------------:|-----------------:|-------------------------------------:|
| PROVIDER 12 | 22238              | 964                 | 2.59                     | 4.33                    | 388.0            | 8.4                                  |
| PROVIDER 3  | 12034              | 333                 | 1.08                     | 2.77                    | 203.0            | 10.2                                 |
| PROVIDER 8  | 5926               | 750                 | 3.97                     | 12.66                   | 514.0            | 12.4                                 |
## Q2.1 CANCELLED rows with raw PAID, COMPLETED or CREATED
|  provider   | raw_status | payout_type | rows_ | first_day  |  last_day  | p50_minutes_to_close | max_minutes_to_close |
|-------------|------------|-------------|------:|------------|------------|---------------------:|---------------------:|
| PROVIDER 12 | PAID       | BANK        | 24    | 2026-01-02 | 2026-08-09 | 7.0                  | 30.8                 |
| PROVIDER 12 | PAID       | CASH        | 22    | 2026-01-03 | 2026-06-24 | 235.6                | 7215.2               |
| PROVIDER 4  | COMPLETED  | BANK        | 18    | 2026-01-22 | 2026-01-22 | 1.2                  | 1.9                  |
| PROVIDER 8  | CREATED    | BANK        | 2     | 2026-02-25 | 2026-02-25 | 0.0                  | 0.0                  |
| PROVIDER 8  | CREATED    | CASH        | 1     | 2026-02-25 | 2026-02-25 | 0.0                  | 0.0                  |
## Q2.2 The 67 rows by other deliveries on the payment and payment status
|  provider   | raw_status |      other_delivery       | payment_status | rows_ | chargebacks | amount_charged_usd |
|-------------|------------|---------------------------|----------------|------:|------------:|-------------------:|
| PROVIDER 12 | PAID       | another attempt delivered | SUCCESSFUL     | 6     | 0           | 3125.00            |
| PROVIDER 12 | PAID       | no delivered attempt      | REFUNDED       | 4     | 0           | 2647.61            |
| PROVIDER 12 | PAID       | no delivered attempt      | SUCCESSFUL     | 36    | 1           | 17954.40           |
| PROVIDER 4  | COMPLETED  | another attempt delivered | SUCCESSFUL     | 17    | 0           | 4111.75            |
| PROVIDER 4  | COMPLETED  | no delivered attempt      | SUCCESSFUL     | 1     | 0           | 400.00             |
| PROVIDER 8  | CREATED    | another attempt delivered | SUCCESSFUL     | 3     | 0           | 2135.00            |
## Q2.3 Payment status of the last attempt, by kind of non-delivered attempt
|        attempt_kind        | attempts | payment_successful | payment_refunded | payment_other | pct_not_refunded | chargebacks |
|----------------------------|---------:|-------------------:|-----------------:|--------------:|-----------------:|------------:|
| cancelled, plain           | 4414     | 73                 | 4340             | 1             | 1.7              | 7           |
| cancelled, status conflict | 41       | 37                 | 4                | 0             | 90.2             | 1           |
| failed                     | 1843     | 72                 | 1771             | 0             | 3.9              | 2           |
## Q2.4 Provider 12: time to close and payment update relative to disbursement update
| payout_type |    attempt_kind     | payment_status | attempts | p10_minutes_to_close | p50_minutes_to_close | p90_minutes_to_close | p50_hours_payment_update_minus_disbursement_update |
|-------------|---------------------|----------------|---------:|---------------------:|---------------------:|---------------------:|---------------------------------------------------:|
| BANK        | cancelled, plain    | REFUNDED       | 752      | 32.2                 | 241.6                | 13763.2              | 0.01                                               |
| BANK        | cancelled, plain    | SUCCESSFUL     | 7        | 7670.9               | 15792.9              | 25945.3              | -263.4                                             |
| BANK        | cancelled, raw PAID | SUCCESSFUL     | 24       | 5.4                  | 7.0                  | 18.2                 | -0.12                                              |
| BANK        | delivered           | SUCCESSFUL     | 113244   | 5.6                  | 7.0                  | 18.3                 | -0.12                                              |
| CASH        | cancelled, plain    | REFUNDED       | 709      | 15.7                 | 933.3                | 35220.4              | 0.01                                               |
| CASH        | cancelled, plain    | SUCCESSFUL     | 12       | 34338.8              | 42687.7              | 56025.5              | -711.46                                            |
| CASH        | cancelled, raw PAID | REFUNDED       | 4        | 356.5                | 816.6                | 5385.4               | 556.08                                             |
| CASH        | cancelled, raw PAID | SUCCESSFUL     | 12       | 60.9                 | 190.8                | 1720.2               | -3.93                                              |
| CASH        | delivered           | SUCCESSFUL     | 84822    | 68.5                 | 813.9                | 3246.2               | -13.88                                             |
## Q2.5 Provider 4 COMPLETED then CANCELLED: the 2026-01-22 cluster
| rows_ |         first_attempt         |         last_attempt          | p50_seconds_to_close | rerouted_to_p3_and_delivered | p50_seconds_close_to_next_attempt | max_seconds_close_to_next_attempt | p4_bank_delivered_same_window |
|------:|-------------------------------|-------------------------------|---------------------:|-----------------------------:|----------------------------------:|----------------------------------:|------------------------------:|
| 18    | 2026-01-22 13:09:27.913008+00 | 2026-01-22 15:33:08.022791+00 | 69.0                 | 17                           | 1.7                               | 4.877851                          | 0                             |
## Q2.6 Days with 3 or more status-conflict rows
|    day     | rows_ |       providers_and_raw_status       |
|------------|------:|--------------------------------------|
| 2026-01-22 | 18    | PROVIDER 4 COMPLETED                 |
| 2026-02-25 | 4     | PROVIDER 8 CREATED, PROVIDER 12 PAID |
## Q2.7 Metric effect of treating the status-conflict rows as delivered
| payments | customer_paid_usd | pct_of_delivered_remittances | pct_of_delivered_usd |
|---------:|------------------:|-----------------------------:|---------------------:|
| 37       | 18526.57          | 0.0051                       | 0.0078               |
## Q3.1 Failed rate with Wilson 95% intervals, and rates under other readings of cancellations
|  provider   | attempts | delivered | failed | cancelled | failed_pct | failed_lo | failed_hi |  class_as_written   | interval_vs_threshold | failed_or_cancelled_pct | fc_lo | fc_hi | class_failed_or_cancelled |
|-------------|---------:|----------:|-------:|----------:|-----------:|----------:|----------:|---------------------|-----------------------|------------------------:|------:|------:|---------------------------|
| PROVIDER 3  | 243048   | 239520    | 435    | 3070      | 0.18       | 0.17      | 0.2       | low                 |                       | 1.44                    | 1.4   | 1.49  | medium                    |
| PROVIDER 12 | 206334   | 198099    | 2751   | 5042      | 1.37       | 1.32      | 1.42      | medium              |                       | 3.78                    | 3.7   | 3.87  | high                      |
| PROVIDER 8  | 131807   | 125160    | 557    | 5710      | 0.44       | 0.41      | 0.48      | low                 |                       | 4.77                    | 4.65  | 4.88  | high                      |
| PROVIDER 11 | 65966    | 64485     | 1278   | 0         | 1.94       | 1.84      | 2.05      | medium              |                       | 1.94                    | 1.84  | 2.05  | medium                    |
| PROVIDER 7  | 39819    | 38263     | 1174   | 147       | 2.98       | 2.81      | 3.15      | medium              | straddles 3%          | 3.34                    | 3.16  | 3.52  | high                      |
| PROVIDER 5  | 24524    | 23820     | 694    | 10        | 2.83       | 2.63      | 3.05      | medium              | straddles 3%          | 2.87                    | 2.67  | 3.09  | medium                    |
| PROVIDER 4  | 23426    | 22956     | 451    | 18        | 1.93       | 1.76      | 2.11      | medium              |                       | 2.0                     | 1.83  | 2.19  | medium                    |
| PROVIDER 9  | 5166     | 4971      | 193    | 0         | 3.74       | 3.25      | 4.29      | high                |                       | 3.74                    | 3.25  | 4.29  | high                      |
| PROVIDER 2  | 3396     | 3141      | 254    | 0         | 7.48       | 6.64      | 8.42      | high                |                       | 7.48                    | 6.64  | 8.42  | high                      |
| PROVIDER 6  | 268      | 240       | 27     | 0         | 10.11      | 7.04      | 14.31     | insufficient_volume |                       | 10.11                   | 7.04  | 14.31 | insufficient_volume       |
| PROVIDER 10 | 6        | 2         | 0      | 4         | 0.0        | 0.0       | 65.76     | insufficient_volume |                       | 66.67                   | 30.0  | 90.32 | insufficient_volume       |
| PROVIDER 1  | 3        | 1         | 2      | 0         | 66.67      | 20.77     | 93.85     | insufficient_volume |                       | 66.67                   | 20.77 | 93.85 | insufficient_volume       |
## Q3.2 Failed rate by provider and month (UTC month of the receipt)
|  provider   |  month  | terminal_attempts | failed | failed_pct |  lo   |  hi   | class_failed | failed_or_cancelled_pct | class_failed_or_cancelled |
|-------------|---------|------------------:|-------:|-----------:|------:|------:|--------------|------------------------:|---------------------------|
| PROVIDER 11 | 2026-04 | 2514              | 43     | 1.71       | 1.27  | 2.3   | medium       | 1.71                    | medium                    |
| PROVIDER 11 | 2026-05 | 10143             | 226    | 2.23       | 1.96  | 2.53  | medium       | 2.23                    | medium                    |
| PROVIDER 11 | 2026-06 | 12177             | 254    | 2.09       | 1.85  | 2.36  | medium       | 2.09                    | medium                    |
| PROVIDER 11 | 2026-07 | 14706             | 282    | 1.92       | 1.71  | 2.15  | medium       | 1.92                    | medium                    |
| PROVIDER 11 | 2026-08 | 15370             | 269    | 1.75       | 1.55  | 1.97  | medium       | 1.75                    | medium                    |
| PROVIDER 11 | 2026-09 | 10853             | 204    | 1.88       | 1.64  | 2.15  | medium       | 1.88                    | medium                    |
| PROVIDER 12 | 2026-01 | 24044             | 76     | 0.32       | 0.25  | 0.4   | low          | 3.51                    | high                      |
| PROVIDER 12 | 2026-02 | 28021             | 85     | 0.3        | 0.25  | 0.37  | low          | 3.39                    | high                      |
| PROVIDER 12 | 2026-03 | 30472             | 150    | 0.49       | 0.42  | 0.58  | low          | 3.59                    | high                      |
| PROVIDER 12 | 2026-04 | 27244             | 416    | 1.53       | 1.39  | 1.68  | medium       | 3.61                    | high                      |
| PROVIDER 12 | 2026-05 | 24790             | 389    | 1.57       | 1.42  | 1.73  | medium       | 4.19                    | high                      |
| PROVIDER 12 | 2026-06 | 18446             | 272    | 1.47       | 1.31  | 1.66  | medium       | 4.22                    | high                      |
| PROVIDER 12 | 2026-07 | 17358             | 291    | 1.68       | 1.5   | 1.88  | medium       | 4.19                    | high                      |
| PROVIDER 12 | 2026-08 | 17530             | 620    | 3.54       | 3.27  | 3.82  | high         | 4.19                    | high                      |
| PROVIDER 12 | 2026-09 | 12945             | 452    | 3.49       | 3.19  | 3.82  | high         | 3.49                    | high                      |
| PROVIDER 2  | 2026-03 | 226               | 13     | 5.75       | 3.39  | 9.59  | high         | 5.75                    | high                      |
| PROVIDER 2  | 2026-04 | 650               | 11     | 1.69       | 0.95  | 3.0   | medium       | 1.69                    | medium                    |
| PROVIDER 2  | 2026-05 | 317               | 8      | 2.52       | 1.28  | 4.9   | medium       | 2.52                    | medium                    |
| PROVIDER 2  | 2026-06 | 441               | 142    | 32.2       | 28.01 | 36.7  | high         | 32.2                    | high                      |
| PROVIDER 2  | 2026-07 | 429               | 31     | 7.23       | 5.14  | 10.07 | high         | 7.23                    | high                      |
| PROVIDER 2  | 2026-08 | 845               | 32     | 3.79       | 2.7   | 5.3   | high         | 3.79                    | high                      |
| PROVIDER 2  | 2026-09 | 375               | 12     | 3.2        | 1.84  | 5.51  | high         | 3.2                     | high                      |
| PROVIDER 3  | 2026-01 | 18610             | 36     | 0.19       | 0.14  | 0.27  | low          | 1.76                    | medium                    |
| PROVIDER 3  | 2026-02 | 21959             | 42     | 0.19       | 0.14  | 0.26  | low          | 1.45                    | medium                    |
| PROVIDER 3  | 2026-03 | 26370             | 65     | 0.25       | 0.19  | 0.31  | low          | 1.68                    | medium                    |
| PROVIDER 3  | 2026-04 | 26322             | 61     | 0.23       | 0.18  | 0.3   | low          | 1.17                    | medium                    |
| PROVIDER 3  | 2026-05 | 30791             | 58     | 0.19       | 0.15  | 0.24  | low          | 1.29                    | medium                    |
| PROVIDER 3  | 2026-06 | 29763             | 78     | 0.26       | 0.21  | 0.33  | low          | 1.38                    | medium                    |
| PROVIDER 3  | 2026-07 | 31670             | 47     | 0.15       | 0.11  | 0.2   | low          | 1.51                    | medium                    |
| PROVIDER 3  | 2026-08 | 31517             | 32     | 0.1        | 0.07  | 0.14  | low          | 1.59                    | medium                    |
| PROVIDER 3  | 2026-09 | 22953             | 16     | 0.07       | 0.04  | 0.11  | low          | 1.2                     | medium                    |
| PROVIDER 4  | 2026-01 | 3134              | 53     | 1.69       | 1.3   | 2.21  | medium       | 2.25                    | medium                    |
| PROVIDER 4  | 2026-02 | 1240              | 36     | 2.9        | 2.1   | 3.99  | medium       | 2.9                     | medium                    |
| PROVIDER 4  | 2026-03 | 1924              | 56     | 2.91       | 2.25  | 3.76  | medium       | 2.91                    | medium                    |
| PROVIDER 4  | 2026-04 | 2265              | 63     | 2.78       | 2.18  | 3.54  | medium       | 2.78                    | medium                    |
| PROVIDER 4  | 2026-05 | 2739              | 119    | 4.34       | 3.64  | 5.17  | high         | 4.34                    | high                      |
| PROVIDER 4  | 2026-06 | 2657              | 31     | 1.17       | 0.82  | 1.65  | medium       | 1.17                    | medium                    |
| PROVIDER 4  | 2026-07 | 3011              | 25     | 0.83       | 0.56  | 1.22  | low          | 0.83                    | low                       |
| PROVIDER 4  | 2026-08 | 3720              | 36     | 0.97       | 0.7   | 1.34  | low          | 0.97                    | low                       |
| PROVIDER 4  | 2026-09 | 2717              | 32     | 1.18       | 0.84  | 1.66  | medium       | 1.18                    | medium                    |
| PROVIDER 5  | 2026-01 | 1175              | 59     | 5.02       | 3.91  | 6.42  | high         | 5.1                     | high                      |
| PROVIDER 5  | 2026-02 | 1414              | 74     | 5.23       | 4.19  | 6.52  | high         | 5.37                    | high                      |
| PROVIDER 5  | 2026-03 | 1811              | 79     | 4.36       | 3.51  | 5.4   | high         | 4.47                    | high                      |
| PROVIDER 5  | 2026-04 | 2623              | 97     | 3.7        | 3.04  | 4.49  | high         | 3.73                    | high                      |
| PROVIDER 5  | 2026-05 | 3094              | 98     | 3.17       | 2.61  | 3.84  | high         | 3.29                    | high                      |
| PROVIDER 5  | 2026-06 | 3184              | 63     | 1.98       | 1.55  | 2.52  | medium       | 1.98                    | medium                    |
| PROVIDER 5  | 2026-07 | 3285              | 84     | 2.56       | 2.07  | 3.15  | medium       | 2.56                    | medium                    |
| PROVIDER 5  | 2026-08 | 4265              | 82     | 1.92       | 1.55  | 2.38  | medium       | 1.92                    | medium                    |
| PROVIDER 5  | 2026-09 | 3663              | 58     | 1.58       | 1.23  | 2.04  | medium       | 1.58                    | medium                    |
| PROVIDER 7  | 2026-05 | 2787              | 83     | 2.98       | 2.41  | 3.68  | medium       | 2.98                    | medium                    |
| PROVIDER 7  | 2026-06 | 8216              | 345    | 4.2        | 3.79  | 4.65  | high         | 4.2                     | high                      |
| PROVIDER 7  | 2026-07 | 10387             | 336    | 3.23       | 2.91  | 3.59  | high         | 3.65                    | high                      |
| PROVIDER 7  | 2026-08 | 10048             | 251    | 2.5        | 2.21  | 2.82  | medium       | 2.96                    | medium                    |
| PROVIDER 7  | 2026-09 | 7997              | 159    | 1.99       | 1.7   | 2.32  | medium       | 2.65                    | medium                    |
| PROVIDER 8  | 2026-01 | 7957              | 48     | 0.6        | 0.46  | 0.8   | low          | 5.46                    | high                      |
| PROVIDER 8  | 2026-02 | 8323              | 55     | 0.66       | 0.51  | 0.86  | low          | 5.77                    | high                      |
| PROVIDER 8  | 2026-03 | 14637             | 84     | 0.57       | 0.46  | 0.71  | low          | 5.28                    | high                      |
| PROVIDER 8  | 2026-04 | 16809             | 102    | 0.61       | 0.5   | 0.74  | low          | 5.54                    | high                      |
| PROVIDER 8  | 2026-05 | 19129             | 97     | 0.51       | 0.42  | 0.62  | low          | 4.74                    | high                      |
| PROVIDER 8  | 2026-06 | 15627             | 47     | 0.3        | 0.23  | 0.4   | low          | 4.23                    | high                      |
| PROVIDER 8  | 2026-07 | 16060             | 29     | 0.18       | 0.13  | 0.26  | low          | 4.21                    | high                      |
| PROVIDER 8  | 2026-08 | 17037             | 36     | 0.21       | 0.15  | 0.29  | low          | 4.19                    | high                      |
| PROVIDER 8  | 2026-09 | 10138             | 59     | 0.58       | 0.45  | 0.75  | low          | 4.08                    | high                      |
| PROVIDER 9  | 2026-07 | 372               | 38     | 10.22      | 7.53  | 13.71 | high         | 10.22                   | high                      |
| PROVIDER 9  | 2026-08 | 2363              | 135    | 5.71       | 4.85  | 6.72  | high         | 5.71                    | high                      |
| PROVIDER 9  | 2026-09 | 2429              | 20     | 0.82       | 0.53  | 1.27  | low          | 0.82                    | low                       |
## Q3.3 Class stability across months with 1,000 or more terminal attempts
|  provider   | months | min_failed_pct | max_failed_pct | distinct_classes_failed | class_sequence_failed | min_fc_pct | max_fc_pct | distinct_classes_fc | class_sequence_fc |
|-------------|-------:|---------------:|---------------:|------------------------:|-----------------------|-----------:|-----------:|--------------------:|-------------------|
| PROVIDER 11 | 6      | 1.71           | 2.23           | 1                       | mmmmmm                | 1.71       | 2.23       | 1                   | mmmmmm            |
| PROVIDER 12 | 9      | 0.3            | 3.54           | 3                       | lllmmmmhh             | 3.39       | 4.22       | 1                   | hhhhhhhhh         |
| PROVIDER 3  | 9      | 0.07           | 0.26           | 1                       | lllllllll             | 1.17       | 1.76       | 1                   | mmmmmmmmm         |
| PROVIDER 4  | 9      | 0.83           | 4.34           | 3                       | mmmmhmllm             | 0.83       | 4.34       | 3                   | mmmmhmllm         |
| PROVIDER 5  | 9      | 1.58           | 5.23           | 2                       | hhhhhmmmm             | 1.58       | 5.37       | 2                   | hhhhhmmmm         |
| PROVIDER 7  | 5      | 1.99           | 4.2            | 2                       | mhhmm                 | 2.65       | 4.2        | 2                   | mhhmm             |
| PROVIDER 8  | 9      | 0.18           | 0.66           | 1                       | lllllllll             | 4.08       | 5.77       | 1                   | hhhhhhhhh         |
| PROVIDER 9  | 2      | 0.82           | 5.71           | 2                       | hl                    | 0.82       | 5.71       | 2                   | hl                |
## Q3.4 Recent period: attempts created from 2026-07-01
|  provider   | terminal_attempts | failed_pct |  lo  |  hi  | class_failed | interval_vs_threshold | failed_or_cancelled_pct |
|-------------|------------------:|-----------:|-----:|-----:|--------------|-----------------------|------------------------:|
| PROVIDER 3  | 86140             | 0.11       | 0.09 | 0.13 | low          |                       | 1.46                    |
| PROVIDER 8  | 43235             | 0.29       | 0.24 | 0.34 | low          |                       | 4.17                    |
| PROVIDER 4  | 9448              | 0.98       | 0.8  | 1.2  | low          | straddles 1%          | 0.98                    |
| PROVIDER 11 | 40929             | 1.84       | 1.72 | 1.98 | medium       |                       | 1.84                    |
| PROVIDER 5  | 11213             | 2.0        | 1.75 | 2.27 | medium       |                       | 2.0                     |
| PROVIDER 7  | 28432             | 2.62       | 2.44 | 2.82 | medium       |                       | 3.12                    |
| PROVIDER 12 | 47833             | 2.85       | 2.7  | 3.0  | medium       | straddles 3%          | 4.0                     |
| PROVIDER 9  | 5164              | 3.74       | 3.25 | 4.29 | high         |                       | 3.74                    |
| PROVIDER 2  | 1649              | 4.55       | 3.64 | 5.66 | high         |                       | 4.55                    |
## Q3.5 Rates by provider and payout type
|  provider   | payout_type | terminal_attempts | failed_pct | failed_or_cancelled_pct |
|-------------|-------------|------------------:|-----------:|------------------------:|
| PROVIDER 11 | BANK        | 47889             | 1.33       | 1.33                    |
| PROVIDER 11 | CASH        | 17874             | 3.58       | 3.58                    |
| PROVIDER 12 | BANK        | 115238            | 1.73       | 3.8                     |
| PROVIDER 12 | CASH        | 85583             | 0.89       | 3.76                    |
| PROVIDER 2  | BANK        | 3395              | 7.48       | 7.48                    |
| PROVIDER 3  | BANK        | 239955            | 0.18       | 1.44                    |
| PROVIDER 4  | BANK        | 3291              | 4.47       | 4.99                    |
| PROVIDER 4  | WALLET      | 20116             | 1.51       | 1.51                    |
| PROVIDER 5  | BANK        | 24514             | 2.83       | 2.87                    |
| PROVIDER 7  | BANK        | 22760             | 3.4        | 3.4                     |
| PROVIDER 7  | CASH        | 16677             | 2.4        | 3.25                    |
| PROVIDER 8  | BANK        | 41374             | 1.2        | 6.49                    |
| PROVIDER 8  | CASH        | 84343             | 0.07       | 3.91                    |
| PROVIDER 9  | BANK        | 5163              | 3.74       | 3.74                    |
## Q3.6 Direct standardization by country and payout type
|  provider   | terminal_attempts | crude_failed_pct | standardized_failed_pct | crude_class | standardized_class | crude_rank | standardized_rank | coverage_pct | crude_fc_pct | standardized_fc_pct | crude_fc_rank | standardized_fc_rank |
|-------------|------------------:|-----------------:|------------------------:|-------------|--------------------|-----------:|------------------:|-------------:|-------------:|--------------------:|--------------:|---------------------:|
| PROVIDER 3  | 239955            | 0.18             | 0.18                    | low         | low                | 1          | 1                 | 55.5         | 1.44         | 1.44                | 1             | 1                    |
| PROVIDER 8  | 125640            | 0.44             | 1.35                    | low         | medium             | 2          | 2                 | 95.0         | 4.76         | 8.11                | 8             | 9                    |
| PROVIDER 12 | 200215            | 1.35             | 1.87                    | medium      | medium             | 3          | 3                 | 95.9         | 3.76         | 4.4                 | 7             | 6                    |
| PROVIDER 11 | 65630             | 1.91             | 2.2                     | medium      | medium             | 4          | 4                 | 90.3         | 1.91         | 2.22                | 2             | 2                    |
| PROVIDER 4  | 23407             | 1.93             | 4.33                    | medium      | high               | 5          | 8                 | 58.3         | 2.0          | 4.82                | 3             | 7                    |
| PROVIDER 5  | 24028             | 2.76             | 3.08                    | medium      | high               | 6          | 6                 | 9.0          | 2.8          | 3.15                | 4             | 4                    |
| PROVIDER 7  | 38943             | 2.77             | 2.64                    | medium      | medium             | 7          | 5                 | 85.2         | 3.13         | 3.14                | 5             | 3                    |
| PROVIDER 9  | 5163              | 3.74             | 3.74                    | high        | high               | 8          | 7                 | 3.4          | 3.74         | 3.74                | 6             | 5                    |
| PROVIDER 2  | 3395              | 7.48             | 7.48                    | high        | high               | 9          | 9                 | 55.5         | 7.48         | 7.48                | 9             | 8                    |
## Q3.7 First observed attempt against retries, with Wilson intervals
|  provider   | position | terminal_attempts | failed | failed_pct |  lo   |  hi   | failed_or_cancelled_pct |
|-------------|----------|------------------:|-------:|-----------:|------:|------:|------------------------:|
| PROVIDER 11 | retry    | 847               | 164    | 19.36      | 16.84 | 22.16 | 19.36                   |
| PROVIDER 11 | first    | 64916             | 1114   | 1.72       | 1.62  | 1.82  | 1.72                    |
| PROVIDER 12 | retry    | 5088              | 657    | 12.91      | 12.02 | 13.86 | 23.47                   |
| PROVIDER 12 | first    | 195762            | 2094   | 1.07       | 1.03  | 1.12  | 3.22                    |
| PROVIDER 2  | retry    | 277               | 116    | 41.88      | 36.22 | 47.76 | 41.88                   |
| PROVIDER 2  | first    | 3118              | 138    | 4.43       | 3.76  | 5.21  | 4.43                    |
| PROVIDER 3  | retry    | 1705              | 20     | 1.17       | 0.76  | 1.8   | 16.34                   |
| PROVIDER 3  | first    | 238250            | 415    | 0.17       | 0.16  | 0.19  | 1.32                    |
| PROVIDER 4  | retry    | 429               | 69     | 16.08      | 12.91 | 19.86 | 16.08                   |
| PROVIDER 4  | first    | 22978             | 382    | 1.66       | 1.51  | 1.84  | 1.74                    |
| PROVIDER 5  | retry    | 496               | 84     | 16.94      | 13.89 | 20.49 | 16.94                   |
| PROVIDER 5  | first    | 24018             | 610    | 2.54       | 2.35  | 2.75  | 2.58                    |
| PROVIDER 7  | retry    | 687               | 134    | 19.51      | 16.72 | 22.63 | 21.45                   |
| PROVIDER 7  | first    | 38750             | 1040   | 2.68       | 2.53  | 2.85  | 3.01                    |
| PROVIDER 8  | retry    | 3974              | 177    | 4.45       | 3.86  | 5.14  | 24.17                   |
| PROVIDER 8  | first    | 121743            | 380    | 0.31       | 0.28  | 0.35  | 4.0                     |
| PROVIDER 9  | retry    | 88                | 39     | 44.32      | 34.39 | 54.72 | 44.32                   |
| PROVIDER 9  | first    | 5076              | 154    | 3.03       | 2.6   | 3.54  | 3.03                    |
## Q3.8 Natural breaks: gaps between neighbouring providers (1,000 or more attempts)
|       measure       |  provider   | rate_pct | gap_pp | ratio_to_previous |
|---------------------|-------------|---------:|-------:|------------------:|
| failed_or_cancelled | PROVIDER 3  | 1.44     | NULL   | NULL              |
| failed_or_cancelled | PROVIDER 11 | 1.94     | 0.5    | 1.35              |
| failed_or_cancelled | PROVIDER 4  | 2.0      | 0.06   | 1.03              |
| failed_or_cancelled | PROVIDER 5  | 2.87     | 0.87   | 1.43              |
| failed_or_cancelled | PROVIDER 7  | 3.34     | 0.47   | 1.16              |
| failed_or_cancelled | PROVIDER 9  | 3.74     | 0.4    | 1.12              |
| failed_or_cancelled | PROVIDER 12 | 3.78     | 0.05   | 1.01              |
| failed_or_cancelled | PROVIDER 8  | 4.77     | 0.98   | 1.26              |
| failed_or_cancelled | PROVIDER 2  | 7.48     | 2.71   | 1.57              |
| failed              | PROVIDER 3  | 0.18     | NULL   | NULL              |
| failed              | PROVIDER 8  | 0.44     | 0.26   | 2.44              |
| failed              | PROVIDER 12 | 1.37     | 0.93   | 3.09              |
| failed              | PROVIDER 4  | 1.93     | 0.56   | 1.41              |
| failed              | PROVIDER 11 | 1.94     | 0.02   | 1.01              |
| failed              | PROVIDER 5  | 2.83     | 0.89   | 1.46              |
| failed              | PROVIDER 7  | 2.98     | 0.15   | 1.05              |
| failed              | PROVIDER 9  | 3.74     | 0.76   | 1.26              |
| failed              | PROVIDER 2  | 7.48     | 3.74   | 2.0               |
## Q3.9 Precision at the thresholds, and provider-months under 1,000 terminal attempts
| attempts | true_rate | lo_pct | hi_pct | half_width_pp |
|---------:|----------:|-------:|-------:|--------------:|
| 100      | 0.01      | 0.18   | 5.45   | 2.64          |
| 300      | 0.01      | 0.34   | 2.9    | 1.28          |
| 1000     | 0.01      | 0.54   | 1.83   | 0.64          |
| 3000     | 0.01      | 0.7    | 1.42   | 0.36          |
| 10000    | 0.01      | 0.82   | 1.21   | 0.2           |
| 30000    | 0.01      | 0.89   | 1.12   | 0.11          |
| 100      | 0.03      | 1.03   | 8.45   | 3.71          |
| 300      | 0.03      | 1.59   | 5.6    | 2.01          |
| 1000     | 0.03      | 2.11   | 4.25   | 1.07          |
| 3000     | 0.03      | 2.45   | 3.67   | 0.61          |
| 10000    | 0.03      | 2.68   | 3.35   | 0.33          |
| 30000    | 0.03      | 2.81   | 3.2    | 0.19          |
| provider_months | under_1000 | under_300 |    providers_with_short_months     |
|----------------:|-----------:|----------:|------------------------------------|
| 69              | 11         | 4         | PROVIDER 9, PROVIDER 2, PROVIDER 7 |
## Q3.10 Failed rate and class under alternative readings of cancellations
|  provider   | attempts | as_written | p3_cancel_as_failed | all_cancel_as_failed | cancel_codes_excluded | y5_as_delivered_in_all_cancel |  class_as_written   | class_p3_cancel_as_failed | class_all_cancel_as_failed | class_cancel_codes_excluded |
|-------------|---------:|-----------:|--------------------:|---------------------:|----------------------:|------------------------------:|---------------------|---------------------------|----------------------------|-----------------------------|
| PROVIDER 3  | 243048   | 0.18       | 1.44                | 1.44                 | 0.18                  | 1.44                          | low                 | medium                    | medium                     | low                         |
| PROVIDER 12 | 206334   | 1.37       | 1.37                | 3.78                 | 1.37                  | 3.76                          | medium              | medium                    | high                       | medium                      |
| PROVIDER 8  | 131807   | 0.44       | 0.44                | 4.77                 | 0.44                  | 4.77                          | low                 | low                       | high                       | low                         |
| PROVIDER 11 | 65966    | 1.94       | 1.94                | 1.94                 | 1.04                  | 1.94                          | medium              | medium                    | medium                     | medium                      |
| PROVIDER 7  | 39819    | 2.98       | 2.98                | 3.34                 | 2.98                  | 3.34                          | medium              | medium                    | high                       | medium                      |
| PROVIDER 5  | 24524    | 2.83       | 2.83                | 2.87                 | 2.83                  | 2.87                          | medium              | medium                    | medium                     | medium                      |
| PROVIDER 4  | 23426    | 1.93       | 1.93                | 2.0                  | 1.93                  | 1.93                          | medium              | medium                    | medium                     | medium                      |
| PROVIDER 9  | 5166     | 3.74       | 3.74                | 3.74                 | 3.74                  | 3.74                          | high                | high                      | high                       | high                        |
| PROVIDER 2  | 3396     | 7.48       | 7.48                | 7.48                 | 7.48                  | 7.48                          | high                | high                      | high                       | high                        |
| PROVIDER 6  | 268      | 10.11      | 10.11               | 10.11                | 1.64                  | 10.11                         | insufficient_volume | insufficient_volume       | insufficient_volume        | insufficient_volume         |
| PROVIDER 10 | 6        | 0.0        | 0.0                 | 66.67                | 0.0                   | 66.67                         | insufficient_volume | insufficient_volume       | insufficient_volume        | insufficient_volume         |
| PROVIDER 1  | 3        | 66.67      | 66.67               | 66.67                | 66.67                 | 66.67                         | insufficient_volume | insufficient_volume       | insufficient_volume        | insufficient_volume         |
## Q3.11 Failed attempts whose provider_status says cancelled or expired
|  provider   |           provider_status           | payout_type | attempts | p50_hours_to_close |
|-------------|-------------------------------------|-------------|---------:|-------------------:|
| PROVIDER 11 | TRANSFER_HAS_BEEN_CANCELED          | CASH        | 380      | 9.1                |
| PROVIDER 11 | TRANSFER_REQUEST_HAS_BEEN_CANCELLED | CASH        | 178      | 9.1                |
| PROVIDER 11 | TRANSFER_REQUEST_HAS_EXPIRED        | CASH        | 43       | 734.3              |
| PROVIDER 6  | CANCELLED                           | CASH        | 23       | 14.0               |
## Q4.1 Raw-table checks of the headline counts
|                                check_                                 | value_ |
|-----------------------------------------------------------------------|-------:|
| Provider 12 rows cancelled (status or raw), created before 2026-07-11 | 4613   |
| Provider 12 rows cancelled (status or raw), created from 2026-08-17   | 0      |
| Provider 3 rows with raw cancelled                                    | 3070   |
| Provider 3 raw cancelled closed within 60 seconds                     | 2040   |
| Provider 8 rows failed                                                | 557    |
| Provider 8 rows failed, closed within 60 seconds                      | 552    |
| Provider 8 rows cancelled (status and raw), closed within 60 seconds  | 1      |
| Provider 8 rows cancelled (status and raw)                            | 5707   |
| CANCELLED rows with raw PAID or COMPLETED                             | 64     |
| Those rows on a SUCCESSFUL payment with no other delivered attempt    | 37     |
## Q4.2 Provider 12 non-delivery by month, from raw_disbursements (one row per disbursement)
|  month  | delivered | failed | cancelled | non_delivery_pct |
|---------|----------:|-------:|----------:|-----------------:|
| 2026-01 | 23968     | 76     | 797       | 3.51             |
| 2026-02 | 27936     | 85     | 895       | 3.39             |
| 2026-03 | 30322     | 150    | 979       | 3.59             |
| 2026-04 | 26828     | 416    | 590       | 3.61             |
| 2026-05 | 24401     | 389    | 679       | 4.19             |
| 2026-06 | 18174     | 272    | 528       | 4.22             |
| 2026-07 | 17067     | 291    | 455       | 4.19             |
| 2026-08 | 16910     | 620    | 119       | 4.19             |
| 2026-09 | 12493     | 452    | 0         | 3.49             |
