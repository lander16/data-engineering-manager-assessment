## R1 Outcomes under the adopted rule
| adopted_status | attempts |
|----------------|---------:|
| cancelled      | 10931    |
| delivered      | 720658   |
| failed         | 10886    |
| in_flight      | 1288     |
| missing        | 185      |
| delivered_remittances |  customer_paid_usd  |
|----------------------:|--------------------:|
| 720630                | 237075836.916685776 |
## R2 Receipts with no disbursement: null ID against orphan ID
| null_id | orphan_id | null_provider |
|--------:|----------:|--------------:|
| 0       | 185       | 185           |
## R3 Provider rates, classes, and 95% Wilson intervals
|  provider   | terminal_attempts | failed_pct | wilson_low | wilson_high | first_attempt_failed_pct | unsuccessful_terminal_pct |    failure_class    | first_attempt_class | unsuccessful_class  |
|-------------|------------------:|-----------:|-----------:|------------:|-------------------------:|--------------------------:|---------------------|---------------------|---------------------|
| PROVIDER 3  | 243025            | 1.44       | 1.4        | 1.49        | 1.32                     | 1.44                      | medium              | medium              | medium              |
| PROVIDER 12 | 200850            | 1.37       | 1.32       | 1.42        | 1.07                     | 3.78                      | medium              | medium              | high                |
| PROVIDER 8  | 125717            | 0.44       | 0.41       | 0.48        | 0.31                     | 4.77                      | low                 | low                 | high                |
| PROVIDER 11 | 65763             | 1.94       | 1.84       | 2.05        | 1.72                     | 1.94                      | medium              | medium              | medium              |
| PROVIDER 7  | 39437             | 2.98       | 2.81       | 3.15        | 2.68                     | 3.34                      | medium              | medium              | high                |
| PROVIDER 5  | 24514             | 2.83       | 2.63       | 3.05        | 2.54                     | 2.87                      | medium              | medium              | medium              |
| PROVIDER 4  | 23407             | 1.93       | 1.76       | 2.11        | 1.66                     | 2.0                       | medium              | medium              | medium              |
| PROVIDER 9  | 5164              | 3.74       | 3.25       | 4.29        | 3.03                     | 3.74                      | high                | high                | high                |
| PROVIDER 2  | 3395              | 7.48       | 6.64       | 8.42        | 4.43                     | 7.48                      | high                | high                | high                |
| PROVIDER 6  | 267               | 10.11      | 7.04       | 14.31       | 8.98                     | 10.11                     | insufficient_volume | insufficient_volume | insufficient_volume |
| PROVIDER 1  | 3                 | 66.67      | 20.77      | 93.85       | 66.67                    | 66.67                     | insufficient_volume | insufficient_volume | insufficient_volume |
| PROVIDER 10 | 2                 | 0.0        | 0.0        | 65.76       | 0.0                      | 66.67                     | insufficient_volume | insufficient_volume | insufficient_volume |
## R4 CANCELLED with raw PAID or COMPLETED, by what else happened
|  provider   | payment_status | has_delivered_attempt | attempts | payments |       usd       |
|-------------|----------------|-----------------------|---------:|---------:|----------------:|
| PROVIDER 12 | REFUNDED       | false                 | 4        | 4        | 2669.040000000  |
| PROVIDER 12 | SUCCESSFUL     | false                 | 36       | 36       | 18123.580010986 |
| PROVIDER 12 | SUCCESSFUL     | true                  | 6        | 6        | 3155.890000000  |
| PROVIDER 4  | SUCCESSFUL     | false                 | 1        | 1        | 402.990000000   |
| PROVIDER 4  | SUCCESSFUL     | true                  | 17       | 17       | 4159.590000000  |
## R5 Named issues
|           issue           | payments |       usd       |
|---------------------------|---------:|----------------:|
| conflict_likely_delivered | 37       | 18526.570010986 |
| possible_double_payout    | 23       | 7315.480000000  |
## R6 Provider 4 cancelled with raw COMPLETED
| attempts |      usd       | first_day  |  last_day  |
|---------:|---------------:|------------|------------|
| 18       | 4562.580000000 | 2026-01-22 | 2026-01-22 |
## R7 No-receipt successful payments by amount family
|      family      | payments |       usd       |
|------------------|---------:|----------------:|
| scheduled_amount | 1173     | 36019.250000000 |
| one_dollar       | 704      | 704.000000000   |
| other            | 84       | 3966.900000000  |
## R8 User and beneficiary pairs
| all_pairs | first_attempt_pairs | retry_only_pairs | users_with_retry_only_pairs |
|----------:|--------------------:|-----------------:|----------------------------:|
| 554117    | 552019              | 2098             | 2060                        |
## R9 Chargeback rates by maturity lag, settled against card denominators
| lag_label | settled_payments | flagged | count_rate_pct | value_rate_pct | card_payments | card_count_rate_pct |
|-----------|-----------------:|--------:|---------------:|---------------:|--------------:|--------------------:|
| 120 days  | 271182           | 215     | 0.0793         | 0.1037         | 271005        | 0.0793              |
| 90 days   | 364764           | 311     | 0.0853         | 0.1123         | 364500        | 0.0853              |
| 60 days   | 454822           | 387     | 0.0851         | 0.1218         | 454450        | 0.0852              |
| none      | 730271           | 526     | 0.072          | 0.095          | 729501        | 0.0721              |
## R10 Paid, undelivered, and unrefunded payments
| payments |       usd       | flagged | card_like |
|---------:|----------------:|--------:|----------:|
| 182      | 50900.590010986 | 9       | 179       |
## R11 Delivered remittances by payment amount
| amount_sign | remittances | users  |  value_sent_usd  |
|-------------|------------:|-------:|-----------------:|
| positive    | 720533      | 391209 | 234891095.730000 |
| zero        | 97          | 96     | 11494.350000     |
| users_with_only_zero_amount |
|----------------------------:|
| 35                          |
| recurring | recurring_on_positive_amounts |
|----------:|------------------------------:|
| 144758    | 144729                        |
## R12 Payment against primary attempt, by cause
|        cause        | remittances | net_usd |
|---------------------|------------:|--------:|
| ties                | 719743      | 0.00    |
| fee_zero_on_receipt | 717         | 3141.25 |
| receipt_higher      | 146         | -194.20 |
| other               | 24          | 23.90   |
## R13 Disbursement created over a minute before its receipt
| attempts | on_retries | longest_days |
|---------:|-----------:|-------------:|
| 753      | 64         | 69.2         |
| payments_whose_first_attempt_changes |
|-------------------------------------:|
| 3                                    |
## R14 Grain checks for receipt to disbursement
| disbursement_ids_on_several_receipts |
|-------------------------------------:|
| 0                                    |
| disbursements_without_receipt |
|------------------------------:|
| 0                             |
## R15 Monthly senders
| payment_month | active_senders | first_seen_senders | returning_senders | returning_pct |
|---------------|---------------:|-------------------:|------------------:|--------------:|
| 2026-01-01    | 48571          | 48571              | 0                 | 0.0           |
| 2026-02-01    | 53763          | 44553              | 9210              | 17.1          |
| 2026-03-01    | 65735          | 47986              | 17749             | 27.0          |
| 2026-04-01    | 68082          | 44336              | 23746             | 34.9          |
| 2026-05-01    | 80753          | 48911              | 31842             | 39.4          |
| 2026-06-01    | 78247          | 42982              | 35265             | 45.1          |
| 2026-07-01    | 83850          | 42965              | 40885             | 48.8          |
| 2026-08-01    | 87848          | 41814              | 46034             | 52.4          |
| 2026-09-01    | 66207          | 29126              | 37081             | 56.0          |
