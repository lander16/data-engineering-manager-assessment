## Q1.1 Beneficiary ids, users and sharing
| beneficiary_ids | users  | payments | ids_with_more_than_one_user |
|----------------:|-------:|---------:|----------------------------:|
| 554117          | 394780 | 728227   | 0                           |
## Q1.2 Payments by attempt count and beneficiary id changes
| attempts | payments | id_changed | pct_changed |
|---------:|---------:|-----------:|------------:|
| 1        | 715012   | 0          | 0.0         |
| 2        | 11259    | 2377       | 21.1        |
| 3        | 1540     | 468        | 30.4        |
| 4        | 312      | 103        | 33.0        |
| 5        | 79       | 27         | 34.2        |
| 6        | 21       | 9          | 42.9        |
| 7        | 3        | 2          | 66.7        |
| 8        | 1        | 1          | 100.0       |
## Q1.3 What else changes between consecutive attempts when the id changes
| id_changed | attempt_pairs | pct_provider_changed | pct_payout_type_changed | pct_payer_changed | pct_country_changed | pct_previous_failed | pct_previous_cancelled | median_gap_minutes |
|------------|--------------:|---------------------:|------------------------:|------------------:|--------------------:|--------------------:|-----------------------:|-------------------:|
| true       | 3091          | 39.0                 | 18.9                    | 46.3              | 0.03                | 32.3                | 67.5                   | 82.3               |
| false      | 12630         | 47.2                 | 18.1                    | 29.4              | 0.0                 | 39.4                | 59.0                   | 55.6               |
## Q1.4 Chance the id changes, by other changes and by gap
|           dim           | value | pairs | pct_id_changed |
|-------------------------|-------|------:|---------------:|
| gap 1 day or more       | NULL  | 2055  | 26.6           |
| gap 10 minutes to 1 day | NULL  | 10763 | 19.8           |
| gap under 10 minutes    | NULL  | 2903  | 14.2           |
| payer changed           | false | 10575 | 15.7           |
| payer changed           | true  | 5146  | 27.8           |
| payout type changed     | false | 12845 | 19.5           |
| payout type changed     | true  | 2876  | 20.3           |
| provider changed        | false | 8552  | 22.1           |
| provider changed        | true  | 7169  | 16.8           |
## Q1.5 Where a changed id points
| new_id_used_on_other_payments | old_id_used_on_other_payments | new_id_seen_before_this_attempt | id_changes |
|-------------------------------|-------------------------------|---------------------------------|-----------:|
| false                         | false                         | false                           | 1699       |
| false                         | false                         | true                            | 41         |
| false                         | true                          | false                           | 386        |
| false                         | true                          | true                            | 5          |
| true                          | false                         | false                           | 299        |
| true                          | false                         | true                            | 446        |
| true                          | true                          | false                           | 81         |
| true                          | true                          | true                            | 134        |
## Q1.6 Chains that return to an id they already used
| chains_returning_to_earlier_id | chains_with_any_change |
|-------------------------------:|-----------------------:|
| 51                             | 2987                   |
## Q1.7 Reuse of ids by the same user across payments
| user_has_earlier_payment | id_used_before | payments | pct_within_group |
|--------------------------|----------------|---------:|-----------------:|
| false                    | false          | 394780   | 100.0            |
| true                     | false          | 156860   | 47.0             |
| true                     | true           | 176587   | 53.0             |
## Q1.8 Payments per beneficiary id
| payments_bucket_10_is_10_plus |  ids   |  pct  |
|------------------------------:|-------:|------:|
| 1                             | 441434 | 79.66 |
| 2                             | 76000  | 13.72 |
| 3                             | 22642  | 4.09  |
| 4                             | 7847   | 1.42  |
| 5                             | 3160   | 0.57  |
| 6                             | 1396   | 0.25  |
| 7                             | 677    | 0.12  |
| 8                             | 376    | 0.07  |
| 9                             | 223    | 0.04  |
| 10                            | 362    | 0.07  |
## Q1.9 Stability of an id's destination, first attempts only
| two_or_more_payments |  ids   | pct_more_than_one_payer | pct_more_than_one_payout_type | pct_more_than_one_provider | ids_in_more_than_one_country |
|----------------------|-------:|------------------------:|------------------------------:|---------------------------:|-----------------------------:|
| false                | 439937 | 0.0                     | 0.0                           | 0.0                        | 0                            |
| true                 | 112082 | 7.8                     | 3.1                           | 26.7                       | 0                            |
## Q1.10 Users per payer and country (payer_destination_name looks like an institution)
| users_in_cell | payer_country_cells | users  | beneficiary_ids | user_pairs_sharing_cell |
|---------------|--------------------:|-------:|----------------:|------------------------:|
| 1 user        | 31                  | 31     | 32              | 0.0                     |
| 2-5 users     | 52                  | 158    | 168             | 191.0                   |
| 6-20 users    | 46                  | 505    | 523             | 2968.0                  |
| 21+ users     | 118                 | 488008 | 565687          | 9100597511.0            |
## Q1.11 Rare payer cells (2 to 20 users): do any user pairs look linked
| cell_size  | user_pairs | same_amount_ever | same_amount_within_1d | any_payment_within_1h | median_closest_gap_hours |
|------------|-----------:|-----------------:|----------------------:|----------------------:|-------------------------:|
| 2-5 users  | 116        | 6                | 0                     | 0                     | 1033.0                   |
| 6-20 users | 1640       | 19               | 0                     | 7                     | 861.0                    |
## Q1.12 Candidate rule: same payer, country, type, exact local amount, within 10 minutes, different users
|               tier               | observed_pairs | shuffled_pairs_avg | observed_over_shuffled | max_pct_real_links |
|----------------------------------|---------------:|-------------------:|-----------------------:|-------------------:|
| A common (2% or more of country) | 6948           | 6348.0             | 1.09                   | 8.6                |
| ALL                              | 14439          | 13093.0            | 1.1                    | 9.3                |
| B mid (0.2% to 2%)               | 5425           | 4735.0             | 1.15                   | 12.7               |
| C rare (0.02% to 0.2%)           | 968            | 924.0              | 1.05                   | 4.6                |
| D very rare (under 0.02%)        | 1098           | 1086.0             | 1.01                   | 1.1                |
## Q1.13 Same rule, sensitivity to the width of the shuffle block (seed 1, 10-minute window)
| shuffle_block | shuffled_pairs | observed_pairs | max_pct_real_links |
|---------------|---------------:|---------------:|-------------------:|
| 1 day         | 10750          | 14439          | 25.5               |
| 3 hours       | 13257          | 14439          | 8.2                |
| 1 hour        | 13678          | 14439          | 5.3                |
## Q1.14 Beneficiaries per user under three counting rules
| seg | all_attempts | first_attempts | delivered_primary |
|-----|-------------:|---------------:|------------------:|
| 0   | 0            | 0              | 3532              |
| 1   | 289700       | 290806         | 288918            |
| 2-3 | 92942        | 92088          | 90820             |
| 4-9 | 12044        | 11796          | 11425             |
| 10+ | 94           | 90             | 85                |
## Q1.15 Users whose segment rises only because retries created new ids
| users  | users_with_extra_ids_from_retries | users_4plus_all_attempts | users_4plus_first_attempts | max_ids_all | max_ids_first |
|-------:|----------------------------------:|-------------------------:|---------------------------:|------------:|--------------:|
| 394780 | 2060                              | 12138                    | 11886                      | 20          | 20            |
## Q1.16 Beneficiaries per user by corridor, first attempts
| country | user_corridors | payments | mean_ids | pct_2plus | pct_4plus | max_ids |
|---------|---------------:|---------:|---------:|----------:|----------:|--------:|
| MX      | 268584         | 502346   | 1.38     | 25.2      | 2.85      | 20      |
| GT      | 51370          | 85000    | 1.35     | 24.6      | 2.13      | 16      |
| HN      | 34495          | 61397    | 1.47     | 31.1      | 3.7       | 11      |
| CO      | 26084          | 45966    | 1.3      | 20.0      | 2.25      | 12      |
| SV      | 9595           | 15681    | 1.32     | 22.7      | 1.91      | 8       |
| NI      | 6778           | 12401    | 1.5      | 31.4      | 4.5       | 11      |
| DO      | 1667           | 2419     | 1.21     | 14.5      | 1.38      | 8       |
| EC      | 1363           | 1868     | 1.17     | 13.5      | 0.44      | 6       |
| PE      | 748            | 968      | 1.14     | 10.6      | 0.4       | 4       |
| BR      | 85             | 103      | 1.04     | 2.4       | 0.0       | 3       |
| CR      | 73             | 78       | 1.05     | 4.1       | 0.0       | 3       |
## Q1.17 Users by number of destination countries
| countries | users  |
|----------:|-------:|
| 1         | 388929 |
| 2         | 5657   |
| 3         | 180    |
| 4         | 12     |
| 5         | 1      |
| 6         | 1      |
## Q1.18 Speed of new beneficiaries per user (users with 3 or more ids, first attempts)
|            measure             | users |
|--------------------------------|------:|
| users with 3+ ids              | 33518 |
| new ids in any 24h: 3 or more  | 25    |
| new ids in any 24h: 5 or more  | 0     |
| new ids in any 7d: 5 or more   | 1     |
| new ids in any 30d: 5 or more  | 109   |
| new ids in any 30d: 10 or more | 0     |
## Y2.1 Users qualifying under each rule, full extract
|               rule               | users  | pct  |
|----------------------------------|-------:|-----:|
| delivered users                  | 391244 | NULL |
| 2+ remittances                   | 160590 | 41.0 |
| 2+ distinct UTC days             | 159748 | 40.8 |
| 2+ calendar months               | 144758 | 37.0 |
| 3+ calendar months               | 58727  | 15.0 |
| two sends at least 7 days apart  | 153374 | 39.2 |
| two sends at least 14 days apart | 145915 | 37.3 |
| two sends at least 28 days apart | 131720 | 33.7 |
| two sends at least 60 days apart | 102399 | 26.2 |
## Y2.2 Gap between consecutive delivered remittances
|  gaps  | p05  | p10  | p25  | p50  | p75  |  p90  | pct_under_1d | pct_under_7d | pct_under_14d |
|-------:|-----:|-----:|-----:|-----:|-----:|------:|-------------:|-------------:|--------------:|
| 329386 | 2.27 | 5.13 | 13.6 | 33.0 | 68.0 | 112.1 | 2.5          | 13.8         | 26.1          |
## Y2.3 Gap histogram in days (gaps starting before 2026-03-01)
| gap_day | gaps |
|--------:|-----:|
| 0       | 1263 |
| 1       | 979  |
| 2       | 940  |
| 3       | 890  |
| 4       | 892  |
| 5       | 940  |
| 6       | 1186 |
| 7       | 1167 |
| 8       | 976  |
| 9       | 837  |
| 10      | 785  |
| 11      | 783  |
| 12      | 829  |
| 13      | 1201 |
| 14      | 1098 |
| 15      | 843  |
| 16      | 762  |
| 17      | 741  |
| 18      | 679  |
| 19      | 742  |
| 20      | 882  |
| 21      | 907  |
| 22      | 656  |
| 23      | 626  |
| 24      | 622  |
| 25      | 606  |
| 26      | 669  |
| 27      | 924  |
| 28      | 860  |
| 29      | 643  |
| 30      | 650  |
| 31      | 549  |
| 32      | 569  |
| 33      | 584  |
| 34      | 749  |
| 35      | 705  |
| 36      | 589  |
| 37      | 545  |
| 38      | 472  |
| 39      | 483  |
| 40      | 559  |
| 41      | 689  |
| 42      | 644  |
| 43      | 478  |
| 44      | 452  |
| 45      | 419  |
| 46      | 454  |
| 47      | 468  |
| 48      | 594  |
| 49      | 556  |
## Y2.4 Gap by corridor (corridor of the later remittance)
| country |  gaps  | p25  | p50  | p75  | pct_under_7d | pct_under_28d |
|---------|-------:|-----:|-----:|-----:|-------------:|--------------:|
| MX      | 233418 | 13.5 | 32.9 | 68.0 | 13.9         | 44.9          |
| GT      | 34177  | 15.0 | 35.9 | 71.8 | 11.7         | 41.2          |
| HN      | 27466  | 14.3 | 35.0 | 70.3 | 12.5         | 42.6          |
| CO      | 20281  | 10.8 | 27.5 | 58.6 | 17.3         | 50.8          |
| SV      | 6547   | 14.8 | 35.8 | 72.7 | 12.2         | 41.9          |
| NI      | 5729   | 12.0 | 29.9 | 61.5 | 15.5         | 47.5          |
| DO      | 830    | 7.1  | 20.4 | 47.8 | 24.7         | 57.5          |
| EC      | 621    | 11.4 | 26.5 | 55.9 | 15.3         | 51.4          |
| PE      | 273    | 8.0  | 21.1 | 45.2 | 23.1         | 57.5          |
| CR      | 25     | 14.1 | 41.2 | 96.0 | 8.0          | 44.0          |
| BR      | 19     | 1.9  | 4.5  | 13.3 | 52.6         | 89.5          |
## Y2.5 Gap by first-month cohort (shrinks for late cohorts because of censoring)
|   cohort   | users_with_a_gap | gaps  | median_gap_d | pct_under_7d |
|------------|-----------------:|------:|-------------:|-------------:|
| 2026-01-01 | 30780            | 86943 | 35.2         | 13.6         |
| 2026-02-01 | 25838            | 61533 | 37.4         | 12.3         |
| 2026-03-01 | 25306            | 53835 | 37.3         | 12.5         |
| 2026-04-01 | 21284            | 40375 | 35.1         | 12.5         |
| 2026-05-01 | 20275            | 34526 | 33.7         | 13.1         |
| 2026-06-01 | 15598            | 24146 | 28.4         | 14.5         |
| 2026-07-01 | 12188            | 16819 | 23.1         | 17.0         |
| 2026-08-01 | 7622             | 9355  | 14.3         | 25.4         |
| 2026-09-01 | 1699             | 1854  | 5.8          | 60.3         |
## Y2.6 Two-month qualifiers by span between first and last send
|              measure               | users  | pct  |
|------------------------------------|-------:|-----:|
| qualify by 2+ calendar months      | 144758 | NULL |
| ... span under 1 day               | 17     | 0.01 |
| ... span under 3 days              | 111    | 0.08 |
| ... span under 7 days              | 713    | 0.49 |
| ... span under 14 days             | 3154   | 2.18 |
| ... span under 28 days             | 13155  | 9.09 |
| one month but span 28 days or more | 117    | NULL |
| one month but span 14 days or more | 4311   | NULL |
## Y2.6b Users with exactly two delivered remittances: months and gap
| two_send_users | in_two_months | two_months_gap_under_3d | two_months_gap_under_7d | one_month_gap_14d_or_more |
|---------------:|--------------:|------------------------:|------------------------:|--------------------------:|
| 83897          | 69305         | 110                     | 691                     | 3707                      |
## Y2.7 Check of Y2.6 through summed gaps, and boundary-straddling pairs under 3 days
| users_2_months_span_under_3d_via_gaps | users_with_any_month_straddling_pair_under_3d |
|--------------------------------------:|----------------------------------------------:|
| 111                                   | 807                                           |
## Y2.8 Rule share by first-month cohort, full extract (not comparable across cohorts)
|   cohort   | users | pct_2plus_sends | pct_2_months | pct_3_months | pct_span_14d | pct_span_28d |
|------------|------:|----------------:|-------------:|-------------:|-------------:|-------------:|
| 2026-01-01 | 48571 | 63.4            | 61.1         | 35.8         | 61.2         | 58.9         |
| 2026-02-01 | 44553 | 58.0            | 55.4         | 28.8         | 55.4         | 52.6         |
| 2026-03-01 | 47986 | 52.7            | 49.8         | 22.4         | 50.0         | 47.2         |
| 2026-04-01 | 44336 | 48.0            | 44.7         | 17.4         | 44.8         | 41.3         |
| 2026-05-01 | 48911 | 41.5            | 37.4         | 11.6         | 37.9         | 34.4         |
| 2026-06-01 | 42982 | 36.3            | 32.1         | 7.4          | 32.2         | 27.6         |
| 2026-07-01 | 42965 | 28.4            | 23.0         | 2.8          | 23.5         | 18.2         |
| 2026-08-01 | 41814 | 18.2            | 11.4         | 0.0          | 11.9         | 5.3          |
| 2026-09-01 | 29126 | 5.8             | 0.0          | 0.0          | 0.7          | 0.0          |
## Y2.9 Rule share by first-month cohort in an equal window after the first send
| window_days |   cohort   | users | pct_2plus_sends | pct_2_months | pct_3_months | pct_span_14d | pct_span_28d |
|------------:|------------|------:|----------------:|-------------:|-------------:|-------------:|-------------:|
| 60          | 2026-01-01 | 48571 | 33.4            | 26.9         | 3.6          | 27.7         | 20.9         |
| 60          | 2026-02-01 | 44553 | 30.5            | 24.4         | 2.7          | 24.7         | 17.9         |
| 60          | 2026-03-01 | 47986 | 28.7            | 22.6         | 2.4          | 23.3         | 17.4         |
| 60          | 2026-04-01 | 44336 | 28.0            | 22.2         | 2.2          | 22.7         | 16.4         |
| 60          | 2026-05-01 | 48911 | 26.0            | 19.9         | 1.8          | 20.8         | 15.2         |
| 60          | 2026-06-01 | 42982 | 26.5            | 20.8         | 2.0          | 21.2         | 15.2         |
| 60          | 2026-07-01 | 32618 | 26.0            | 18.8         | 1.3          | 20.8         | 15.2         |
| 90          | 2026-01-01 | 48571 | 42.3            | 37.3         | 9.9          | 37.9         | 32.8         |
| 90          | 2026-02-01 | 44553 | 39.5            | 34.8         | 8.2          | 34.9         | 29.7         |
| 90          | 2026-03-01 | 47986 | 36.9            | 32.0         | 6.9          | 32.5         | 27.9         |
| 90          | 2026-04-01 | 44336 | 36.0            | 31.3         | 6.6          | 31.7         | 26.6         |
| 90          | 2026-05-01 | 48911 | 33.7            | 28.7         | 5.6          | 29.4         | 24.9         |
| 90          | 2026-06-01 | 33898 | 34.6            | 29.0         | 5.6          | 30.2         | 25.5         |
## Y2.10 Calendar phase effect: same 60-day window, by day of month of the first send
| first_send_day_of_month | users | pct_2plus_sends | pct_2_months | pct_3_months | pct_span_14d | pct_2_months_but_span_under_14d |
|-------------------------|------:|----------------:|-------------:|-------------:|-------------:|--------------------------------:|
| a day 1-7               | 72729 | 28.8            | 17.8         | 0.6          | 23.2         | 0.0                             |
| b day 8-14              | 76184 | 28.3            | 20.4         | 1.7          | 22.8         | 0.0                             |
| c day 15-21             | 75598 | 28.6            | 23.8         | 2.8          | 23.3         | 0.76                            |
| d day 22-25             | 39085 | 28.9            | 26.0         | 3.7          | 23.4         | 2.68                            |
| e day 26-31             | 46361 | 28.4            | 27.5         | 4.1          | 23.3         | 4.27                            |
## Y2.11 Time to qualify, users whose first send is 150 or more days before the extract end
|         rule         | users  | by_day_30 | by_day_60 | by_day_90 | by_day_120 | by_day_150 | by_extract_end |
|----------------------|-------:|----------:|----------:|----------:|-----------:|-----------:|---------------:|
| 2+ calendar months   | 177340 | 9.6       | 24.0      | 33.9      | 41.1       | 46.4       | 53.2           |
| 2+ remittances       | 177340 | 18.3      | 30.3      | 38.9      | 45.3       | 50.0       | 56.1           |
| 3+ calendar months   | 177340 | 0.0       | 2.7       | 7.9       | 13.6       | 18.5       | 26.7           |
| sends 14+ days apart | 177340 | 10.8      | 24.8      | 34.5      | 41.6       | 46.8       | 53.5           |
## Y2.12 Which rule predicts activity afterwards (rule fixed at day W, outcome in the next 60 days)
| day_w |         rule         | users  | pct_qualify | active_if_qualify | active_if_not | lift | recall | balanced_accuracy |
|------:|----------------------|-------:|------------:|------------------:|--------------:|-----:|-------:|------------------:|
| 30    | 2+ remittances       | 268255 | 17.4        | 42.0              | 24.0          | 1.75 | 27.0   | 56.5              |
| 30    | sends 7+ days apart  | 268255 | 14.1        | 42.9              | 24.6          | 1.74 | 22.2   | 55.6              |
| 30    | sends 14+ days apart | 268255 | 10.2        | 43.7              | 25.3          | 1.73 | 16.4   | 54.2              |
| 30    | 2+ calendar months   | 268255 | 9.1         | 43.1              | 25.6          | 1.68 | 14.4   | 53.6              |
| 30    | 3+ remittances       | 268255 | 2.8         | 55.7              | 26.3          | 2.12 | 5.8    | 52.1              |
| 30    | sends 28+ days apart | 268255 | 1.5         | 44.5              | 26.9          | 1.66 | 2.5    | 50.7              |
| 30    | 3+ calendar months   | 268255 | 0.0         | 44.4              | 27.2          | 1.64 | 0.0    | 50.0              |
| 60    | 2+ remittances       | 225178 | 29.4        | 39.3              | 20.9          | 1.89 | 44.1   | 59.9              |
| 60    | sends 7+ days apart  | 225178 | 26.9        | 40.1              | 21.2          | 1.89 | 40.9   | 59.6              |
| 60    | sends 14+ days apart | 225178 | 23.9        | 40.9              | 21.7          | 1.88 | 37.2   | 59.0              |
| 60    | 2+ calendar months   | 225178 | 23.1        | 40.9              | 21.9          | 1.87 | 36.0   | 58.7              |
| 60    | sends 28+ days apart | 225178 | 17.7        | 42.6              | 22.8          | 1.87 | 28.6   | 57.4              |
| 60    | 3+ remittances       | 225178 | 8.3         | 50.6              | 24.1          | 2.1  | 16.0   | 55.2              |
| 60    | 3+ calendar months   | 225178 | 2.5         | 53.4              | 25.6          | 2.08 | 5.1    | 51.8              |
| 90    | sends 7+ days apart  | 177340 | 36.8        | 38.3              | 18.5          | 2.07 | 54.7   | 62.0              |
| 90    | 2+ remittances       | 177340 | 38.9        | 37.6              | 18.2          | 2.06 | 56.8   | 62.0              |
| 90    | sends 14+ days apart | 177340 | 34.5        | 38.9              | 18.8          | 2.07 | 52.1   | 61.9              |
| 90    | 2+ calendar months   | 177340 | 33.9        | 39.0              | 19.0          | 2.05 | 51.2   | 61.7              |
| 90    | sends 28+ days apart | 177340 | 29.4        | 40.3              | 19.7          | 2.05 | 46.1   | 61.2              |
| 90    | 3+ remittances       | 177340 | 14.5        | 47.7              | 22.0          | 2.17 | 26.9   | 58.4              |
| 90    | 3+ calendar months   | 177340 | 7.9         | 51.4              | 23.5          | 2.18 | 15.8   | 55.3              |
## Y2.13 Discordant groups: calendar-month rule against sends-apart rule (rule fixed at day W, next 60 days)
| day_w |              grp              | users  | pct_active_next_60d |
|------:|-------------------------------|-------:|--------------------:|
| 60    | 0 single send                 | 158877 | 20.9                |
| 60    | 1 months 2+ but span under 7d | 538    | 33.3                |
| 60    | 2 months 2+ but span 7-14d    | 2070   | 33.9                |
| 60    | 3 months 2+ and span 14d+     | 49427  | 41.3                |
| 60    | 4 one month but span 14d+     | 4462   | 36.0                |
| 60    | 5 one month, span under 7d    | 5302   | 31.4                |
| 60    | 6 one month, span 7-14d       | 4502   | 33.7                |
| 90    | 0 single send                 | 108363 | 18.2                |
| 90    | 1 months 2+ but span under 7d | 327    | 25.1                |
| 90    | 2 months 2+ but span 7-14d    | 1319   | 28.8                |
| 90    | 3 months 2+ and span 14d+     | 58411  | 39.3                |
| 90    | 4 one month but span 14d+     | 2708   | 31.1                |
| 90    | 5 one month, span under 7d    | 3395   | 25.8                |
| 90    | 6 one month, span 7-14d       | 2817   | 28.8                |
## Y3.1 Full-extract top group against the rest
| in_top_50_pct | users  |    usd    | avg_remittances | avg_months | pct_single_send | pct_2_months | avg_ticket |
|---------------|-------:|----------:|----------------:|-----------:|----------------:|-------------:|-----------:|
| true          | 59511  | 118537971 | 2.8             | 2.29       | 31.8            | 63.8         | 710.0      |
| false         | 331733 | 118537866 | 1.67            | 1.5        | 63.8            | 32.2         | 214.0      |
## Y3.2 Monthly top group size and threshold
|   month    | top_users | active_users | pct_of_active | smallest_top_user_usd |
|------------|----------:|-------------:|--------------:|----------------------:|
| 2026-01-01 | 6387      | 48571        | 13.1          | 750.000000000         |
| 2026-02-01 | 7182      | 53763        | 13.4          | 802.990000000         |
| 2026-03-01 | 8942      | 65735        | 13.6          | 852.990000000         |
| 2026-04-01 | 9341      | 68082        | 13.7          | 810.990000000         |
| 2026-05-01 | 11193     | 80753        | 13.9          | 804.980000000         |
| 2026-06-01 | 10897     | 78247        | 13.9          | 849.990000000         |
| 2026-07-01 | 11806     | 83850        | 14.1          | 826.490000000         |
| 2026-08-01 | 12288     | 87848        | 14.0          | 819.990000000         |
| 2026-09-01 | 8987      | 66207        | 13.6          | 846.980000000         |
## Y3.3 Overlap of consecutive monthly top groups
|   month    | top_users | also_top_next_month | pct_stay_top | jaccard_pct |
|------------|----------:|--------------------:|-------------:|------------:|
| 2026-01-01 | 6387      | 280                 | 4.4          | 2.1         |
| 2026-02-01 | 7182      | 325                 | 4.5          | 2.1         |
| 2026-03-01 | 8942      | 419                 | 4.7          | 2.3         |
| 2026-04-01 | 9341      | 480                 | 5.1          | 2.4         |
| 2026-05-01 | 11193     | 508                 | 4.5          | 2.4         |
| 2026-06-01 | 10897     | 605                 | 5.6          | 2.7         |
| 2026-07-01 | 11806     | 598                 | 5.1          | 2.5         |
| 2026-08-01 | 12288     | 410                 | 3.3          | 2.0         |
## Y3.4 Check of Y3.3 for January to February with flags per user
| top_in_both | jan_top | feb_top |
|------------:|--------:|--------:|
| 280         | 6387    | 7182    |
## Y3.5 Next-month behavior of monthly top users (January to August)
|       grp        | user_months | pct_active_next_month | pct_top_next_month |
|------------------|------------:|----------------------:|-------------------:|
| top 50% in month | 78036       | 14.4                  | 4.6                |
| rest             | 488813      | 20.7                  | 1.5                |
## Y3.6 How monthly top users reach their volume
| remittances_in_month | top_user_months | pct  | avg_month_usd |
|----------------------|----------------:|-----:|--------------:|
| 1 remittance         | 72244           | 83.0 | 1329.0        |
| 2 remittances        | 12297           | 14.1 | 1518.0        |
| 3+ remittances       | 2482            | 2.9  | 1551.0        |
## Y3.7 Monthly top groups against the full-extract top group
|   month    | top_users | pct_in_full_top | pct_of_full_top_covered | pct_month_volume_from_full_top |
|------------|----------:|----------------:|------------------------:|-------------------------------:|
| 2026-01-01 | 6387      | 68.0            | 7.3                     | 48.8                           |
| 2026-02-01 | 7182      | 71.7            | 8.7                     | 50.6                           |
| 2026-03-01 | 8942      | 72.8            | 10.9                    | 51.6                           |
| 2026-04-01 | 9341      | 72.7            | 11.4                    | 51.2                           |
| 2026-05-01 | 11193     | 70.8            | 13.3                    | 50.1                           |
| 2026-06-01 | 10897     | 73.1            | 13.4                    | 51.0                           |
| 2026-07-01 | 11806     | 70.5            | 14.0                    | 49.5                           |
| 2026-08-01 | 12288     | 70.2            | 14.5                    | 48.7                           |
| 2026-09-01 | 8987      | 69.7            | 10.5                    | 48.6                           |
## Y3.8 Users in a monthly top group at least once, against the full-extract group
| ever_in_monthly_top | full_top | in_both | full_top_never_in_monthly_top | monthly_top_not_in_full_top |
|--------------------:|---------:|--------:|------------------------------:|----------------------------:|
| 76621               | 59511    | 51495   | 8016                          | 25126                       |
## Y3.9 Months a full-extract top user spent in a monthly top group
| months_in_monthly_top | full_top_users |
|----------------------:|---------------:|
| 0                     | 8016           |
| 1                     | 42364          |
| 2                     | 7985           |
| 3                     | 1027           |
| 4                     | 113            |
| 5                     | 6              |
## Y3.10 Tenure: share of each first-month cohort in the full-extract top group
|   cohort   | users | top_users | pct_of_cohort_in_top | pct_of_total_volume | pct_of_users |
|------------|------:|----------:|---------------------:|--------------------:|-------------:|
| 2026-01-01 | 48571 | 10306     | 21.2                 | 15.7                | 12.4         |
| 2026-02-01 | 44553 | 8693      | 19.5                 | 13.6                | 11.4         |
| 2026-03-01 | 47986 | 8736      | 18.2                 | 14.0                | 12.3         |
| 2026-04-01 | 44336 | 7189      | 16.2                 | 11.9                | 11.3         |
| 2026-05-01 | 48911 | 7004      | 14.3                 | 12.1                | 12.5         |
| 2026-06-01 | 42982 | 5877      | 13.7                 | 10.2                | 11.0         |
| 2026-07-01 | 42965 | 4898      | 11.4                 | 9.2                 | 11.0         |
| 2026-08-01 | 41814 | 4183      | 10.0                 | 8.1                 | 10.7         |
| 2026-09-01 | 29126 | 2625      | 9.0                  | 5.2                 | 7.4          |
## Y3.11 Same test with equal exposure: rank by volume in the first 90 days after the first send
|   cohort   | users | pct_in_top_by_first_90_days |
|------------|------:|----------------------------:|
| 2026-01-01 | 48571 | 13.6                        |
| 2026-02-01 | 44553 | 14.6                        |
| 2026-03-01 | 47986 | 15.6                        |
| 2026-04-01 | 44336 | 15.4                        |
| 2026-05-01 | 48911 | 15.1                        |
| 2026-06-01 | 33898 | 16.5                        |
## Y3.12 Quarterly ranking, overlap of consecutive quarters (third quarter is partial and has no successor)
|  quarter   | top_users | active_users | pct_of_active | also_top_next_quarter | pct_stay_top |
|------------|----------:|-------------:|--------------:|----------------------:|-------------:|
| 2026-01-01 | 20086     | 141110       | 14.2          | 2200                  | 11.0         |
| 2026-04-01 | 27724     | 188283       | 14.7          | 2726                  | 9.8          |
| 2026-07-01 | 29398     | 197781       | 14.9          | NULL                  | NULL         |
