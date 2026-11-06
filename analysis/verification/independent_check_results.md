# Independent verification (pure Python stdlib, Decimal)

Checks compared: 137; matched: 137; mismatched: 0; not reported by DuckDB: 3

Match = independent value rounded to the precision DuckDB printed. DuckDB business tables (06) print USD at 6dp after a cast, so USD sums that include the 689 high-precision payments differ in the 5th-6th decimal.

| check | independent value | DuckDB value | match |
|---|---|---|---|
| payments rows | 788976 | 788976 | yes |
| payments distinct id | 788976 | 788976 | yes |
| receipts rows | 743948 | 743948 | yes |
| receipts distinct id | 743948 | 743948 | yes |
| disbursements rows | 743763 | 743763 | yes |
| disbursements distinct id | 743763 | 743763 | yes |
| receipts per payment dist (payments with >=1 receipt) | 1:715012; 2:11259; 3:1540; 4:312; 5:79; 6:21; 7:3; 8:1 | 1:715012; 2:11259; 3:1540; 4:312; 5:79; 6:21; 7:3; 8:1 | yes |
| receipts with null disbursement_id | 0 | n/a (not reported) | n/a |
| receipts with disbursement_id not in disbursements | 185 | n/a (not reported) | n/a |
| receipts with no disbursement record (null or missing) | 185 | 185 | yes |
| receipts with payment_id not in payments | 0 | 0 | yes |
| payments without a receipt | 60749 | 60749 | yes |
| nulls payments.id | 0 | 0 | yes |
| nulls payments.amount | 0 | 0 | yes |
| nulls payments.currency | 0 | 0 | yes |
| nulls payments.user_id | 0 | 0 | yes |
| nulls payments.status | 0 | 0 | yes |
| nulls payments.detailed_status | 2745 | 2745 | yes |
| nulls payments.error_code | 788976 | 788976 | yes |
| nulls payments.reason | 788976 | 788976 | yes |
| nulls payments.type | 1 | 1 | yes |
| nulls payments.total_intents | 772324 | 772324 | yes |
| nulls payments.location_of_request_state_code | 788548 | 788548 | yes |
| nulls payments.has_dispute_chargeback | 0 | 0 | yes |
| nulls payments.created_at | 0 | 0 | yes |
| nulls payments.updated_at | 0 | 0 | yes |
| nulls receipts.id | 0 | 0 | yes |
| nulls receipts.destination_country_code | 0 | 0 | yes |
| nulls receipts.destination_currency | 0 | 0 | yes |
| nulls receipts.amount_charged | 0 | 0 | yes |
| nulls receipts.fee | 0 | 0 | yes |
| nulls receipts.exchange_rate | 0 | 0 | yes |
| nulls receipts.promotion_amount | 0 | 0 | yes |
| nulls receipts.destination_amount | 0 | 0 | yes |
| nulls receipts.user_id | 0 | 0 | yes |
| nulls receipts.payment_id | 0 | 0 | yes |
| nulls receipts.disbursement_id | 0 | 0 | yes |
| nulls receipts.beneficiary_id | 0 | 0 | yes |
| nulls receipts.created_at | 0 | 0 | yes |
| nulls disbursements.id | 0 | 0 | yes |
| nulls disbursements.user_id | 0 | 0 | yes |
| nulls disbursements.type | 0 | 0 | yes |
| nulls disbursements.status | 0 | 0 | yes |
| nulls disbursements.raw_status | 0 | 0 | yes |
| nulls disbursements.provider_status | 579607 | 579607 | yes |
| nulls disbursements.amount | 568 | 568 | yes |
| nulls disbursements.disbursement_provider | 0 | 0 | yes |
| nulls disbursements.payer_destination_name | 0 | 0 | yes |
| nulls disbursements.destination_country | 137 | 137 | yes |
| nulls disbursements.destination_currency | 137 | 137 | yes |
| nulls disbursements.created_at | 0 | 0 | yes |
| nulls disbursements.updated_at | 816 | 816 | yes |
| payments.amount decimals dist | 0:50321; 1:12022; 2:725806; 3:94; 4:39; 5:5; 8:4; 9:685 | 0:50321; 1:12022; 2:725806; 3:94; 4:39; 5:5; 8:4; 9:685 | yes |
| payments.amount 8/9dp rows matching float32(round2) at 9dp | 687 | 687 | yes |
| payments.amount rows with 8 or 9 dp | 689 | 689 | yes |
| numeric payments.amount max decimals / max int digits | 9 / 4 | 9 / 4 | yes |
| numeric payments.total_intents max decimals / max int digits | 0 / 1 | 0 / 1 | yes |
| numeric receipts.amount_charged max decimals / max int digits | 2 / 4 | 2 / 4 | yes |
| numeric receipts.fee max decimals / max int digits | 2 / 2 | 2 / 2 | yes |
| numeric receipts.exchange_rate max decimals / max int digits | 4 / 4 | 4 / 4 | yes |
| numeric receipts.promotion_amount max decimals / max int digits | 2 / 3 | 2 / 3 | yes |
| numeric receipts.destination_amount max decimals / max int digits | 2 / 8 | 2 / 8 | yes |
| numeric disbursements.amount max decimals / max int digits | 2 / 8 | 2 / 8 | yes |
| sum payments.amount all | 268009275.296380599 | 268009275.296380599 | yes |
| sum payments.amount SUCCESSFUL | 237730447.406696304 | 237730447.406696304 | yes |
| delivered remittance count | 720630 | 720630 | yes |
| sum delivered remittance amount | 237075836.916685776 | 237075836.916685776 | yes |
| delivered month 2026-01 volume / count | 16679287.738697410 / 54755 | 16679287.738697410 / 54755 | yes |
| delivered month 2026-02 volume / count | 19265512.559947657 / 60726 | 19265512.559947657 / 60726 | yes |
| delivered month 2026-03 volume / count | 24753796.199430188 / 75052 | 24753796.199430188 / 75052 | yes |
| delivered month 2026-04 volume / count | 25408575.707895777 / 77645 | 25408575.707895777 / 77645 | yes |
| delivered month 2026-05 volume / count | 30303037.939352239 / 92746 | 30303037.939352239 / 92746 | yes |
| delivered month 2026-06 volume / count | 30038057.871036566 / 89289 | 30038057.871036566 / 89289 | yes |
| delivered month 2026-07 volume / count | 32372631.160644604 / 96149 | 32372631.160644604 / 96149 | yes |
| delivered month 2026-08 volume / count | 33614832.568005530 / 101232 | 33614832.568005530 / 101232 | yes |
| delivered month 2026-09 volume / count | 24640105.171675805 / 73036 | 24640105.171675805 / 73036 | yes |
| delivered months present | 9 | 9 | yes |
| outcome FAILED x all_attempts_failed count / USD | 1 / 500 | 1 / 500.000000 | yes |
| outcome FAILED x delivered count / USD | 2 / 512.99 | 2 / 512.990000 | yes |
| outcome FAILED x no_receipt count / USD | 58684 / 27567825.155192383 | 58684 / 27567825.155192383 | yes |
| outcome PENDING_USER_ACTION x no_receipt count / USD | 17 / 7039.40 | 17 / 7039.400000 | yes |
| outcome REFUNDED x all_attempts_failed count / USD | 6106 / 2653985.044491912 | 6106 / 2653985.044492 | yes |
| outcome REFUNDED x delivered count / USD | 7 / 1897.49 | 7 / 1897.490000 | yes |
| outcome REFUNDED x in_flight_or_unknown count / USD | 20 / 13485.04 | 20 / 13485.040000 | yes |
| outcome REFUNDED x no_receipt count / USD | 86 / 33583.67 | 86 / 33583.670000 | yes |
| outcome STARTED x no_receipt count / USD | 1 / -0.9 | 1 / -0.900000 | yes |
| outcome SUCCESSFUL x all_attempts_failed count / USD | 182 / 50900.590010986 | 182 / 50900.590011 | yes |
| outcome SUCCESSFUL x delivered count / USD | 720611 / 237070321.026685776 | 720611 / 237070321.026685776 | yes |
| outcome SUCCESSFUL x in_flight_or_unknown count / USD | 1279 / 563019.749999542 | 1279 / 563019.750000 | yes |
| outcome SUCCESSFUL x multiple_delivered count / USD | 19 / 5515.89 | 19 / 5515.890000 | yes |
| outcome SUCCESSFUL x no_receipt count / USD | 1961 / 40690.15 | 1961 / 40690.150000 | yes |
| outcome table total count / USD | 788976 / 268009275.296380599 | 788976 / 268009275.296380599 | yes |
| beneficiaries shared by >1 user | 0 | 0 | yes |
| distinct beneficiaries | 554117 | 554117 | yes |
| users by beneficiary count bucket | 1:289700; 2-3:92942; 4-9:12044; 10+:94 | 1:289700; 2-3:92942; 4-9:12044; 10+:94 | yes |
| provider 'PROVIDER 3' attempts / %status fail / %raw fail / %raw cancelled | 243048 / 1.44 / 0.18 / 1.26 | 243048 / 1.44 / 0.18 / 1.26 | yes |
| provider 'PROVIDER 12' attempts / %status fail / %raw fail / %raw cancelled | 206334 / 3.78 / 1.33 / 2.42 | 206334 / 3.78 / 1.33 / 2.42 | yes |
| provider 'PROVIDER 8' attempts / %status fail / %raw fail / %raw cancelled | 131807 / 4.75 / 0.42 / 4.33 | 131807 / 4.75 / 0.42 / 4.33 | yes |
| provider 'PROVIDER 11' attempts / %status fail / %raw fail / %raw cancelled | 65966 / 1.94 / 1.94 / 0.00 | 65966 / 1.94 / 1.94 / 0.0 | yes |
| provider 'PROVIDER 7' attempts / %status fail / %raw fail / %raw cancelled | 39819 / 3.32 / 2.95 / 0.37 | 39819 / 3.32 / 2.95 / 0.37 | yes |
| provider 'PROVIDER 5' attempts / %status fail / %raw fail / %raw cancelled | 24524 / 2.84 / 2.80 / 0.04 | 24524 / 2.84 / 2.8 / 0.04 | yes |
| provider 'PROVIDER 4' attempts / %status fail / %raw fail / %raw cancelled | 23426 / 2.00 / 1.93 / 0.00 | 23426 / 2.0 / 1.93 / 0.0 | yes |
| provider 'PROVIDER 9' attempts / %status fail / %raw fail / %raw cancelled | 5166 / 3.74 / 3.74 / 0.00 | 5166 / 3.74 / 3.74 / 0.0 | yes |
| provider 'PROVIDER 2' attempts / %status fail / %raw fail / %raw cancelled | 3396 / 7.48 / 7.48 / 0.00 | 3396 / 7.48 / 7.48 / 0.0 | yes |
| provider 'PROVIDER 6' attempts / %status fail / %raw fail / %raw cancelled | 268 / 10.07 / 10.07 / 0.00 | 268 / 10.07 / 10.07 / 0.0 | yes |
| provider 'PROVIDER 10' attempts / %status fail / %raw fail / %raw cancelled | 6 / 66.67 / 0.00 / 66.67 | 6 / 66.67 / 0.0 / 66.67 | yes |
| provider 'PROVIDER 1' attempts / %status fail / %raw fail / %raw cancelled | 3 / 66.67 / 66.67 / 0.00 | 3 / 66.67 / 66.67 / 0.0 | yes |
| chargeback values seen | False:788450; True:526 | n/a (not reported) | n/a |
| chargebacks among SUCCESSFUL/REFUNDED | 526 | 526 | yes |
| settled (SUCCESSFUL/REFUNDED) count | 730271 | 730271 | yes |
| chargeback count rate % | 0.0720 | 0.072 | yes |
| chargeback USD rate % | 0.0950 | 0.095 | yes |
| chargeback month 2026-01 cb / settled / rate % | 43 / 55473 / 0.0775 | 43 / 55473 / 0.078 | yes |
| chargeback month 2026-02 cb / settled / rate % | 33 / 61379 / 0.0538 | 33 / 61379 / 0.054 | yes |
| chargeback month 2026-03 cb / settled / rate % | 65 / 75911 / 0.0856 | 65 / 75911 / 0.086 | yes |
| chargeback month 2026-04 cb / settled / rate % | 74 / 78419 / 0.0944 | 74 / 78419 / 0.094 | yes |
| chargeback month 2026-05 cb / settled / rate % | 96 / 93582 / 0.1026 | 96 / 93582 / 0.103 | yes |
| chargeback month 2026-06 cb / settled / rate % | 76 / 90058 / 0.0844 | 76 / 90058 / 0.084 | yes |
| chargeback month 2026-07 cb / settled / rate % | 60 / 97043 / 0.0618 | 60 / 97043 / 0.062 | yes |
| chargeback month 2026-08 cb / settled / rate % | 55 / 102736 / 0.0535 | 55 / 102736 / 0.054 | yes |
| chargeback month 2026-09 cb / settled / rate % | 24 / 75670 / 0.0317 | 24 / 75670 / 0.032 | yes |
| users with delivered payments (total users) | 391244 | 391244 | yes |
| rank where cumulative >= 50% of delivered USD | 59511 | 59511 | yes |
| rank as % of users | 15.2107 | 15.21 | yes |
| delivered users with 2+ remittances | 160590 | 160590 | yes |
| delivered users with 2+ distinct months | 144758 | 144758 | yes |
| delivered users with 3+ distinct months | 58727 | 58727 | yes |
| delivered users with a gap over 1 day and at most 90 days | 133760 | 133760 | yes |
| receipts promotion_amount > 0 | 13983 | 13983 | yes |
| sum promotion_amount | 746479.11 | 746479.11 | yes |
| max promotion_amount | 620 | 620 | yes |
| receipts amount_charged = 0 and promotion > 0 | 2953 | 2953 | yes |
| SUCCESSFUL no-receipt month 2026-06 | 29 | 29 | yes |
| SUCCESSFUL no-receipt month 2026-07 | 148 | 148 | yes |
| SUCCESSFUL no-receipt month 2026-08 | 733 | 733 | yes |
| SUCCESSFUL no-receipt month 2026-09 | 1051 | 1051 | yes |
| SUCCESSFUL no-receipt total | 1961 | 1961 | yes |
| payments with failed-family attempt | 18313 | 18313 | yes |
| ... also with delivered attempt | 11975 | 11975 | yes |
| ... without delivered attempt | 6338 | 6338 | yes |
