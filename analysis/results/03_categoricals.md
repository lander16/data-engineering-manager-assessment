## Payment status and detailed status
|       status        |               detailed_status                |   n    |         usd         |
|---------------------|----------------------------------------------|-------:|--------------------:|
| SUCCESSFUL          | SUCCESSFUL                                   | 724042 | 237726505.766696304 |
| FAILED              | FAILED_DUE_TO_INSUFFICIENT_FUNDS             | 23773  | 7376292.601000000   |
| FAILED              | FAILED_DUE_TO_SUSPECTED_FRAUD_BY_PROCESSOR   | 12962  | 9204030.706755420   |
| FAILED              | FAILED_DUE_TO_3DS_CHALLENGE_FAILED           | 5335   | 3638815.031000000   |
| REFUNDED            | SUCCESSFUL                                   | 3475   | 1526483.694501678   |
| REFUNDED            | NULL                                         | 2744   | 1176467.549990234   |
| FAILED              | FAILED_DUE_TO_CVV_ERROR                      | 2388   | 747970.780000000    |
| FAILED              | FAILED_DUE_TO_BANK_REJECTION                 | 2386   | 983833.140000000    |
| FAILED              | FAILED_DUE_TO_REJECTION_BY_PROVIDER          | 2150   | 835557.230000000    |
| FAILED              | FAILED_DUE_TO_PROVIDER_ERROR                 | 1670   | 549580.140000000    |
| FAILED              | FAILED_DUE_TO_EXPIRED_CARD                   | 1411   | 630348.860000000    |
| FAILED              | FAILED_DUE_TO_INVALID_AMOUNT                 | 1374   | 1493644.270000000   |
| FAILED              | FAILED_DUE_TO_STOLEN_CARD                    | 1225   | 462367.947100000    |
| FAILED              | FAILED_DUE_TO_CARD_INVALID                   | 1025   | 336940.790000000    |
| FAILED              | FAILED_DUE_TO_UNMAPPED_REASON                | 986    | 617002.490000000    |
| FAILED              | FAILED_DUE_TO_REPORTED_LOST                  | 945    | 318809.150000000    |
| FAILED              | FAILED_DUE_TO_CASH_CODE_EXPIRE               | 531    | 125833.699339099    |
| FAILED              | FAILED_DUE_TO_INVALID_TRANSACTION            | 436    | 202034.610000000    |
| FAILED              | FAILED_DUE_TO_INVALID_MERCHANT               | 23     | 6152.500000000      |
| FAILED              | FAILED_DUE_TO_EARLY_INSUFFICIENT_FUNDS_CHECK | 22     | 16860.590000000     |
| PENDING_USER_ACTION | PENDING_USER_ACTION_3DS_CHALLENGE            | 17     | 7039.400000000      |
| FAILED              | FAILED_DUE_TO_TERMINAL_ERROR                 | 13     | 9301.600000000      |
| FAILED              | FAILED_DUE_TO_EXTERNAL_CALL_FAILURE          | 12     | 6300.870000000      |
| SUCCESSFUL          | PENDING_USER_ACTION_ACH_SETTLEMENT           | 10     | 3941.640000000      |
| FAILED              | FAILED_TRANSACTION_EXPIRED_BY_PROVIDER       | 10     | 2498.160000000      |
| FAILED              | FAILED_DUE_TO_BALANCE_STALE                  | 7      | 3044.990000000      |
| FAILED              | FAILED_DUE_TO_BALANCE_NOT_PRESENT            | 2      | 1515.000000000      |
| STARTED             | NULL                                         | 1      | -0.900000000        |
| FAILED              | PENDING_USER_ACTION_3DS_CHALLENGE            | 1      | 102.989997864       |
## Payment type by status
|    type    |       status        |   n    |
|------------|---------------------|-------:|
| ACH        | SUCCESSFUL          | 59     |
| ACH        | FAILED              | 33     |
| ACH        | REFUNDED            | 1      |
| APPLE_PAY  | SUCCESSFUL          | 7307   |
| APPLE_PAY  | FAILED              | 843    |
| APPLE_PAY  | REFUNDED            | 61     |
| CARD       | SUCCESSFUL          | 715979 |
| CARD       | FAILED              | 57250  |
| CARD       | REFUNDED            | 6154   |
| CARD       | PENDING_USER_ACTION | 17     |
| CASH       | SUCCESSFUL          | 610    |
| CASH       | FAILED              | 532    |
| CASH       | REFUNDED            | 3      |
| WALLET_POC | SUCCESSFUL          | 97     |
| WALLET_POC | FAILED              | 29     |
| NULL       | STARTED             | 1      |
## Payment currency
| currency |   n    |
|----------|-------:|
| USD      | 788976 |
## Chargeback flag values
| has_dispute_chargeback |   n    |
|------------------------|-------:|
| True                   | 526    |
| False                  | 788450 |
## total_intents by payment type
|    type    | total_intents |   n    |
|------------|---------------|-------:|
| CARD       | NULL          | 762797 |
| CARD       | 1             | 16603  |
| APPLE_PAY  | NULL          | 8211   |
| CASH       | NULL          | 1145   |
| WALLET_POC | NULL          | 126    |
| ACH        | 1             | 49     |
| ACH        | NULL          | 44     |
| NULL       | NULL          | 1      |
## total_intents by month
|  month  | populated | rows_  |
|---------|----------:|-------:|
| 2026-01 | 804       | 60832  |
| 2026-02 | 1127      | 66792  |
| 2026-03 | 1796      | 82430  |
| 2026-04 | 3008      | 84869  |
| 2026-05 | 1986      | 100931 |
| 2026-06 | 2206      | 97163  |
| 2026-07 | 2306      | 103957 |
| 2026-08 | 1915      | 110189 |
| 2026-09 | 1504      | 81813  |
## Disbursement status, raw status, and provider status
|            status            |          raw_status          |               provider_status               |   n    |
|------------------------------|------------------------------|---------------------------------------------|-------:|
| PAID                         | PAID                         | NULL                                        | 297971 |
| Success                      | complete                     | NULL                                        | 239520 |
| COMPLETED                    | COMPLETED                    | completed                                   | 66190  |
| COMPLETED                    | COMPLETED                    | PAYMENT_HAS_BEEN_COMPLETED                  | 64485  |
| COMPLETED                    | COMPLETED                    | 00000000                                    | 24686  |
| COMPLETED                    | COMPLETED                    | NULL                                        | 23817  |
| CANCELLED                    | CANCELLED                    | NULL                                        | 10717  |
| COMPLETED                    | COMPLETED                    | COMPLETED                                   | 3381   |
| Failed                       | cancelled                    | NULL                                        | 3070   |
| FAILED                       | FAILED                       | NULL                                        | 2812   |
| FAILED                       | FAILED                       | 00000000                                    | 892    |
| FAILED                       | FAILED                       | refunded                                    | 692    |
| REJECTED                     | REJECTED                     | NULL                                        | 686    |
| REJECTED                     | REJECTED                     | TRANSFER_HAS_BEEN_REJECTED                  | 633    |
| COMPLETED                    | COMPLETED                    | HOLD:11102002                               | 604    |
| REJECTED                     | REJECTED                     | rejected                                    | 455    |
| FAILED                       | FAILED                       | TRANSFER_HAS_BEEN_CANCELED                  | 380    |
| WIRE_RELEASED                | WIRE_RELEASED                | NULL                                        | 373    |
| IN_PROGRESS                  | IN_PROGRESS                  | 00000000                                    | 304    |
| Failed                       | failed                       | NULL                                        | 300    |
| PAYABLE                      | IN_PROGRESS                  | availableForPickup                          | 231    |
| PAYABLE                      | IN_PROGRESS                  | TRANSFER_SENT_TO_PAYER                      | 203    |
| FAILED                       | FAILED                       | REFUNDED                                    | 181    |
| FAILED                       | FAILED                       | TRANSFER_REQUEST_HAS_BEEN_CANCELLED         | 178    |
| CANCELLED                    | CANCELLED                    | CANCELLED                                   | 147    |
| FAILED                       | FAILED                       | HOLD:11102002                               | 143    |
| Failed                       | Failed                       | NULL                                        | 135    |
| TRANSMITTED                  | TRANSMITTED                  | NULL                                        | 109    |
| FAILED                       | FAILED                       | rejected                                    | 95     |
| FAILED                       | FAILED                       | failed                                      | 47     |
| CANCELLED                    | PAID                         | NULL                                        | 46     |
| FAILED                       | FAILED                       | TRANSFER_REQUEST_HAS_EXPIRED                | 43     |
| FAILED                       | FAILED                       | FAILED                                      | 42     |
| FAILED                       | FAILED                       | CANCELLED                                   | 23     |
| FAILED                       | FAILED                       | TRANSMITTER_PAYER_COMBINATION_NOT_PERMITTED | 21     |
| REJECTED                     | REJECTED                     | REFUNDED                                    | 19     |
| CANCELLED                    | COMPLETED                    | completed                                   | 18     |
| Pending                      | processing                   | NULL                                        | 13     |
| ON_HOLD                      | ON_HOLD                      | HOLD:11102002                               | 11     |
| FAILED                       | FAILED                       | 503                                         | 10     |
| Pending                      | pending                      | NULL                                        | 8      |
| FAILED                       | FAILED                       | 11102001                                    | 7      |
| IN_PROGRESS                  | IN_PROGRESS                  | HOLD:11102002                               | 6      |
| ERROR_SENDING_PAYOUT_REQUEST | ERROR_SENDING_PAYOUT_REQUEST | NULL                                        | 5      |
| PAYABLE                      | PAYABLE                      | NULL                                        | 5      |
| FAILED                       | FAILED                       | CLAIM_CODE_DOES_NOT_MATCH                   | 4      |
| FAILED                       | FAILED                       | GENERAL_PROCESSING_ERROR                    | 4      |
| FAILED                       | FAILED                       | PROVIDER_UNAVAILABLE_OR_CLIENT_ERROR        | 4      |
| DELIVERED                    | DELIVERED                    | NULL                                        | 3      |
| CANCELLATION_IN_PROGRESS     | CANCELLATION_IN_PROGRESS     | 00000000                                    | 3      |
| PAYOUT_NOT_PROCESSED         | PAYOUT_NOT_PROCESSED         | NULL                                        | 3      |
| CANCELLED                    | CREATED                      | NULL                                        | 3      |
| HOLD_BY_PAYER                | HOLD_BY_PAYER                | NULL                                        | 3      |
| HOLD_BY_COMPLIANCE           | ON_HOLD                      | inReview                                    | 3      |
| TO_BE_PROCESSED              | TO_BE_PROCESSED              | NULL                                        | 2      |
| IN_PROGRESS                  | IN_PROGRESS                  | in_progress                                 | 2      |
| HOLD_BY_COMPLIANCE           | HOLD_BY_COMPLIANCE           | NULL                                        | 2      |
| Pending                      | Pending                      | NULL                                        | 2      |
| WIRE_CONFIRMED               | WIRE_CONFIRMED               | NULL                                        | 2      |
| IN_PROGRESS                  | IN_PROGRESS                  | processing                                  | 1      |
| FAILED                       | FAILED                       | GENERAL_SYSTEM_ERROR                        | 1      |
| TO_BE_PROCESSED              | TO_BE_PROCESSED              | 00000000                                    | 1      |
| IN_PROGRESS                  | IN_PROGRESS                  | PROCESSING                                  | 1      |
| CANCELLATION_IN_PROGRESS     | CANCELLATION_IN_PROGRESS     | HOLD:11102002                               | 1      |
| FAILED                       | FAILED                       | HOLD:11102012                               | 1      |
| COMPLETED                    | COMPLETED                    | CONFIRM                                     | 1      |
| IN_PROGRESS                  | IN_PROGRESS                  | IN_PROGRESS                                 | 1      |
| IN_PROGRESS                  | IN_PROGRESS                  | inProcess                                   | 1      |
## Status vocabulary by provider
| disbursement_provider |            status            |   n    |
|-----------------------|------------------------------|-------:|
| PROVIDER 1            | FAILED                       | 2      |
| PROVIDER 1            | COMPLETED                    | 1      |
| PROVIDER 10           | CANCELLED                    | 4      |
| PROVIDER 10           | PAID                         | 2      |
| PROVIDER 11           | COMPLETED                    | 64485  |
| PROVIDER 11           | FAILED                       | 645    |
| PROVIDER 11           | REJECTED                     | 633    |
| PROVIDER 11           | PAYABLE                      | 203    |
| PROVIDER 12           | PAID                         | 172809 |
| PROVIDER 12           | COMPLETED                    | 25290  |
| PROVIDER 12           | CANCELLED                    | 5042   |
| PROVIDER 12           | FAILED                       | 2751   |
| PROVIDER 12           | IN_PROGRESS                  | 310    |
| PROVIDER 12           | TRANSMITTED                  | 109    |
| PROVIDER 12           | ON_HOLD                      | 11     |
| PROVIDER 12           | PAYABLE                      | 5      |
| PROVIDER 12           | CANCELLATION_IN_PROGRESS     | 4      |
| PROVIDER 12           | TO_BE_PROCESSED              | 3      |
| PROVIDER 2            | COMPLETED                    | 3141   |
| PROVIDER 2            | FAILED                       | 235    |
| PROVIDER 2            | REJECTED                     | 19     |
| PROVIDER 2            | IN_PROGRESS                  | 1      |
| PROVIDER 3            | Success                      | 239520 |
| PROVIDER 3            | Failed                       | 3505   |
| PROVIDER 3            | Pending                      | 23     |
| PROVIDER 4            | COMPLETED                    | 22956  |
| PROVIDER 4            | REJECTED                     | 267    |
| PROVIDER 4            | FAILED                       | 184    |
| PROVIDER 4            | CANCELLED                    | 18     |
| PROVIDER 4            | IN_PROGRESS                  | 1      |
| PROVIDER 5            | COMPLETED                    | 23817  |
| PROVIDER 5            | REJECTED                     | 686    |
| PROVIDER 5            | CANCELLED                    | 10     |
| PROVIDER 5            | ERROR_SENDING_PAYOUT_REQUEST | 5      |
| PROVIDER 5            | PAYOUT_NOT_PROCESSED         | 3      |
| PROVIDER 5            | DELIVERED                    | 3      |
| PROVIDER 6            | COMPLETED                    | 240    |
| PROVIDER 6            | FAILED                       | 27     |
| PROVIDER 6            | IN_PROGRESS                  | 1      |
| PROVIDER 7            | COMPLETED                    | 38263  |
| PROVIDER 7            | FAILED                       | 1174   |
| PROVIDER 7            | PAYABLE                      | 231    |
| PROVIDER 7            | CANCELLED                    | 147    |
| PROVIDER 7            | HOLD_BY_COMPLIANCE           | 3      |
| PROVIDER 7            | IN_PROGRESS                  | 1      |
| PROVIDER 8            | PAID                         | 125160 |
| PROVIDER 8            | CANCELLED                    | 5710   |
| PROVIDER 8            | FAILED                       | 557    |
| PROVIDER 8            | WIRE_RELEASED                | 373    |
| PROVIDER 8            | HOLD_BY_PAYER                | 3      |
| PROVIDER 8            | HOLD_BY_COMPLIANCE           | 2      |
| PROVIDER 8            | WIRE_CONFIRMED               | 2      |
| PROVIDER 9            | COMPLETED                    | 4971   |
| PROVIDER 9            | REJECTED                     | 188    |
| PROVIDER 9            | FAILED                       | 5      |
| PROVIDER 9            | IN_PROGRESS                  | 2      |
## Normalized status and raw status disagreements
| disbursement_provider |       status       | raw_status  |   n    |
|-----------------------|--------------------|-------------|-------:|
| PROVIDER 3            | Success            | complete    | 239520 |
| PROVIDER 3            | Failed             | cancelled   | 3070   |
| PROVIDER 7            | PAYABLE            | IN_PROGRESS | 231    |
| PROVIDER 11           | PAYABLE            | IN_PROGRESS | 203    |
| PROVIDER 12           | CANCELLED          | PAID        | 46     |
| PROVIDER 4            | CANCELLED          | COMPLETED   | 18     |
| PROVIDER 3            | Pending            | processing  | 13     |
| PROVIDER 7            | HOLD_BY_COMPLIANCE | ON_HOLD     | 3      |
| PROVIDER 8            | CANCELLED          | CREATED     | 3      |
## Payout type
|     type      |   n    |
|---------------|-------:|
| BANK          | 511657 |
| CASH          | 211955 |
| WALLET        | 20121  |
| CASH DELIVERY | 30     |
## Country and currency: disbursements
| destination_country | destination_currency |   n    |
|---------------------|----------------------|-------:|
| MX                  | MXN                  | 510549 |
| GT                  | GTQ                  | 87160  |
| HN                  | HNL                  | 63724  |
| CO                  | COP                  | 47374  |
| SV                  | USD                  | 16167  |
| NI                  | USD                  | 12939  |
| DO                  | DOP                  | 2003   |
| EC                  | USD                  | 1976   |
| PE                  | PEN                  | 835    |
| DO                  | USD                  | 498    |
| PE                  | USD                  | 207    |
| NULL                | NULL                 | 137    |
| BR                  | BRL                  | 104    |
| CR                  | CRC                  | 41     |
| COSTA RICA          | USD                  | 25     |
| CR                  | USD                  | 21     |
| MX                  | GTQ                  | 3      |
## Country and currency: receipts
| destination_country_code | destination_currency |   n    |
|--------------------------|----------------------|-------:|
| MX                       | MXN                  | 510773 |
| GT                       | GTQ                  | 87189  |
| HN                       | HNL                  | 63740  |
| CO                       | COP                  | 47411  |
| SV                       | USD                  | 16177  |
| NI                       | USD                  | 12939  |
| DO                       | DOP                  | 2005   |
| EC                       | USD                  | 1976   |
| PE                       | PEN                  | 836    |
| DO                       | USD                  | 500    |
| PE                       | USD                  | 206    |
| BR                       | BRL                  | 106    |
| CR                       | USD                  | 46     |
| CR                       | CRC                  | 41     |
| MX                       | GTQ                  | 3      |
## Provider by payout type and country
| disbursement_provider |     type      | destination_country |   n    |
|-----------------------|---------------|---------------------|-------:|
| PROVIDER 1            | WALLET        | GT                  | 3      |
| PROVIDER 10           | CASH          | MX                  | 6      |
| PROVIDER 11           | BANK          | MX                  | 42708  |
| PROVIDER 11           | CASH          | GT                  | 8960   |
| PROVIDER 11           | CASH          | MX                  | 4811   |
| PROVIDER 11           | BANK          | CO                  | 3307   |
| PROVIDER 11           | CASH          | HN                  | 2124   |
| PROVIDER 11           | CASH          | SV                  | 2059   |
| PROVIDER 11           | BANK          | GT                  | 1864   |
| PROVIDER 11           | CASH          | CO                  | 119    |
| PROVIDER 11           | BANK          | HN                  | 8      |
| PROVIDER 11           | BANK          | SV                  | 6      |
| PROVIDER 12           | BANK          | MX                  | 98043  |
| PROVIDER 12           | CASH          | MX                  | 48419  |
| PROVIDER 12           | CASH          | GT                  | 19986  |
| PROVIDER 12           | CASH          | NI                  | 8887   |
| PROVIDER 12           | CASH          | HN                  | 8578   |
| PROVIDER 12           | BANK          | GT                  | 7587   |
| PROVIDER 12           | BANK          | CO                  | 4581   |
| PROVIDER 12           | BANK          | NI                  | 4052   |
| PROVIDER 12           | BANK          | EC                  | 1756   |
| PROVIDER 12           | CASH          | SV                  | 1544   |
| PROVIDER 12           | BANK          | HN                  | 829    |
| PROVIDER 12           | BANK          | PE                  | 756    |
| PROVIDER 12           | CASH          | DO                  | 634    |
| PROVIDER 12           | CASH          | EC                  | 220    |
| PROVIDER 12           | BANK          | SV                  | 182    |
| PROVIDER 12           | CASH          | PE                  | 107    |
| PROVIDER 12           | CASH          | CO                  | 94     |
| PROVIDER 12           | BANK          | CR                  | 43     |
| PROVIDER 12           | CASH DELIVERY | DO                  | 30     |
| PROVIDER 12           | BANK          | BR                  | 5      |
| PROVIDER 12           | CASH          | CR                  | 1      |
| PROVIDER 2            | BANK          | MX                  | 3396   |
| PROVIDER 3            | BANK          | MX                  | 242911 |
| PROVIDER 3            | BANK          | NULL                | 137    |
| PROVIDER 4            | WALLET        | CO                  | 20117  |
| PROVIDER 4            | BANK          | MX                  | 3309   |
| PROVIDER 5            | BANK          | HN                  | 18107  |
| PROVIDER 5            | BANK          | SV                  | 4217   |
| PROVIDER 5            | BANK          | GT                  | 1714   |
| PROVIDER 5            | BANK          | MX                  | 190    |
| PROVIDER 5            | BANK          | PE                  | 179    |
| PROVIDER 5            | BANK          | BR                  | 99     |
| PROVIDER 5            | BANK          | CR                  | 18     |
| PROVIDER 6            | CASH          | MX                  | 268    |
| PROVIDER 7            | BANK          | MX                  | 16907  |
| PROVIDER 7            | CASH          | GT                  | 12871  |
| PROVIDER 7            | BANK          | GT                  | 3335   |
| PROVIDER 7            | CASH          | MX                  | 2955   |
| PROVIDER 7            | BANK          | CO                  | 2163   |
| PROVIDER 7            | CASH          | SV                  | 1088   |
| PROVIDER 7            | BANK          | SV                  | 310    |
| PROVIDER 7            | CASH          | HN                  | 95     |
| PROVIDER 7            | CASH          | CO                  | 48     |
| PROVIDER 7            | BANK          | HN                  | 47     |
| PROVIDER 8            | CASH          | MX                  | 44486  |
| PROVIDER 8            | CASH          | HN                  | 27699  |
| PROVIDER 8            | BANK          | GT                  | 20621  |
| PROVIDER 8            | BANK          | CO                  | 10760  |
| PROVIDER 8            | CASH          | GT                  | 10219  |
| PROVIDER 8            | BANK          | HN                  | 6237   |
| PROVIDER 8            | CASH          | SV                  | 4558   |
| PROVIDER 8            | BANK          | SV                  | 2203   |
| PROVIDER 8            | BANK          | MX                  | 2143   |
| PROVIDER 8            | BANK          | DO                  | 1762   |
| PROVIDER 8            | CASH          | CO                  | 1019   |
| PROVIDER 8            | CASH          | DO                  | 75     |
| PROVIDER 8            | CASH          | COSTA RICA          | 25     |
| PROVIDER 9            | BANK          | CO                  | 5165   |
| PROVIDER 9            | WALLET        | CO                  | 1      |
## Payer destination concentration
| destinations | largest_destination_rows | median_destination_rows |
|-------------:|-------------------------:|------------------------:|
| 213          | 119941                   | 21.0                    |
## Do payer destinations span countries?
| countries | payer_destinations |
|----------:|-------------------:|
| 1         | 196                |
| 2         | 10                 |
| 3         | 4                  |
| 4         | 3                  |
## State code population
| populated | states |
|----------:|-------:|
| 428       | 42     |
