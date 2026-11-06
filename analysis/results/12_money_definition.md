## 1.01 Promotion volume and consistency across attempts
| receipts | receipts_with_promo | distinct_promo_values | promo_usd_all_receipts | payments_with_promo | payments_where_promo_varies_by_attempt | payments_where_charged_varies_by_attempt |
|---------:|--------------------:|----------------------:|-----------------------:|--------------------:|---------------------------------------:|-----------------------------------------:|
| 743948   | 13983               | 348                   | 746479.110000          | 13561               | 0                                      | 1                                        |
## 1.02 Most common promotion values (receipt level)
| promotion_amount | receipts | users | pct_of_promo_receipts | cumulative_pct |
|-----------------:|---------:|------:|----------------------:|---------------:|
| 20.000000        | 6704     | 6457  | 47.94                 | 47.9           |
| 5.000000         | 1442     | 1375  | 10.31                 | 58.3           |
| 100.000000       | 1004     | 963   | 7.18                  | 65.4           |
| 10.000000        | 884      | 812   | 6.32                  | 71.8           |
| 40.000000        | 598      | 576   | 4.28                  | 76.0           |
| 30.000000        | 578      | 560   | 4.13                  | 80.2           |
| 150.000000       | 398      | 389   | 2.85                  | 83.0           |
| 50.000000        | 335      | 323   | 2.4                   | 85.4           |
| 250.000000       | 237      | 231   | 1.69                  | 87.1           |
| 60.000000        | 196      | 187   | 1.4                   | 88.5           |
| 200.000000       | 192      | 191   | 1.37                  | 89.9           |
| 300.000000       | 126      | 122   | 0.9                   | 90.8           |
| 600.000000       | 96       | 84    | 0.69                  | 91.5           |
| 80.000000        | 73       | 71    | 0.52                  | 92.0           |
| 350.000000       | 70       | 67    | 0.5                   | 92.5           |
| 400.000000       | 53       | 53    | 0.38                  | 92.9           |
| 25.000000        | 52       | 52    | 0.37                  | 93.2           |
| 500.000000       | 43       | 42    | 0.31                  | 93.5           |
| 450.000000       | 34       | 34    | 0.24                  | 93.8           |
| 3.000000         | 33       | 33    | 0.24                  | 94.0           |
## 1.03 Promotion value quantiles and roundness by class (payment level, first attempt)
|   promo_class    | payments |     promo_q10_50_90_99      | max_promo  | pct_whole_dollar | pct_multiple_of_10 | pct_multiple_of_50 |
|------------------|---------:|-----------------------------|-----------:|-----------------:|-------------------:|-------------------:|
| fully_funded     | 2888     | [20.0, 100.0, 300.0, 600.0] | 600.000000 | 95.7             | 86.3               | 69.9               |
| partial_50_plus  | 849      | [50.0, 100.0, 250.0, 600.0] | 620.000000 | 98.4             | 95.1               | 62.9               |
| partial_under_50 | 9824     | [5.0, 20.0, 30.0, 40.0]     | 49.000000  | 99.3             | 83.1               | 0.0                |
## 1.04 Promotion as a share of value sent, by class (payment level, first attempt)
|   promo_class    | payments | promo_usd | avg_promo | avg_value_sent | avg_promo_pct_of_value_sent | promo_pct_of_class_value_sent |
|------------------|---------:|----------:|----------:|---------------:|----------------------------:|------------------------------:|
| fully_funded     | 2888     | 428898    | 148.51    | 148.51         | 100.0                       | 100.0                         |
| partial_50_plus  | 849      | 116552    | 137.28    | 505.36         | 43.9                        | 27.17                         |
| partial_under_50 | 9824     | 183012    | 18.63     | 456.84         | 13.7                        | 4.08                          |
## 1.05 Promotion classes among delivered remittances: size and user position (primary attempt)
|   promo_class    | delivered_remittances | promo_usd | pct_of_all_promo_usd | pct_first_in_extract | pct_first_or_second |
|------------------|----------------------:|----------:|---------------------:|---------------------:|--------------------:|
| fully_funded     | 2849                  | 424899    | 58.9                 | 42.9                 | 67.9                |
| none             | 707262                | 0         | 0.0                  | 52.4                 | 75.0                |
| partial_50_plus  | 846                   | 115732    | 16.0                 | 53.8                 | 75.5                |
| partial_under_50 | 9673                  | 180444    | 25.0                 | 76.8                 | 92.4                |
## 1.06 Delivered promotions by month and class
|   month    | fully_funded_n | fully_funded_usd | partial_under_50_n | partial_under_50_usd | partial_50_plus_n | partial_50_plus_usd | promo_pct_of_value_sent |
|------------|---------------:|-----------------:|-------------------:|---------------------:|------------------:|--------------------:|------------------------:|
| 2026-01-01 | 143            | 20730            | 1118               | 18159                | 79                | 12799               | 0.313                   |
| 2026-02-01 | 134            | 17513            | 1178               | 22226                | 50                | 5813                | 0.239                   |
| 2026-03-01 | 165            | 23020            | 1189               | 22708                | 56                | 6365                | 0.213                   |
| 2026-04-01 | 180            | 24747            | 1039               | 19935                | 52                | 7540                | 0.208                   |
| 2026-05-01 | 305            | 41225            | 1223               | 23351                | 114               | 15027               | 0.265                   |
| 2026-06-01 | 364            | 50982            | 907                | 17600                | 108               | 13131               | 0.275                   |
| 2026-07-01 | 454            | 71428            | 1079               | 19744                | 117               | 17856               | 0.34                    |
| 2026-08-01 | 623            | 98329            | 1111               | 20250                | 141               | 18600               | 0.411                   |
| 2026-09-01 | 481            | 76923            | 829                | 16471                | 129               | 18601               | 0.458                   |
## 1.07 Partial promotions: tier by month (first attempt, promotion above 0 and amount_charged above 0; tiers with 50 or more payments)
|   promo    | jan | feb | mar | apr | may | jun | jul | aug | sep | total | pct_first_in_extract |
|-----------:|----:|----:|----:|----:|----:|----:|----:|----:|----:|------:|---------------------:|
| 20.000000  | 659 | 851 | 878 | 796 | 932 | 694 | 653 | 508 | 385 | 6356  | 73.9                 |
| 5.000000   | 299 | 153 | 137 | 82  | 103 | 74  | 194 | 227 | 104 | 1373  | 88.4                 |
| 10.000000  | 84  | 71  | 66  | 101 | 96  | 53  | 76  | 110 | 96  | 753   | 93.8                 |
| 40.000000  | 65  | 84  | 87  | 64  | 68  | 55  | 49  | 40  | 23  | 535   | 83.9                 |
| 30.000000  | 0   | 3   | 2   | 1   | 2   | 14  | 97  | 200 | 201 | 520   | 60.0                 |
| 100.000000 | 9   | 6   | 7   | 13  | 27  | 33  | 33  | 52  | 37  | 217   | 42.4                 |
| 60.000000  | 23  | 20  | 22  | 5   | 26  | 20  | 13  | 13  | 16  | 158   | 81.6                 |
| 50.000000  | 5   | 3   | 3   | 7   | 8   | 15  | 12  | 21  | 21  | 95    | 47.4                 |
| 150.000000 | 3   | 0   | 0   | 2   | 9   | 13  | 14  | 19  | 17  | 77    | 39.0                 |
| 80.000000  | 8   | 4   | 7   | 6   | 10  | 8   | 7   | 3   | 2   | 55    | 78.2                 |
## 1.08 Fully funded promotions: value tiers by month
|   promo    | jan_to_apr | may_jun | jul_aug | sep | total |
|-----------:|-----------:|--------:|--------:|----:|------:|
| 100.000000 | 103        | 209     | 319     | 127 | 758   |
| 150.000000 | 27         | 72      | 154     | 62  | 315   |
| 50.000000  | 40         | 61      | 86      | 43  | 230   |
| 250.000000 | 36         | 35      | 80      | 38  | 189   |
| 20.000000  | 87         | 38      | 42      | 13  | 180   |
| 200.000000 | 59         | 30      | 52      | 18  | 159   |
| 300.000000 | 33         | 25      | 38      | 16  | 112   |
| 600.000000 | 11         | 15      | 30      | 13  | 69    |
| 10.000000  | 30         | 13      | 15      | 4   | 62    |
| 350.000000 | 14         | 14      | 17      | 15  | 60    |
| 40.000000  | 16         | 15      | 10      | 2   | 43    |
| 30.000000  | 8          | 3       | 13      | 17  | 41    |
| 400.000000 | 7          | 4       | 23      | 5   | 39    |
| 500.000000 | 6          | 3       | 16      | 12  | 37    |
| 60.000000  | 6          | 8       | 12      | 5   | 31    |
## 1.09 Promotion incidence by corridor (delivered remittances)
| country | delivered | with_promo | pct_with_promo | fully_funded | pct_fully_funded | promo_usd |
|---------|----------:|-----------:|---------------:|-------------:|-----------------:|----------:|
| MX      | 498327    | 7454       | 1.5            | 1918         | 0.38             | 475352    |
| GT      | 83836     | 1488       | 1.77           | 198          | 0.24             | 66330     |
| HN      | 60426     | 1455       | 2.41           | 340          | 0.56             | 87328     |
| CO      | 45297     | 1161       | 2.56           | 217          | 0.48             | 50512     |
| SV      | 15460     | 1003       | 6.49           | 83           | 0.54             | 22593     |
| NI      | 12094     | 528        | 4.37           | 60           | 0.5              | 12177     |
| DO      | 2324      | 106        | 4.56           | 15           | 0.65             | 3680      |
| EC      | 1777      | 149        | 8.38           | 15           | 0.84             | 2304      |
| PE      | 920       | 14         | 1.52           | 3            | 0.33             | 624       |
| BR      | 99        | 7          | 7.07           | 0            | 0.0              | 150       |
| CR      | 70        | 3          | 4.29           | 0            | 0.0              | 25        |
## 1.10 Promotion incidence by payment type (delivered remittances)
|   ptype    | delivered | with_promo | pct_with_promo | fully_funded |
|------------|----------:|-----------:|---------------:|-------------:|
| CARD       | 712605    | 13130      | 1.84           | 2779         |
| APPLE_PAY  | 7263      | 215        | 2.96           | 68           |
| CASH       | 607       | 17         | 2.8            | 0            |
| WALLET_POC | 96        | 4          | 4.17           | 2            |
| ACH        | 59        | 2          | 3.39           | 0            |
## 1.11 Promotion and fee (first attempt, all payments)
|   promo_class    | payments | avg_fee | pct_fee_zero | pct_payment_equals_charged_plus_fee | pct_promo_equals_fee |
|------------------|---------:|--------:|-------------:|------------------------------------:|---------------------:|
| fully_funded     | 2888     | 3.85    | 3.9          | 99.65                               | 0.0                  |
| none             | 714666   | 4.01    | 5.6          | 99.82                               | 0.0                  |
| partial_50_plus  | 849      | 4.37    | 2.7          | 99.29                               | 0.0                  |
| partial_under_50 | 9824     | 4.51    | 8.8          | 99.56                               | 0.0                  |
## 1.12 Fully funded receipts: what payments.amount equals
| fully_funded_receipts | payments | payment_amount_equals_receipt_fee | payment_amount_zero | receipt_fee_zero | payment_amount_not_equal_fee |
|----------------------:|---------:|----------------------------------:|--------------------:|-----------------:|-----------------------------:|
| 2953                  | 2888     | 2942                              | 113                 | 122              | 11                           |
## 1.13 Fully funded receipts where payment amount differs from the receipt fee
|   status   | attempt_number | attempt_status | receipt_fee | payment_amount |  gap  |
|------------|---------------:|----------------|------------:|---------------:|------:|
| SUCCESSFUL | 1              | delivered      | 2.460000    | 1.230000000    | -1.23 |
| SUCCESSFUL | 1              | delivered      | 6.090000    | 5.090000000    | -1.00 |
| SUCCESSFUL | 1              | delivered      | 0.000000    | 2.990000000    | 2.99  |
| SUCCESSFUL | 1              | delivered      | 0.000000    | 2.990000000    | 2.99  |
| SUCCESSFUL | 1              | delivered      | 0.000000    | 2.990000000    | 2.99  |
| SUCCESSFUL | 1              | delivered      | 0.000000    | 2.990000000    | 2.99  |
| SUCCESSFUL | 1              | delivered      | 0.000000    | 2.990000000    | 2.99  |
| SUCCESSFUL | 1              | delivered      | 0.000000    | 2.990000000    | 2.99  |
| SUCCESSFUL | 1              | delivered      | 0.000000    | 2.990000000    | 2.99  |
| SUCCESSFUL | 2              | delivered      | 0.000000    | 4.980000000    | 4.98  |
| SUCCESSFUL | 1              | delivered      | 0.000000    | 6.490000000    | 6.49  |
## 1.14 Fully funded: value sent against ordinary sends up to $600
|        grp         |   n    |               value_q                | max_value_sent | pct_whole_dollar | pct_exactly_100 | pct_exactly_150 | pct_exactly_500 | pct_exactly_600 |
|--------------------|-------:|--------------------------------------|---------------:|-----------------:|----------------:|----------------:|----------------:|----------------:|
| fully_funded       | 2849   | [20.0, 50.0, 100.0, 200.0, 300.0]    | 600.000000     | 95.8             | 26.4            | 11.0            | 1.3             | 2.4             |
| no_promo_up_to_600 | 601084 | [30.0, 57.14, 117.1, 250.0, 420.777] | 600.000000     | 82.7             | 9.5             | 3.9             | 4.1             | 1.7             |
## 1.15 Ordinary delivered sends above $600
| delivered_without_promo_above_600 | users | max_charged |
|----------------------------------:|------:|------------:|
| 106178                            | 89807 | 3418.800000 |
## 1.16 Fully funded: share of payments that are the user's first in the extract, by month
|   month    | fully_funded_n | fully_funded_pct_first | ordinary_pct_first | partial_promo_pct_first |
|------------|---------------:|-----------------------:|-------------------:|------------------------:|
| 2026-01-01 | 144            | 85.4                   | 87.7               | 93.3                    |
| 2026-02-01 | 136            | 67.6                   | 71.6               | 86.8                    |
| 2026-03-01 | 167            | 61.1                   | 62.0               | 80.2                    |
| 2026-04-01 | 182            | 48.9                   | 55.1               | 76.8                    |
| 2026-05-01 | 306            | 47.4                   | 50.7               | 71.7                    |
| 2026-06-01 | 365            | 38.9                   | 46.1               | 66.5                    |
| 2026-07-01 | 455            | 42.6                   | 42.6               | 68.6                    |
| 2026-08-01 | 623            | 30.8                   | 39.3               | 65.2                    |
| 2026-09-01 | 488            | 31.6                   | 38.0               | 62.3                    |
## 1.17 Fully funded: delivered-sequence position and repeat recipients
|     grp      | delivered | pct_first_delivered | pct_second_delivered | pct_third_or_later |
|--------------|----------:|--------------------:|---------------------:|-------------------:|
| fully_funded | 2849      | 46.5                | 24.2                 | 29.3               |
| none         | 707262    | 54.0                | 22.4                 | 23.6               |
| partial      | 10519     | 76.9                | 15.0                 | 8.1                |
## 1.18 Number of promoted payments per user, by class
|     grp      | promoted_payments | users |
|--------------|------------------:|------:|
| fully_funded | 1                 | 2631  |
| fully_funded | 2                 | 116   |
| fully_funded | 3                 | 7     |
| fully_funded | 4                 | 1     |
| partial      | 1                 | 10267 |
| partial      | 2                 | 195   |
| partial      | 3                 | 4     |
| partial      | 4                 | 1     |
## 1.19 Refund-credit test A: earlier problem payments of the same user, by promotion class
|       grp        | payments | pct_with_any_prior | pct_prior_refund | pct_prior_failed_card | pct_prior_chargeback | pct_prior_successful_but_undelivered |
|------------------|---------:|-------------------:|-----------------:|----------------------:|---------------------:|-------------------------------------:|
| fully_funded     | 2866     | 57.0               | 0.66             | 7.57                  | 0.035                | 1.43                                 |
| no_receipt       | 1961     | 68.0               | 0.97             | 11.22                 | 0.0                  | 6.02                                 |
| none             | 708683   | 47.7               | 0.64             | 4.79                  | 0.011                | 0.09                                 |
| partial_50_plus  | 847      | 46.2               | 0.24             | 7.56                  | 0.0                  | 0.59                                 |
| partial_under_50 | 9695     | 23.2               | 0.27             | 2.71                  | 0.0                  | 0.11                                 |
## 1.20 Refund-credit test A restricted to users with at least one earlier payment
|       grp        | payments | pct_prior_refund | pct_prior_failed_card | pct_prior_successful_but_undelivered |
|------------------|---------:|-----------------:|----------------------:|-------------------------------------:|
| fully_funded     | 1633     | 1.16             | 13.29                 | 2.51                                 |
| no_receipt       | 1333     | 1.43             | 16.5                  | 8.85                                 |
| none             | 337716   | 1.35             | 10.05                 | 0.18                                 |
| partial_50_plus  | 391      | 0.51             | 16.37                 | 1.28                                 |
| partial_under_50 | 2248     | 1.16             | 11.7                  | 0.49                                 |
## 1.21 Refund-credit test B: earlier payment with the same amount as the promotion
|              grp              | payments | with_prior_refund | prior_refund_same_amount | prior_problem_same_amount | prior_any_same_amount |
|-------------------------------|---------:|------------------:|-------------------------:|--------------------------:|----------------------:|
| fully_funded                  | 2888     | 19                | 1                        | 15                        | 170                   |
| ordinary_up_to_600_from_march | 503654   | 3906              | 184                      | 2015                      | 30142                 |
## 1.22 Refund-credit test C: does a promotion follow a refunded or failed payout?
|  sstatus   |        sout        | source_payments | pct_any_promo_after | pct_fully_funded_after | promo_equals_amount_n |
|------------|--------------------|----------------:|--------------------:|-----------------------:|----------------------:|
| SUCCESSFUL | delivered          | 450196          | 2.35                | 1.07                   | 215                   |
| REFUNDED   | not_delivered      | 6106            | 2.18                | 0.8                    | 3                     |
| SUCCESSFUL | in_flight          | 1276            | 5.56                | 2.22                   | 0                     |
| SUCCESSFUL | not_delivered      | 182             | 1.96                | 0.0                    | 0                     |
| SUCCESSFUL | multiple_delivered | 17              | 0.0                 | 0.0                    | 0                     |
## 1.23 Beneficiary side: destination amount against charged and promotion
|     grp      | attempt_status | receipts | ties_charged_plus_promo | ties_charged_only | provider_amount_ties_charged_plus_promo |
|--------------|----------------|---------:|------------------------:|------------------:|----------------------------------------:|
| fully_funded | cancelled      | 51       | 51                      | 0                 | 51                                      |
| fully_funded | delivered      | 2849     | 2849                    | 0                 | 2849                                    |
| fully_funded | failed         | 44       | 44                      | 0                 | 44                                      |
| fully_funded | in_flight      | 8        | 8                       | 0                 | 8                                       |
| fully_funded | missing        | 1        | 1                       | 0                 | 0                                       |
| partial      | cancelled      | 311      | 310                     | 33                | 310                                     |
| partial      | delivered      | 10520    | 10520                   | 614               | 10520                                   |
| partial      | failed         | 177      | 177                     | 15                | 166                                     |
| partial      | in_flight      | 21       | 21                      | 3                 | 21                                      |
| partial      | missing        | 1        | 1                       | 0                 | 0                                       |
## 1.24 Beneficiary side: the one partial promotion that does not tie
| country | currency | amount_charged | promotion_amount | exchange_rate | destination_amount | attempt_status |
|---------|----------|---------------:|-----------------:|--------------:|-------------------:|----------------|
| HN      | HNL      | 150.000000     | 20.000000        | 16.86000000   | 4499.900000        | cancelled      |
## 1.25 Refund, chargeback and first-attempt failure rates by promotion class
|   promo_class    | payments | refund_pct | chargeback_pct | first_attempt_failed_pct |
|------------------|---------:|-----------:|---------------:|-------------------------:|
| fully_funded     | 2888     | 0.76       | 0.035          | 1.28                     |
| none             | 714663   | 0.84       | 0.072          | 0.86                     |
| partial_50_plus  | 849      | 0.24       | 0.0            | 0.94                     |
| partial_under_50 | 9824     | 1.31       | 0.061          | 1.36                     |
## 1.26 Overlap of fully funded users with the no-receipt payments (Q4 link)
| fully_funded_users | no_receipt_users | both | all_users |
|-------------------:|-----------------:|-----:|----------:|
| 2755               | 1845             | 104  | 421412    |
## 1.27 Fully funded payments preceded by a successful but undelivered payment of the same user
| prior_outcome | fully_funded_payments_with_such_a_prior |
|---------------|----------------------------------------:|
| no_receipt    | 39                                      |
| in_flight     | 2                                       |
## 1.28 Check with raw text tables: fully funded receipts and the payment amount
| fully_funded_receipts | payments | payment_amount_equals_fee |
|----------------------:|---------:|--------------------------:|
| 2953                  | 2888     | 2942                      |
## 2.01 Candidate measures, extract total
| ord |                                           measure                                           | payments |     usd      |
|----:|---------------------------------------------------------------------------------------------|---------:|-------------:|
| 1   | All payment rows (any status)                                                               | 788976   | 268009275.3  |
| 2   | SUCCESSFUL payments, payments.amount                                                        | 724052   | 237730447.41 |
| 3   | Delivered remittances, customer paid (payments.amount)                                      | 720630   | 237075836.92 |
| 4   | Delivered, charged + fee from primary receipt                                               | 720630   | 237072866.31 |
| 5   | Delivered, value sent (charged + promotion)                                                 | 720630   | 234902590.08 |
| 6   | Delivered, cash principal (charged only, no fee, no promotion)                              | 720630   | 234181515.36 |
| 7   | Delivered, value sent + fee (gross of promotion)                                            | 720630   | 237793941.03 |
| 8   | Delivered, beneficiary side: destination amount / rate (USD-equivalent)                     | 720630   | 234903713.29 |
| 9   | Receipt-level join, SUCCESSFUL payments x receipts, payments.amount (double counts retries) | 736473   | 244268337.89 |
## 2.02 Composition of the gap between customer paid and value sent
| customer_paid |  value_sent  | paid_minus_sent | receipt_fees | promotions | fees_minus_promotions | paid_minus_receipt_paid |
|--------------:|-------------:|----------------:|-------------:|-----------:|----------------------:|------------------------:|
| 237075836.92  | 234902590.08 | 2173246.84      | 2891350.95   | 721074.72  | 2170276.23            | 2970.61                 |
## 2.03 Monthly measures (UTC payment month), delivered remittances
|   month    | remittances | customer_paid_m | value_sent_m | cash_principal_m | receipt_paid_m | paid_minus_sent_k | paid_over_sent_pct | fee_pct_of_sent | promo_pct_of_sent |
|------------|------------:|----------------:|-------------:|-----------------:|---------------:|------------------:|-------------------:|----------------:|------------------:|
| 2026-01-01 | 54755       | 16.679          | 16.526       | 16.474           | 16.679         | 153.7             | 0.93               | 1.242           | 0.313             |
| 2026-02-01 | 60726       | 19.266          | 19.076       | 19.03            | 19.265         | 189.8             | 0.995              | 1.232           | 0.239             |
| 2026-03-01 | 75052       | 24.754          | 24.508       | 24.456           | 24.753         | 245.7             | 1.003              | 1.213           | 0.213             |
| 2026-04-01 | 77645       | 25.409          | 25.15        | 25.097           | 25.408         | 258.9             | 1.029              | 1.233           | 0.208             |
| 2026-05-01 | 92746       | 30.303          | 30.007       | 29.927           | 30.303         | 296.4             | 0.988              | 1.251           | 0.265             |
| 2026-06-01 | 89289       | 30.038          | 29.756       | 29.674           | 30.038         | 282.5             | 0.949              | 1.223           | 0.275             |
| 2026-07-01 | 96149       | 32.373          | 32.087       | 31.978           | 32.373         | 285.4             | 0.89               | 1.23            | 0.34              |
| 2026-08-01 | 101232      | 33.615          | 33.34        | 33.203           | 33.615         | 274.7             | 0.824              | 1.235           | 0.411             |
| 2026-09-01 | 73036       | 24.64           | 24.454       | 24.342           | 24.64          | 186.0             | 0.76               | 1.218           | 0.458             |
## 2.04 Month-over-month growth under each measure
|   month    | paid_mom_pct | sent_mom_pct | cash_mom_pct | sent_minus_paid_pp |
|------------|-------------:|-------------:|-------------:|-------------------:|
| 2026-01-01 | NULL         | NULL         | NULL         | NULL               |
| 2026-02-01 | 15.51        | 15.43        | 15.52        | -0.074             |
| 2026-03-01 | 28.49        | 28.48        | 28.51        | -0.009             |
| 2026-04-01 | 2.65         | 2.62         | 2.62         | -0.027             |
| 2026-05-01 | 19.26        | 19.31        | 19.24        | 0.049              |
| 2026-06-01 | -0.87        | -0.84        | -0.85        | 0.038              |
| 2026-07-01 | 7.77         | 7.84         | 7.77         | 0.064              |
| 2026-08-01 | 3.84         | 3.9          | 3.83         | 0.068              |
| 2026-09-01 | -26.7        | -26.65       | -26.69       | 0.046              |
## 2.05 Growth from first to last full month (January to August)
| paid_growth_pct | sent_growth_pct |
|----------------:|----------------:|
| 101.54          | 101.75          |
## 2.06 Sensitivity of value sent to the primary-attempt rule
|                basis                |    value_sent    |      fee       |   promotion   |
|-------------------------------------|-----------------:|---------------:|--------------:|
| primary: earliest delivered attempt | 234902590.080000 | 2891350.950000 | 721074.720000 |
| first attempt, any status           | 234902590.070000 | 2891681.420000 | 721074.720000 |
| last delivered attempt              | 234902590.080000 | 2891350.950000 | 721074.720000 |
| highest value over attempts         | 234902590.080000 | NULL           | NULL          |
## 2.07 Payments where the first attempt and the primary attempt give a different value or fee
| delivered_remittances | value_differs | fee_differs | primary_is_a_later_attempt |
|----------------------:|--------------:|------------:|---------------------------:|
| 720630                | 1             | 86          | 12118                      |
## 2.08 Beneficiary-side tie of value sent (USD-equivalent of destination and provider amounts)
| receipt_destination_usd_equiv | provider_amount_usd_equiv |  value_sent  | destination_minus_sent | destination_minus_sent_pct | remittances_in_check |
|------------------------------:|--------------------------:|-------------:|-----------------------:|---------------------------:|---------------------:|
| 234903713.29                  | 234904534.59              | 234902590.08 | 1123.21                | 0.0005                     | 720630               |
## 2.09 Where customer paid does not tie to the primary receipt (rounded to cents)
|                     gap_class                      | remittances | net_gap_usd | pct_with_promo | multi_attempt_payments | primary_not_first_attempt |
|----------------------------------------------------|------------:|------------:|---------------:|-----------------------:|--------------------------:|
| 0 tie                                              | 719743      | -0.26       | 1.85           | 12018                  | 12001                     |
| 1 payment carries a standard fee, receipt fee is 0 | 593         | 2250.63     | 3.54           | 96                     | 95                        |
| 2 receipt fee is 0, other positive gap             | 124         | 890.62      | 7.26           | 11                     | 11                        |
| 3 positive gap, receipt fee above 0                | 24          | 23.82       | 4.17           | 4                      | 4                         |
| 4 receipt fee $1 above payment, SV                 | 139         | -139.00     | 3.6            | 2                      | 2                         |
| 5 other negative gap                               | 7           | -55.20      | 14.29          | 5                      | 5                         |
## 2.10 Non-ties by month
|   month    | remittances | non_ties | positive | minus_one_dollar |
|------------|------------:|---------:|---------:|-----------------:|
| 2026-01-01 | 54755       | 79       | 79       | 0                |
| 2026-02-01 | 60726       | 117      | 117      | 0                |
| 2026-03-01 | 75052       | 111      | 111      | 0                |
| 2026-04-01 | 77645       | 151      | 137      | 14               |
| 2026-05-01 | 92746       | 160      | 137      | 22               |
| 2026-06-01 | 89289       | 114      | 59       | 50               |
| 2026-07-01 | 96149       | 53       | 0        | 53               |
| 2026-08-01 | 101232      | 25       | 24       | 0                |
| 2026-09-01 | 73036       | 77       | 77       | 0                |
## 2.11 Users in the 50% volume group under each measure
| users  | top50_customer_paid | top50_value_sent | top50_cash_principal | in_both_paid_and_sent | only_in_paid_group | only_in_sent_group | paid_cutoff_usd |
|-------:|--------------------:|-----------------:|---------------------:|----------------------:|-------------------:|-------------------:|----------------:|
| 391244 | 59511               | 59100            | 58914                | 58946                 | 565                | 154                | 1188.940000000  |
## 2.12 Top-k overlap between customer-paid and alternative rankings
| top_k | in_both_paid_and_sent | leave_under_value_sent | leave_under_cash_principal |
|------:|----------------------:|-----------------------:|---------------------------:|
| 10    | 10                    | 0                      | 0                          |
| 100   | 99                    | 1                      | 1                          |
| 1000  | 996                   | 4                      | 3                          |
| 10000 | 9953                  | 47                     | 40                         |
| 59511 | 59247                 | 264                    | 209                        |
## 2.13 Rank movement among the top 1,000 customer-paid users
| users | rank_changed | max_shift | shift_q50_q90 |
|------:|-------------:|----------:|---------------|
| 1000  | 899          | 308       | [5.0, 22.0]   |
## 2.14 Profile of users who cross the 50% line only under customer paid
| users | avg_remittances | avg_paid | avg_sent | avg_paid_minus_sent |
|------:|----------------:|---------:|---------:|--------------------:|
| 565   | 4.6             | 1200.0   | 1178.0   | 21.5                |
## 3.01 No-receipt SUCCESSFUL payments by type, detailed status and month
|   type    | detailed_status |   month    | payments |  usd  | users | chargebacks |
|-----------|-----------------|------------|---------:|------:|------:|------------:|
| CARD      | SUCCESSFUL      | 2026-06-01 | 29       | 539   | 29    | 1           |
| CARD      | SUCCESSFUL      | 2026-07-01 | 148      | 2302  | 146   | 0           |
| APPLE_PAY | SUCCESSFUL      | 2026-08-01 | 2        | 2     | 1     | 0           |
| CARD      | SUCCESSFUL      | 2026-08-01 | 731      | 13290 | 712   | 0           |
| CARD      | SUCCESSFUL      | 2026-09-01 | 1051     | 24558 | 1020  | 0           |
## 3.02 Detailed status of regular SUCCESSFUL payments with a receipt
|    type    |          detailed_status           | payments |
|------------|------------------------------------|---------:|
| CARD       | SUCCESSFUL                         | 714020   |
| APPLE_PAY  | SUCCESSFUL                         | 7305     |
| CASH       | SUCCESSFUL                         | 610      |
| WALLET_POC | SUCCESSFUL                         | 97       |
| ACH        | SUCCESSFUL                         | 49       |
| ACH        | PENDING_USER_ACTION_ACH_SETTLEMENT | 10       |
## 3.03 Amount families by month
|   month    | payments |  usd  | one_dollar | six25_family | june_round | other |
|------------|---------:|------:|-----------:|-------------:|-----------:|------:|
| 2026-06-01 | 29       | 539   | 0          | 0            | 29         | 0     |
| 2026-07-01 | 148      | 2302  | 68         | 50           | 0          | 30    |
| 2026-08-01 | 733      | 13292 | 325        | 393          | 0          | 15    |
| 2026-09-01 | 1051     | 24558 | 311        | 730          | 0          | 10    |
## 3.04 Most common amounts
|    amount     | payments | users | first_day  |  last_day  |
|--------------:|---------:|------:|------------|------------|
| 1.000000000   | 704      | 699   | 2026-07-08 | 2026-09-22 |
| 24.750000000  | 549      | 524   | 2026-07-17 | 2026-09-21 |
| 37.250000000  | 276      | 266   | 2026-07-22 | 2026-09-22 |
| 12.250000000  | 153      | 150   | 2026-07-25 | 2026-09-22 |
| 62.250000000  | 85       | 82    | 2026-07-25 | 2026-09-21 |
| 10.000000000  | 32       | 32    | 2026-06-27 | 2026-08-26 |
| 49.750000000  | 28       | 27    | 2026-07-26 | 2026-09-19 |
| 18.500000000  | 26       | 26    | 2026-07-27 | 2026-09-19 |
| 25.000000000  | 25       | 25    | 2026-06-27 | 2026-09-04 |
| 31.000000000  | 22       | 21    | 2026-08-15 | 2026-09-20 |
| 43.500000000  | 18       | 15    | 2026-08-15 | 2026-09-19 |
| 5.000000000   | 7        | 7     | 2026-06-26 | 2026-08-15 |
| 20.000000000  | 5        | 5     | 2026-06-30 | 2026-09-11 |
| 50.000000000  | 5        | 5     | 2026-06-27 | 2026-08-17 |
| 74.750000000  | 4        | 4     | 2026-07-27 | 2026-09-05 |
| 87.250000000  | 3        | 3     | 2026-07-31 | 2026-08-26 |
| 99.750000000  | 3        | 3     | 2026-08-29 | 2026-09-13 |
| 124.750000000 | 2        | 2     | 2026-08-08 | 2026-09-11 |
| 137.250000000 | 2        | 1     | 2026-07-24 | 2026-09-09 |
| 15.000000000  | 1        | 1     | 2026-08-19 | 2026-08-19 |
## 3.05 Index m of the 6.25 x m - 0.25 family
| m  | amount | payments |
|---:|-------:|---------:|
| 2  | 12.25  | 153      |
| 3  | 18.5   | 26       |
| 4  | 24.75  | 549      |
| 5  | 31.0   | 22       |
| 6  | 37.25  | 276      |
| 7  | 43.5   | 18       |
| 8  | 49.75  | 28       |
| 10 | 62.25  | 85       |
| 12 | 74.75  | 4        |
| 14 | 87.25  | 3        |
| 16 | 99.75  | 3        |
| 18 | 112.25 | 1        |
| 20 | 124.75 | 2        |
| 22 | 137.25 | 2        |
| 24 | 149.75 | 1        |
## 3.06 Cents of the amount: no-receipt payments against delivered remittances
|          grp          | cents | payments | pct  |
|-----------------------|------:|---------:|-----:|
| delivered_remittance  | 99    | 378914   | 52.6 |
| delivered_remittance  | 98    | 123453   | 17.1 |
| delivered_remittance  | 49    | 49508    | 6.9  |
| delivered_remittance  | 0     | 39155    | 5.4  |
| delivered_remittance  | 9     | 3775     | 0.5  |
| delivered_remittance  | 54    | 3054     | 0.4  |
| successful_no_receipt | 0     | 802      | 40.9 |
| successful_no_receipt | 75    | 587      | 29.9 |
| successful_no_receipt | 25    | 520      | 26.5 |
| successful_no_receipt | 50    | 44       | 2.2  |
| successful_no_receipt | 99    | 6        | 0.3  |
| successful_no_receipt | 98    | 2        | 0.1  |
## 3.07 No-receipt amounts that look like a remittance (cents not .00 .25 .50 .75)
|          created_at           |     amount     | type | hr_utc | dow | other_payments_within_1_day |
|-------------------------------|---------------:|------|-------:|----:|----------------------------:|
| 2026-09-18 11:59:13.878797+00 | 54.980000000   | CARD | 11     | 5   | 0                           |
| 2026-09-18 11:59:21.347466+00 | 754.980000000  | CARD | 11     | 5   | 0                           |
| 2026-09-18 12:00:16.506113+00 | 262.990000000  | CARD | 12     | 5   | 0                           |
| 2026-09-18 17:02:54.996341+00 | 1002.990000000 | CARD | 17     | 5   | 0                           |
| 2026-09-18 19:02:56.790581+00 | 352.990000000  | CARD | 19     | 5   | 0                           |
| 2026-09-20 03:01:15.388196+00 | 102.990000000  | CARD | 3      | 0   | 0                           |
| 2026-09-21 18:03:10.711728+00 | 32.990000000   | CARD | 18     | 1   | 0                           |
| 2026-09-22 14:07:29.990371+00 | 37.990000000   | CARD | 14     | 2   | 0                           |
## 3.08 Hour of day (UTC) of no-receipt payments against regular delivered remittances in August and September
| hour_utc | pct_six25_family | pct_one_dollar | pct_regular_aug_sep |
|---------:|-----------------:|---------------:|--------------------:|
| 0        | 1.8              | 6.1            | 7.0                 |
| 1        | 2.0              | 5.7            | 6.8                 |
| 2        | 2.2              | 1.6            | 5.9                 |
| 3        | 1.0              | 2.3            | 4.1                 |
| 4        | 1.0              | 2.1            | 2.4                 |
| 5        | 0.2              | 1.1            | 1.3                 |
| 6        | 0.1              | 0.3            | 0.7                 |
| 7        | 0.3              | 0.1            | 0.4                 |
| 8        | 0.2              | 0.3            | 0.3                 |
| 9        | 0.3              | 0.4            | 0.5                 |
| 10       | 0.5              | 0.1            | 1.0                 |
| 11       | 60.1             | 1.0            | 1.7                 |
| 12       | 1.2              | 2.1            | 2.6                 |
| 13       | 1.6              | 5.7            | 3.8                 |
| 14       | 1.9              | 4.8            | 4.7                 |
| 15       | 1.8              | 9.2            | 5.7                 |
| 16       | 3.3              | 8.8            | 6.6                 |
| 17       | 2.4              | 8.8            | 6.8                 |
| 18       | 3.2              | 4.8            | 6.2                 |
| 19       | 3.7              | 7.2            | 6.1                 |
| 20       | 2.9              | 6.7            | 6.1                 |
| 21       | 3.1              | 7.1            | 6.0                 |
| 22       | 3.2              | 6.5            | 6.5                 |
| 23       | 2.2              | 7.0            | 6.7                 |
## 3.09 Day of week of no-receipt payments against regular delivered remittances (0 = Sunday, 6 = Saturday)
| day_of_week | pct_six25_family | pct_one_dollar | pct_regular_aug_sep |
|------------:|-----------------:|---------------:|--------------------:|
| 0           | 7.0              | 13.9           | 16.0                |
| 1           | 6.6              | 15.8           | 13.9                |
| 2           | 2.6              | 9.8            | 11.6                |
| 3           | 2.2              | 11.8           | 10.5                |
| 4           | 5.0              | 12.5           | 11.6                |
| 5           | 10.1             | 18.6           | 16.0                |
| 6           | 66.4             | 17.6           | 20.4                |
## 3.10 Share of each amount family at 11:00 UTC and on Saturdays
| amount_family | payments | at_11_utc | pct_11_utc | on_saturday | pct_saturday | saturday_11_utc |
|---------------|---------:|----------:|-----------:|------------:|-------------:|----------------:|
| june_round    | 29       | 0         | 0.0        | 7           | 24.1         | 0               |
| one_dollar    | 704      | 7         | 1.0        | 124         | 17.6         | 0               |
| other         | 55       | 2         | 3.6        | 12          | 21.8         | 0               |
| six25_family  | 1173     | 705       | 60.1       | 779         | 66.4         | 636             |
## 3.11 Saturday 11:00 UTC batches: charges per Saturday, successes and failures (amount family)
|    day     |  weekday  | successful | failed | refunded | first_time | last_time |
|------------|-----------|-----------:|-------:|---------:|------------|-----------|
| 2026-08-08 | Saturday  | 24         | 14     | 0        | 11:00:26   | 11:01:41  |
| 2026-08-10 | Monday    | 8          | 12     | 0        | 11:00:26   | 11:00:31  |
| 2026-08-15 | Saturday  | 32         | 10     | 0        | 11:00:28   | 11:01:35  |
| 2026-08-17 | Monday    | 4          | 17     | 0        | 11:00:26   | 11:01:19  |
| 2026-08-22 | Saturday  | 65         | 22     | 0        | 11:00:21   | 11:48:37  |
| 2026-08-28 | Friday    | 0          | 21     | 0        | 11:00:29   | 11:00:34  |
| 2026-08-29 | Saturday  | 110        | 30     | 1        | 11:00:26   | 11:20:07  |
| 2026-08-31 | Monday    | 2          | 23     | 0        | 11:00:27   | 11:00:34  |
| 2026-09-02 | Wednesday | 0          | 21     | 0        | 11:00:20   | 11:01:24  |
| 2026-09-04 | Friday    | 9          | 17     | 0        | 11:00:28   | 11:08:58  |
| 2026-09-05 | Saturday  | 127        | 52     | 0        | 11:00:26   | 11:31:02  |
| 2026-09-07 | Monday    | 4          | 43     | 0        | 11:00:26   | 11:00:57  |
| 2026-09-09 | Wednesday | 1          | 38     | 0        | 11:00:36   | 11:01:18  |
| 2026-09-11 | Friday    | 5          | 21     | 0        | 11:00:28   | 11:04:31  |
| 2026-09-12 | Saturday  | 140        | 70     | 0        | 11:00:25   | 11:59:36  |
| 2026-09-14 | Monday    | 4          | 46     | 0        | 11:00:21   | 11:00:51  |
| 2026-09-15 | Tuesday   | 0          | 28     | 0        | 11:00:22   | 11:28:58  |
| 2026-09-16 | Wednesday | 1          | 40     | 0        | 11:00:29   | 11:00:58  |
| 2026-09-18 | Friday    | 6          | 24     | 0        | 11:00:25   | 11:05:00  |
| 2026-09-19 | Saturday  | 132        | 74     | 0        | 11:00:31   | 11:02:55  |
| 2026-09-21 | Monday    | 10         | 54     | 0        | 11:00:26   | 11:00:58  |
| 2026-09-22 | Tuesday   | 1          | 25     | 0        | 11:00:28   | 11:00:32  |
## 3.12 Weekly series by pattern
| week_start | six25_at_11_utc | six25_other_hours | one_dollar | other_amounts |
|------------|----------------:|------------------:|-----------:|--------------:|
| 2026-06-22 | 0               | 0                 | 0          | 13            |
| 2026-06-29 | 0               | 0                 | 0          | 32            |
| 2026-07-06 | 0               | 0                 | 3          | 5             |
| 2026-07-13 | 0               | 1                 | 52         | 7             |
| 2026-07-20 | 0               | 34                | 13         | 2             |
| 2026-07-27 | 7               | 19                | 0          | 0             |
| 2026-08-03 | 24              | 18                | 35         | 0             |
| 2026-08-10 | 42              | 25                | 66         | 6             |
| 2026-08-17 | 72              | 33                | 114        | 8             |
| 2026-08-24 | 113             | 51                | 96         | 1             |
| 2026-08-31 | 138             | 65                | 77         | 1             |
| 2026-09-07 | 152             | 94                | 88         | 1             |
| 2026-09-14 | 146             | 114               | 126        | 6             |
| 2026-09-21 | 11              | 14                | 34         | 2             |
## 3.13 Same amount families among non-successful no-receipt payments, by month
|   month    |   status   | amount_family | payments |
|------------|------------|---------------|---------:|
| 2026-05-01 | FAILED     | one_dollar    | 1        |
| 2026-05-01 | FAILED     | other         | 7346     |
| 2026-05-01 | REFUNDED   | other         | 6        |
| 2026-06-01 | FAILED     | one_dollar    | 2        |
| 2026-06-01 | FAILED     | other         | 7099     |
| 2026-06-01 | FAILED     | six25_family  | 2        |
| 2026-06-01 | REFUNDED   | other         | 6        |
| 2026-06-01 | SUCCESSFUL | other         | 29       |
| 2026-07-01 | FAILED     | one_dollar    | 4        |
| 2026-07-01 | FAILED     | other         | 6879     |
| 2026-07-01 | FAILED     | six25_family  | 30       |
| 2026-07-01 | REFUNDED   | one_dollar    | 1        |
| 2026-07-01 | SUCCESSFUL | one_dollar    | 68       |
| 2026-07-01 | SUCCESSFUL | other         | 30       |
| 2026-07-01 | SUCCESSFUL | six25_family  | 50       |
| 2026-08-01 | FAILED     | one_dollar    | 49       |
| 2026-08-01 | FAILED     | other         | 7125     |
| 2026-08-01 | FAILED     | six25_family  | 278      |
| 2026-08-01 | REFUNDED   | one_dollar    | 6        |
| 2026-08-01 | REFUNDED   | other         | 4        |
| 2026-08-01 | REFUNDED   | six25_family  | 1        |
| 2026-08-01 | SUCCESSFUL | one_dollar    | 325      |
| 2026-08-01 | SUCCESSFUL | other         | 15       |
| 2026-08-01 | SUCCESSFUL | six25_family  | 393      |
| 2026-09-01 | FAILED     | one_dollar    | 56       |
| 2026-09-01 | FAILED     | other         | 5344     |
| 2026-09-01 | FAILED     | six25_family  | 742      |
| 2026-09-01 | REFUNDED   | one_dollar    | 5        |
| 2026-09-01 | REFUNDED   | other         | 3        |
| 2026-09-01 | REFUNDED   | six25_family  | 3        |
| 2026-09-01 | SUCCESSFUL | one_dollar    | 311      |
| 2026-09-01 | SUCCESSFUL | other         | 10       |
| 2026-09-01 | SUCCESSFUL | six25_family  | 730      |
## 3.14 Failure rate by amount family, no-receipt payments from August
| amount_family | failed | successful | refunded | failed_pct |
|---------------|-------:|-----------:|---------:|-----------:|
| one_dollar    | 105    | 636        | 11       | 14.0       |
| other         | 12469  | 25         | 7        | 99.7       |
| six25_family  | 1020   | 1123       | 4        | 47.5       |
## 3.15 Failure reasons since mid-July: share of failed payments by family
| amount_family |            reason            | failed | pct  |
|---------------|------------------------------|-------:|-----:|
| one_dollar    | INSUFFICIENT_FUNDS           | 54     | 72.0 |
| one_dollar    | CARD_INVALID                 | 9      | 12.0 |
| one_dollar    | SUSPECTED_FRAUD_BY_PROCESSOR | 8      | 10.7 |
| one_dollar    | EXPIRED_CARD                 | 3      | 4.0  |
| one_dollar    | STOLEN_CARD                  | 1      | 1.3  |
| other         | INSUFFICIENT_FUNDS           | 7279   | 53.4 |
| other         | SUSPECTED_FRAUD_BY_PROCESSOR | 3187   | 23.4 |
| other         | 3DS_CHALLENGE_FAILED         | 860    | 6.3  |
| other         | INVALID_AMOUNT               | 783    | 5.7  |
| other         | CVV_ERROR                    | 506    | 3.7  |
| other         | EXPIRED_CARD                 | 371    | 2.7  |
| other         | STOLEN_CARD                  | 364    | 2.7  |
| other         | CARD_INVALID                 | 289    | 2.1  |
| six25_family  | INSUFFICIENT_FUNDS           | 804    | 86.8 |
| six25_family  | CARD_INVALID                 | 67     | 7.2  |
| six25_family  | SUSPECTED_FRAUD_BY_PROCESSOR | 40     | 4.3  |
| six25_family  | CVV_ERROR                    | 5      | 0.5  |
| six25_family  | EXPIRED_CARD                 | 5      | 0.5  |
| six25_family  | STOLEN_CARD                  | 4      | 0.4  |
| six25_family  | INVALID_AMOUNT               | 1      | 0.1  |
## 3.16 Chargebacks and refunds since July (no-receipt payments)
| amount_family | successful | successful_with_chargeback | refunded | refund_pct |
|---------------|-----------:|---------------------------:|---------:|-----------:|
| one_dollar    | 704        | 0                          | 12       | 1.68       |
| other         | 55         | 0                          | 7        | 11.29      |
| six25_family  | 1173       | 0                          | 4        | 0.34       |
## 3.17 Baseline refund and chargeback rates on regular remittances with receipts
| successful | chargeback_pct | refund_pct |
|-----------:|---------------:|-----------:|
| 722091     | 0.073          | 0.84       |
## 3.18 Relation to the same user's other payments: windows around the no-receipt payment
|                       relation                       | no_receipt_payments | pct  |
|------------------------------------------------------|--------------------:|-----:|
| other payment of any status within 60 minutes        | 56                  | 2.9  |
| delivered remittance within 60 minutes (either side) | 31                  | 1.6  |
| delivered remittance within 60 minutes before        | 3                   | 0.2  |
| delivered remittance within 60 minutes after         | 28                  | 1.4  |
| any other payment within 24 hours                    | 104                 | 5.3  |
| any other payment within 7 days                      | 294                 | 15.0 |
| delivered remittance at any earlier time             | 1240                | 63.2 |
| delivered remittance at any later time               | 319                 | 16.3 |
| amount equals another payment amount of the user     | 170                 | 8.7  |
| amount equals a receipt fee of the user              | 0                   | 0.0  |
| amount equals a promotion of the user                | 0                   | 0.0  |
| amount equals value sent of a user remittance        | 4                   | 0.2  |
## 3.19 Distance to the user's nearest delivered remittance, by family (days)
| amount_family | hour_group  | payments | pct_user_has_no_other_payment | pct_delivered_before | pct_delivered_after | median_days_since_prev_delivered | median_days_to_next_delivered |
|---------------|-------------|---------:|------------------------------:|---------------------:|--------------------:|---------------------------------:|------------------------------:|
| june_round    | other hours | 29       | 20.7                          | 55.2                 | 48.3                | 30.6                             | 33.1                          |
| one_dollar    | at 11 UTC   | 7        | 14.3                          | 71.4                 | 14.3                | 40.8                             | 13.5                          |
| one_dollar    | other hours | 697      | 25.7                          | 61.4                 | 19.1                | 49.8                             | 9.5                           |
| other         | at 11 UTC   | 2        | 0.0                           | 100.0                | 0.0                 | 89.2                             | NULL                          |
| other         | other hours | 53       | 32.1                          | 52.8                 | 26.4                | 60.6                             | 19.4                          |
| six25_family  | at 11 UTC   | 705      | 24.7                          | 65.4                 | 12.8                | 48.7                             | 11.0                          |
| six25_family  | other hours | 468      | 23.9                          | 64.1                 | 14.3                | 44.4                             | 9.0                           |
## 3.20 Baseline: share of regular successful payments in August and September with an earlier delivered remittance or no earlier payment
| payments | pct_first_in_extract |
|---------:|---------------------:|
| 175492   | 39.0                 |
## 3.21 Repeat frequency: no-receipt successful payments per user
| payments_per_user | users |
|------------------:|------:|
| 1                 | 1737  |
| 2                 | 100   |
| 3                 | 8     |
## 3.22 Gap between a user's consecutive no-receipt successful payments (days)
| gap_days | pairs | same_amount |
|----------|------:|------------:|
| a 0-1    | 13    | 9           |
| b 1-7    | 7     | 2           |
| c 7-14   | 42    | 12          |
| d 14-28  | 31    | 14          |
| e 28+    | 23    | 12          |
## 3.23 Six25-family charges per user since July: all statuses
| users | users_with_more_than_one_event | users_with_two_or_more_successes | users_never_succeeded | users_with_failure_then_or_and_success | users_with_changing_amount |
|------:|-------------------------------:|---------------------------------:|----------------------:|---------------------------------------:|---------------------------:|
| 1836  | 294                            | 49                               | 713                   | 63                                     | 4                          |
## 3.24 Saturday batch users who were also in the previous week's batch
| week_start | users | also_in_previous_week |
|------------|------:|----------------------:|
| 2026-07-27 | 18    | 0                     |
| 2026-08-03 | 41    | 1                     |
| 2026-08-10 | 76    | 2                     |
| 2026-08-17 | 131   | 5                     |
| 2026-08-24 | 197   | 7                     |
| 2026-08-31 | 275   | 9                     |
| 2026-09-07 | 337   | 28                    |
| 2026-09-14 | 360   | 27                    |
| 2026-09-21 | 88    | 11                    |
## 3.25 One-dollar payments: no-receipt against regular remittances with receipts
|           grp           |   month    | payments | refunded |
|-------------------------|------------|---------:|---------:|
| no receipt (any status) | 2026-01-01 | 1        | 0        |
| no receipt (any status) | 2026-02-01 | 1        | 0        |
| no receipt (any status) | 2026-03-01 | 4        | 0        |
| no receipt (any status) | 2026-04-01 | 2        | 0        |
| no receipt (any status) | 2026-05-01 | 1        | 0        |
| no receipt (any status) | 2026-06-01 | 2        | 0        |
| no receipt (any status) | 2026-07-01 | 73       | 1        |
| no receipt (any status) | 2026-08-01 | 380      | 6        |
| no receipt (any status) | 2026-09-01 | 372      | 5        |
| with receipt            | 2026-01-01 | 30       | 6        |
| with receipt            | 2026-02-01 | 26       | 3        |
| with receipt            | 2026-03-01 | 32       | 5        |
| with receipt            | 2026-04-01 | 27       | 5        |
| with receipt            | 2026-05-01 | 21       | 3        |
| with receipt            | 2026-06-01 | 26       | 6        |
| with receipt            | 2026-07-01 | 24       | 7        |
| with receipt            | 2026-08-01 | 21       | 1        |
| with receipt            | 2026-09-01 | 14       | 0        |
## 3.26 Other amounts of the families among regular receipted payments
| amount_family |   status   | payout_outcome | payments | first_day  |  last_day  |
|---------------|------------|----------------|---------:|------------|------------|
| one_dollar    | SUCCESSFUL | delivered      | 179      | 2026-01-02 | 2026-09-22 |
| one_dollar    | REFUNDED   | not_delivered  | 36       | 2026-01-15 | 2026-08-04 |
| one_dollar    | SUCCESSFUL | missing_payout | 2        | 2026-08-05 | 2026-08-05 |
| one_dollar    | SUCCESSFUL | not_delivered  | 2        | 2026-02-24 | 2026-03-16 |
| one_dollar    | SUCCESSFUL | in_flight      | 2        | 2026-08-28 | 2026-09-04 |
| six25_family  | SUCCESSFUL | delivered      | 125      | 2026-01-01 | 2026-09-21 |
| six25_family  | REFUNDED   | not_delivered  | 1        | 2026-05-27 | 2026-05-27 |
## 3.27 Retry cadence: consecutive six25-family events of one user (all statuses, from late July)
| prev_status | status | gap_days | hour_utc | pairs | same_amount |
|-------------|--------|---------:|---------:|------:|------------:|
| FAILED      | FAILED | 2        | 11       | 33    | 33          |
| FAILED      | FAILED | 4        | 11       | 22    | 22          |
| FAILED      | FAILED | 3        | 11       | 15    | 15          |
| FAILED      | FAILED | 14       | 11       | 15    | 15          |
| FAILED      | FAILED | 6        | 11       | 14    | 14          |
| FAILED      | FAILED | 5        | 11       | 13    | 13          |
| FAILED      | FAILED | 8        | 11       | 12    | 12          |
| FAILED      | FAILED | 1        | 11       | 11    | 11          |
| FAILED      | FAILED | 7        | 11       | 10    | 10          |
| FAILED      | FAILED | 12       | 11       | 10    | 10          |
| FAILED      | FAILED | 11       | 11       | 8     | 8           |
| FAILED      | FAILED | 16       | 11       | 8     | 8           |
| FAILED      | FAILED | 17       | 11       | 8     | 8           |
## 3.28 Overlap of no-receipt users with fully funded promotions, by family
| amount_family | payments | pct_user_had_fully_funded_before | pct_user_gets_fully_funded_after |
|---------------|---------:|---------------------------------:|---------------------------------:|
| june_round    | 29       | 3.45                             | 0.0                              |
| one_dollar    | 704      | 2.13                             | 3.98                             |
| other         | 55       | 0.0                              | 0.0                              |
| six25_family  | 1173     | 4.6                              | 1.11                             |
## 3.29 Baseline for 3.28: delivered remittances from August
| payments | pct_user_had_fully_funded_before | pct_user_gets_fully_funded_after |
|---------:|---------------------------------:|---------------------------------:|
| 174268   | 0.5                              | 0.15                             |
## 3.30 Overlap of one-dollar users and six25-family users (no-receipt payments since July, any status)
| six25_users | one_dollar_users | users_in_both | one_dollar_first | six25_first | expected_if_independent |
|------------:|-----------------:|--------------:|-----------------:|------------:|------------------------:|
| 1836        | 815              | 113           | 101              | 12          | 9.9                     |
## 3.31 Remittance context of six25-family users at their first six25 event
| users | with_any_earlier_payment | with_earlier_delivered | delivered_in_prior_7_days | delivered_7_to_35_days_before |
|------:|-------------------------:|-----------------------:|--------------------------:|------------------------------:|
| 1836  | 1246                     | 1159                   | 78                        | 384                           |
## 3.32 Right-censoring: lag from payment creation to first receipt
| successful_with_receipt |   lag_seconds_q50_90_99_999_max    | over_1_hour | over_1_day | receipt_before_payment |
|------------------------:|------------------------------------|------------:|-----------:|-----------------------:|
| 722091                  | [5.7, 12.5, 43.5, 730.2, 509508.2] | 423         | 20         | 0                      |
## 3.33 Right-censoring: no-receipt share of SUCCESSFUL payments by age at extract end (September payments)
| age_days | successful | no_receipt |  pct  | no_receipt_remittance_shaped |
|---------:|-----------:|-----------:|------:|-----------------------------:|
| 0        | 3277       | 42         | 1.282 | 2                            |
| 1        | 3888       | 43         | 1.106 | 0                            |
| 2        | 4335       | 72         | 1.661 | 1                            |
| 3        | 4642       | 180        | 3.878 | 2                            |
| 4        | 3538       | 52         | 1.47  | 3                            |
| 5        | 2865       | 23         | 0.803 | 0                            |
| 6        | 2811       | 11         | 0.391 | 0                            |
| 7        | 3264       | 17         | 0.521 | 0                            |
| 8        | 3719       | 27         | 0.726 | 0                            |
| 9        | 4327       | 37         | 0.855 | 0                            |
| 10       | 4449       | 186        | 4.181 | 0                            |
| 11       | 3473       | 37         | 1.065 | 0                            |
| 12       | 2894       | 14         | 0.484 | 0                            |
| 13       | 2722       | 15         | 0.551 | 0                            |
| 14       | 25068      | 295        | 1.177 | 0                            |
## 3.34 Right-censoring: end of extract
|         last_payment          |         last_receipt          |       last_disbursement       | no_receipt_in_last_12_minutes |
|-------------------------------|-------------------------------|-------------------------------|------------------------------:|
| 2026-09-22 14:07:29.990371+00 | 2026-09-22 14:06:52.517462+00 | 2026-09-22 14:06:54.836733+00 | 2                             |
## 3.35 Age of the oldest weekly-batch charges at extract end
|      first_batch_charge       | age_days_at_extract_end |
|-------------------------------|------------------------:|
| 2026-08-01 11:00:29.018609+00 | 52.1                    |
## 3.36 Other no-receipt payments that are not SUCCESSFUL
|       status        |   type    |          detailed_status          | payments | first_day  |  usd  |
|---------------------|-----------|-----------------------------------|---------:|------------|------:|
| SUCCESSFUL          | CARD      | SUCCESSFUL                        | 1959     | 2026-06-26 | 40688 |
| REFUNDED            | CARD      | SUCCESSFUL                        | 56       | 2026-01-01 | 25603 |
| REFUNDED            | CARD      | (null)                            | 30       | 2026-05-29 | 7981  |
| PENDING_USER_ACTION | CARD      | PENDING_USER_ACTION_3DS_CHALLENGE | 17       | 2026-01-04 | 7039  |
| SUCCESSFUL          | APPLE_PAY | SUCCESSFUL                        | 2        | 2026-08-14 | 2     |
| STARTED             | NULL      | (null)                            | 1        | 2026-07-07 | -1    |
## 3.37 Check with raw text tables: no-receipt SUCCESSFUL payments at 11:00 UTC and on Saturday
| no_receipt_successful | at_11 | on_saturday | exactly_1 | six25_family | six25_saturday_11 |
|----------------------:|------:|------------:|----------:|-------------:|------------------:|
| 1961                  | 714   | 922         | 704       | 1173         | 636               |
