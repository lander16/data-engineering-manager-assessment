## C1 Users under each definition
| users  | two_calendar_months | gap_within_60_days | gap_within_90_days | two_sends |
|-------:|--------------------:|-------------------:|-------------------:|----------:|
| 391244 | 144758              | 117010             | 133760             | 160590    |
## C2 Gap distribution between delivered remittances
| p50  | p75  |  p90  | pct_within_60 | pct_within_90 |
|-----:|-----:|------:|--------------:|--------------:|
| 33.0 | 68.0 | 112.1 | 70.8          | 83.9          |
## C3 Calendar effect: rule met within 60 days, by week of the month of the first send
| start_week | users | two_calendar_months_pct | repeat_within_60_pct |
|-----------:|------:|------------------------:|---------------------:|
| 1          | 72729 | 17.8                    | 28.3                 |
| 2          | 76184 | 20.4                    | 27.9                 |
| 3          | 75598 | 23.8                    | 28.2                 |
| 4          | 85446 | 26.8                    | 28.2                 |
## C4 Share by first month, which shows right-censoring
| first_month | users | two_calendar_months_pct | gap_within_60_pct | gap_within_90_pct |
|-------------|------:|------------------------:|------------------:|------------------:|
| 2026-01-01  | 48571 | 61.1                    | 44.6              | 50.1              |
| 2026-02-01  | 44553 | 55.4                    | 39.6              | 45.4              |
| 2026-03-01  | 47986 | 49.8                    | 35.7              | 41.2              |
| 2026-04-01  | 44336 | 44.7                    | 33.2              | 38.3              |
| 2026-05-01  | 48911 | 37.4                    | 29.0              | 34.4              |
| 2026-06-01  | 42982 | 32.1                    | 27.5              | 34.2              |
| 2026-07-01  | 42965 | 23.0                    | 25.5              | 27.9              |
| 2026-08-01  | 41814 | 11.4                    | 17.7              | 17.7              |
| 2026-09-01  | 29126 | 0.0                     | 5.2               | 5.2               |
## C5 Repeat rate among users with a full window
| window_days | eligible | repeat_pct |
|------------:|---------:|-----------:|
| 60          | 309957   | 28.2       |
| 90          | 268255   | 36.9       |
## C6 Where the 2-month and 90-day rules disagree
| two_calendar_months | gap_within_90_days | users  |
|---------------------|--------------------|-------:|
| false               | false              | 231926 |
| false               | true               | 14560  |
| true                | false              | 25558  |
| true                | true               | 119200 |
## C7 Does the rule predict the next 60 days? Rule read on the first 90 days, for users first seen by May 20
|         rule          | qualifies_pct | active_if_qualified | active_if_not |
|-----------------------|--------------:|--------------------:|--------------:|
| two_calendar_months   | 32.8          | 37.6                | 18.0          |
| repeat_within_90_days | 37.6          | 36.3                | 17.3          |
## C8 Repeat within 90 days by first month, for users with a full window
| first_month | eligible | repeat_within_90_pct |
|-------------|---------:|---------------------:|
| 2026-01-01  | 48571    | 41.9                 |
| 2026-02-01  | 44553    | 39.1                 |
| 2026-03-01  | 47986    | 36.5                 |
| 2026-04-01  | 44336    | 35.7                 |
| 2026-05-01  | 48911    | 33.4                 |
| 2026-06-01  | 33898    | 34.2                 |
## C9 Effect of $0 remittances on the 90-day rule
| recurring_on_positive_amounts |
|------------------------------:|
| 133740                        |
