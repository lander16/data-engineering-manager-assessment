## Delivered attempts and payments
| delivered_attempts | payments |
|-------------------:|---------:|
| 720649             | 720630   |
## Primary attempt economics compared with all delivered attempts
| value_all_delivered |  value_primary   | fee_all_delivered |  fee_primary   | promotion_all_delivered | promotion_primary |
|--------------------:|-----------------:|------------------:|---------------:|------------------------:|------------------:|
| 234908070.150000    | 234902590.080000 | 2891406.770000    | 2891350.950000 | 721094.720000           | 721074.720000     |
## Multiple delivered payments
| payments | duplicate_value | duplicate_fee | duplicate_promotion |
|---------:|----------------:|--------------:|--------------------:|
| 19       | 5480.070000     | 55.820000     | 20.000000           |
## Primary attempt compared with payment amount
| payments | ties_out | does_not_tie | net_gap_usd |
|---------:|---------:|-------------:|------------:|
| 720630   | 719743   | 887          | 2970.950000 |
## Promotions by attempt status
| attempt_status | attempts | promotion_usd |
|----------------|---------:|--------------:|
| delivered      | 13369    | 721094.720000 |
| cancelled      | 362      | 12698.670000  |
| failed         | 221      | 9569.720000   |
| in_flight      | 29       | 3086.000000   |
| missing        | 2        | 30.000000     |
## Fee and promotion differences across attempts of one payment
| multi_attempt_payments | fee_differs | promotion_differs |
|-----------------------:|------------:|------------------:|
| 13215                  | 115         | 0                 |
## Payout outcomes under the proposed rule
|       status        |   payout_outcome   | payments |         usd         |
|---------------------|--------------------|---------:|--------------------:|
| FAILED              | no_receipt         | 58684    | 27567825.155192383  |
| FAILED              | delivered          | 2        | 512.990000000       |
| FAILED              | not_delivered      | 1        | 500.000000000       |
| PENDING_USER_ACTION | no_receipt         | 17       | 7039.400000000      |
| REFUNDED            | not_delivered      | 6106     | 2653985.044491912   |
| REFUNDED            | no_receipt         | 86       | 33583.670000000     |
| REFUNDED            | missing_payout     | 15       | 13132.790000000     |
| REFUNDED            | delivered          | 7        | 1897.490000000      |
| REFUNDED            | in_flight          | 5        | 352.250000000       |
| STARTED             | no_receipt         | 1        | -0.900000000        |
| SUCCESSFUL          | delivered          | 720611   | 237070321.026685776 |
| SUCCESSFUL          | no_receipt         | 1961     | 40690.150000000     |
| SUCCESSFUL          | in_flight          | 1276     | 562114.759999542    |
| SUCCESSFUL          | not_delivered      | 182      | 50900.590010986     |
| SUCCESSFUL          | multiple_delivered | 19       | 5515.890000000      |
| SUCCESSFUL          | missing_payout     | 3        | 904.990000000       |
## Provider rates with a terminal denominator
|  provider   | attempts | delivered | failed | cancelled | in_flight | failed_over_all_pct | failed_rate_pct | cancelled_rate_pct |    failure_class    |
|-------------|---------:|----------:|-------:|----------:|----------:|--------------------:|----------------:|-------------------:|---------------------|
| PROVIDER 3  | 243048   | 239520    | 435    | 3070      | 23        | 0.18                | 0.18            | 1.26               | low                 |
| PROVIDER 12 | 206334   | 198099    | 2751   | 5042      | 442       | 1.33                | 1.37            | 2.45               | medium              |
| PROVIDER 8  | 131807   | 125160    | 557    | 5710      | 380       | 0.42                | 0.44            | 4.34               | low                 |
| PROVIDER 11 | 65966    | 64485     | 1278   | 0         | 203       | 1.94                | 1.94            | 0.0                | medium              |
| PROVIDER 7  | 39819    | 38263     | 1174   | 147       | 235       | 2.95                | 2.98            | 0.37               | medium              |
| PROVIDER 5  | 24524    | 23820     | 694    | 10        | 0         | 2.83                | 2.83            | 0.04               | medium              |
| PROVIDER 4  | 23426    | 22956     | 451    | 18        | 1         | 1.93                | 1.93            | 0.08               | medium              |
| PROVIDER 9  | 5166     | 4971      | 193    | 0         | 2         | 3.74                | 3.74            | 0.0                | high                |
| PROVIDER 2  | 3396     | 3141      | 254    | 0         | 1         | 7.48                | 7.48            | 0.0                | high                |
| PROVIDER 6  | 268      | 240       | 27     | 0         | 1         | 10.07               | 10.11           | 0.0                | insufficient_volume |
| PROVIDER 10 | 6        | 2         | 0      | 4         | 0         | 0.0                 | 0.0             | 66.67              | insufficient_volume |
| PROVIDER 1  | 3        | 1         | 2      | 0         | 0         | 66.67               | 66.67           | 0.0                | insufficient_volume |
## First observed attempt rates with a terminal denominator
|  provider   | terminal_first_attempts | first_failed_rate_pct |
|-------------|------------------------:|----------------------:|
| PROVIDER 3  | 238250                  | 0.17                  |
| PROVIDER 12 | 195762                  | 1.07                  |
| PROVIDER 8  | 121743                  | 0.31                  |
| PROVIDER 11 | 64916                   | 1.72                  |
| PROVIDER 7  | 38750                   | 2.68                  |
| PROVIDER 5  | 24018                   | 2.54                  |
| PROVIDER 4  | 22978                   | 1.66                  |
| PROVIDER 9  | 5076                    | 3.03                  |
| PROVIDER 2  | 3118                    | 4.43                  |
| PROVIDER 6  | 256                     | 8.98                  |
| PROVIDER 1  | 3                       | 66.67                 |
| PROVIDER 10 | 2                       | 0.0                   |
## Status conflicts and whether another attempt was delivered
| raw_status_lc | payment_status | other_attempt_delivered | payout_outcome | attempts |       usd       |
|---------------|----------------|-------------------------|----------------|---------:|----------------:|
| completed     | SUCCESSFUL     | false                   | not_delivered  | 1        | 402.990000000   |
| completed     | SUCCESSFUL     | true                    | delivered      | 17       | 4159.590000000  |
| created       | SUCCESSFUL     | true                    | delivered      | 3        | 2145.960000000  |
| paid          | REFUNDED       | false                   | not_delivered  | 4        | 2669.040000000  |
| paid          | SUCCESSFUL     | false                   | not_delivered  | 36       | 18123.580010986 |
| paid          | SUCCESSFUL     | true                    | delivered      | 6        | 3155.890000000  |
## Comparable recurring follow-up by first delivered month
| cohort  | users | users_with_full_window | repeat_60_day_pct |
|---------|------:|-----------------------:|------------------:|
| 2026-01 | 48571 | 48571                  | 32.9              |
| 2026-02 | 44553 | 44553                  | 30.0              |
| 2026-03 | 47986 | 47986                  | 28.3              |
| 2026-04 | 44336 | 44336                  | 27.7              |
| 2026-05 | 48911 | 48911                  | 25.6              |
| 2026-06 | 42982 | 42982                  | 26.1              |
| 2026-07 | 42965 | 32618                  | 25.6              |
| 2026-08 | 41814 | 0                      | NULL              |
| 2026-09 | 29126 | 0                      | NULL              |
