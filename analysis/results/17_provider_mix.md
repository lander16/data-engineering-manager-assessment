## M1 Failed rate by destination and payout type, at 1,000 or more decided attempts
| country_code | payout_type | decided | failed | failed_pct | providers |
|--------------|-------------|--------:|-------:|-----------:|----------:|
| EC           | BANK        | 1744    | 166    | 9.52       | 1         |
| NI           | BANK        | 3967    | 363    | 9.15       | 1         |
| CO           | CASH        | 1147    | 45     | 3.92       | 4         |
| HN           | BANK        | 24562   | 852    | 3.47       | 5         |
| GT           | BANK        | 34189   | 915    | 2.68       | 5         |
| CO           | BANK        | 24978   | 583    | 2.33       | 5         |
| SV           | BANK        | 6766    | 120    | 1.77       | 5         |
| NI           | CASH        | 8643    | 153    | 1.77       | 1         |
| SV           | CASH        | 8965    | 150    | 1.67       | 4         |
| CO           | WALLET      | 20117   | 304    | 1.51       | 2         |
| MX           | BANK        | 407719  | 5590   | 1.37       | 8         |
| GT           | CASH        | 51044   | 480    | 0.94       | 4         |
| MX           | CASH        | 97036   | 829    | 0.85       | 6         |
| HN           | CASH        | 36909   | 191    | 0.52       | 4         |
| DO           | BANK        | 1645    | 3      | 0.18       | 1         |
## M2 Each provider against its peers on the same destination and payout type
Peers exclude the provider itself. Routes where peers have under 1,000 decided attempts are left out, because the rate would be too thin to compare.
|  provider   | decided | failed_pct | compared_pct | compared_failed_pct | peer_failed_pct | failed_vs_peers | unsuccessful_vs_peers |
|-------------|--------:|-----------:|-------------:|--------------------:|----------------:|----------------:|----------------------:|
| PROVIDER 3  | 243025  | 1.44       | 100.0        | 1.44                | 1.27            | 1.14            | 0.59                  |
| PROVIDER 12 | 200850  | 1.37       | 92.0         | 1.06                | 1.33            | 0.8             | 1.3                   |
| PROVIDER 8  | 125717  | 0.44       | 97.9         | 0.45                | 2.34            | 0.19            | 1.02                  |
| PROVIDER 11 | 65763   | 1.94       | 100.0        | 1.94                | 1.28            | 1.52            | 0.74                  |
| PROVIDER 7  | 39437   | 2.98       | 100.0        | 2.98                | 1.19            | 2.51            | 1.22                  |
| PROVIDER 5  | 24514   | 2.83       | 98.8         | 2.74                | 4.21            | 0.65            | 0.23                  |
| PROVIDER 4  | 23407   | 1.93       | 14.1         | 4.47                | 1.35            | 3.32            | 2.73                  |
| PROVIDER 9  | 5164    | 3.74       | 100.0        | 3.74                | 1.97            | 1.9             | 0.56                  |
| PROVIDER 2  | 3395    | 7.48       | 100.0        | 7.48                | 1.32            | 5.67            | 4.15                  |
## M3 The largest gaps inside one route, at 3,000 or more decided attempts
| country_code | payout_type |  provider   | decided | failed | failed_pct |
|--------------|-------------|-------------|--------:|-------:|-----------:|
| CO           | BANK        | PROVIDER 11 | 3307    | 124    | 3.75       |
| CO           | BANK        | PROVIDER 9  | 5163    | 193    | 3.74       |
| CO           | BANK        | PROVIDER 12 | 4400    | 112    | 2.55       |
| CO           | BANK        | PROVIDER 8  | 9945    | 16     | 0.16       |
| CO           | WALLET      | PROVIDER 4  | 20116   | 304    | 1.51       |
| GT           | BANK        | PROVIDER 7  | 3335    | 265    | 7.95       |
| GT           | BANK        | PROVIDER 12 | 7176    | 261    | 3.64       |
| GT           | BANK        | PROVIDER 8  | 20102   | 299    | 1.49       |
| GT           | CASH        | PROVIDER 7  | 12667   | 230    | 1.82       |
| GT           | CASH        | PROVIDER 11 | 8845    | 139    | 1.57       |
| GT           | CASH        | PROVIDER 12 | 19654   | 104    | 0.53       |
| GT           | CASH        | PROVIDER 8  | 9878    | 7      | 0.07       |
| HN           | BANK        | PROVIDER 5  | 18101   | 534    | 2.95       |
| HN           | BANK        | PROVIDER 8  | 5655    | 129    | 2.28       |
| HN           | CASH        | PROVIDER 12 | 8260    | 37     | 0.45       |
| HN           | CASH        | PROVIDER 8  | 26453   | 10     | 0.04       |
| MX           | BANK        | PROVIDER 2  | 3395    | 254    | 7.48       |
| MX           | BANK        | PROVIDER 4  | 3291    | 147    | 4.47       |
| MX           | BANK        | PROVIDER 7  | 16905   | 326    | 1.93       |
| MX           | BANK        | PROVIDER 3  | 243025  | 3505   | 1.44       |
| MX           | BANK        | PROVIDER 11 | 42704   | 479    | 1.12       |
| MX           | BANK        | PROVIDER 12 | 96251   | 840    | 0.87       |
| MX           | CASH        | PROVIDER 11 | 4765    | 257    | 5.39       |
| MX           | CASH        | PROVIDER 12 | 46548   | 415    | 0.89       |
| MX           | CASH        | PROVIDER 8  | 42641   | 41     | 0.1        |
| NI           | BANK        | PROVIDER 12 | 3967    | 363    | 9.15       |
| NI           | CASH        | PROVIDER 12 | 8643    | 153    | 1.77       |
| SV           | BANK        | PROVIDER 5  | 4215    | 71     | 1.68       |
| SV           | CASH        | PROVIDER 8  | 4396    | 0      | 0.0        |
