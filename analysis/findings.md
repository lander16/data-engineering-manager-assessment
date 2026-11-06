# Data Profiling Findings

Extract window: 2026-01-01 00:00 to 2026-09-22 14:07 UTC. September is partial.

- **Observations** are measured facts. The script that produces each one is named in its section.
- **Hypotheses** are explanations the data does not prove. Each has a confidence level and a way to confirm it.
- **Implications** are the modeling decisions that follow.

## Observations

### File integrity

Source: `results/source_checksums.sha256`, `sql/00_setup.sql`

| Check | Result |
|---|---|
| Source files changed by profiling | No: checksums match before and after each run |
| Files parse under strict CSV settings | Yes, with explicit column lists |
| Encoding | ASCII only, no byte-order mark |
| Line endings | CRLF in all 3 files; no carriage returns leaked into values |

| File | Rows | Columns | Size |
|---|---:|---:|---:|
| `payments.csv` | 788,976 | 14 | 194 MB |
| `receipts.csv` | 743,948 | 13 | 289 MB |
| `disbursements.csv` | 743,763 | 13 | 194 MB |

### Completeness

Source: `sql/01_completeness.sql`

No column has empty strings, padded values, or null-like text such as `NaN` or `None`. Every other column not listed below is 100% populated.

| Column | Nulls | Share |
|---|---:|---:|
| `payments.error_code` | 788,976 | 100% |
| `payments.reason` | 788,976 | 100% |
| `payments.location_of_request_state_code` | 788,548 | 99.946% |
| `payments.total_intents` | 772,324 | 97.889% |
| `payments.detailed_status` | 2,745 | 0.348% |
| `payments.type` | 1 | under 0.001% |
| `disbursements.provider_status` | 579,607 | 77.929% |
| `disbursements.updated_at` | 816 | 0.110% |
| `disbursements.amount` | 568 | 0.076% |
| `disbursements.destination_country` | 137 | 0.018% |
| `disbursements.destination_currency` | 137 | 0.018% |

Nulls cluster by provider:

- All 137 null country and currency rows are Provider 3. These same rows also have null amount and `updated_at`.
- The other 431 null amounts are Provider 12 `failed` rows.
- Provider 5 accounts for 673 of the null `updated_at` values, mostly `rejected`.

Other population notes:

- `total_intents` only ever contains `1`.
- `location_of_request_state_code` is mostly on cash payments and has mixed formats, including `TX`, `US-TX`, `ROO`, `CMX`, and `ENG`.

### Keys and relationships

Source: `sql/02_keys_and_relationships.sql`

| Check | Result |
|---|---:|
| Duplicate primary keys, all files | 0 |
| Duplicate rows when ignoring `id`, all files | 0 |
| IDs not in 64-character lowercase hex format | 0 |
| Receipts without a payment | 0 |
| Receipts without a disbursement record | 185 |
| Disbursements without a receipt | 0 |
| Payments without a receipt | 60,749 |
| Disbursements on more than 1 receipt | 0 |
| `user_id` mismatches between files | 0 |
| Beneficiaries used by more than 1 user | 0 of 554,117 |

Receipts per payment: 0 for 60,749 payments, 1 for 715,012, and 2 to 8 for 13,215. Joining successful payments to receipts and summing `payments.amount` overstates volume by $6.54M: $244.27M instead of $237.73M (`sql/09_source_checks.sql`).

The 13,215 multi-attempt payments:

| Change across attempts | Payments |
|---|---:|
| Provider changed | 6,318 |
| Beneficiary ID changed | 2,987 |
| Exchange rate changed | 58 |
| Destination currency changed | 26 |
| Amount charged changed | 1 |
| Destination country changed | 1 |

The median time from first to last attempt is 88 minutes. The 90th percentile is 44 hours, and the maximum is 69 days.

A single beneficiary ID never spans countries, but 11,698 use more than one payer destination and 5,307 use more than one payout type.

### Statuses, types, and currencies

Source: `sql/03_categoricals.sql`

- Payment `status` has 5 clean values. `detailed_status` has 25 values and is null for 2,744 `REFUNDED` rows.
- Disbursement `status` has 21 spellings and 20 values after lowercasing. Vocabulary varies by provider. For example, Provider 3 alone uses `Success`.
- All payments are in USD.
- Receipts contain 11 countries and 9 currencies. Disbursements have one spelled-out country value, `COSTA RICA`, on 25 rows.
- USD payouts occur in SV, NI, and EC, and in part of DO, PE, and CR.
- `payer_destination_name` has 213 values. 17 of them span more than one country.

Where `status` and `raw_status` disagree in a way that changes meaning:

| Provider | `status` | `raw_status` | Rows |
|---|---|---|---:|
| Provider 3 | `Failed` | `cancelled` | 3,070 |
| Provider 12 | `CANCELLED` | `PAID` | 46 |
| Provider 4 | `CANCELLED` | `COMPLETED` | 18 |
| Provider 8 | `CANCELLED` | `CREATED` | 3 |

`COMPLETED` rows with provider status `HOLD:11102002` number 604.

### Numeric precision

Source: `sql/04_numeric_precision.sql`, `sql/07_followups.sql`

All values are plain decimals, with no scientific notation, thousands separators, leading zeros, or trailing zeros.

| Field | Max integer digits | Max decimals | Decimals needed | Rows beyond 2 decimals |
|---|---:|---:|---:|---:|
| `payments.amount` | 4 | 9 | 9 to keep source values | 827 |
| `receipts.amount_charged` | 4 | 2 | 2 | 0 |
| `receipts.fee` | 2 | 2 | 2 | 0 |
| `receipts.promotion_amount` | 3 | 2 | 2 | 0 |
| `receipts.exchange_rate` | 4 | 4 | 4 | 32, all PEN |
| `receipts.destination_amount` | 8 | 2 | 2 | 0 |
| `disbursements.amount` | 8 | 2 | 2 | 0 |

For `payments.amount`:

- 689 values have 8 or 9 decimals. Of these, 687 equal a 2-decimal value stored as a 32-bit float, such as `102.989997864` for `102.99`.
- 687 of the 827 values beyond 2 decimals are `CASH` payments.
- 138 values have 3 to 5 decimals, and none match the float pattern. Using the first receipt (`sql/09_source_checks.sql`):
  - 23 local-currency payouts equal `destination_amount / exchange_rate + fee` exactly.
  - 102 USD payouts tie to `amount_charged + fee` after rounding. Reverse FX can't explain these, because the rate is 1.
  - 13 have no receipt.
- Rounding all 827 to 2 decimals changes the total by less than $0.40.
- Totals differ by under $0.01 between exact decimals and doubles.

Ranges and anomalies:

| Observation | Rows |
|---|---:|
| `payments.amount` is 0 | 133 |
| `payments.amount` is negative: -0.90, status `STARTED` | 1 |
| `receipts.amount_charged` is negative: -522.99 | 1 |
| `receipts.destination_amount` is 0 | 1 |
| Destination value off by more than 1% of `(charged + promotion) × rate` | 7 |
| HN receipt with rate 16.86 or 17.54 against a median of 26.71 | 2 |
| DO receipts labeled USD with a rate of 56.24 or 58.27 | 2 |

Five receipts have a currency conflict or a USD rate other than 1 (`sql/09_source_checks.sql`). All their disbursements are `FAILED` or `CANCELLED`. Four of the payments are `REFUNDED`, and the $100 DO payment is still `SUCCESSFUL`.

Successful payments of $3,000 or more number 1,187. The largest is $3,418.80.

Accounting identities:

| Identity | Result |
|---|---|
| `payments.amount = amount_charged + fee` | 742,978 of 743,948 after rounding to cents |
| Most common gaps | +2.99 (420), +4.98 (158), -1.00 (141) |
| `(amount_charged + promotion_amount) × exchange_rate ≈ destination_amount` | All but 7 rows within 1% |

`receipts.destination_amount` and `disbursements.amount`:

- They differ by over half a unit on 172,010 rows.
- Gaps of that size appear only on Providers 8 and 12 among large provider and currency groups. The largest gap is about 1%.

### Timestamps

Source: `sql/05_timestamps.sql`

- All 3.8 million timestamp values match one format and use a `+00:00` offset.
- Fractions are always 6 digits, except 101 values with none.
- Every calendar day has payments. Daily counts range from 1,270 to 5,668, and the median is 2,866.
- The largest payment gap is 169 minutes on 2026-06-12, from 14:06 to 16:55 UTC. Only 2 receipts and 2 disbursements fall in that gap.
- `disbursements.updated_at` precedes `created_at` on 18 Provider 3 rows, by under 1 second. All 18 have an `updated_at` equal to `created_at` truncated to the second. Across the file, 99 `updated_at` values have no fraction: 98 Provider 3 and 1 Provider 7 (`sql/09_source_checks.sql`).
- Receipts and disbursements are usually created within 1 minute of each other, in either order. 110 rows differ by over 1 hour.
- Chargeback-flagged payments have a median `updated_at` lag of 0 days and a maximum of 3.8 days.
- Refunded payments have a median `updated_at` lag of 11.7 hours.

Moving delivered volume from UTC months to New York months shifts each month by under 1.1%. The largest shift is -$254K, in September.

**Reproducibility note:** the first run of the baseline script grouped months in this machine's time zone and produced a false `2025-12` month. All scripts now set UTC explicitly.

### Business baselines

Source: `sql/06_business_baselines.sql`, `sql/07_followups.sql`

Payment outcomes, totaling all 788,976 payments:

| Payment status | Payout outcome | Payments | USD |
|---|---|---:|---:|
| `SUCCESSFUL` | Delivered once | 720,611 | $237,070,321 |
| `SUCCESSFUL` | Delivered more than once | 19 | $5,516 |
| `SUCCESSFUL` | In flight or unknown | 1,279 | $563,020 |
| `SUCCESSFUL` | All attempts failed | 182 | $50,901 |
| `SUCCESSFUL` | No receipt | 1,961 | $40,690 |
| `REFUNDED` | All attempts failed | 6,106 | $2,653,985 |
| `REFUNDED` | No receipt | 86 | $33,584 |
| `REFUNDED` | In flight or unknown | 20 | $13,485 |
| `REFUNDED` | Delivered | 7 | $1,897 |
| `FAILED` | No receipt | 58,684 | $27,567,825 |
| `FAILED` | Delivered | 2 | $513 |
| `FAILED` | All attempts failed | 1 | $500 |
| `PENDING_USER_ACTION` | No receipt | 17 | $7,039 |
| `STARTED` | No receipt | 1 | -$0.90 |

Delivered volume by UTC month:

| Month | Remittances | Active users | USD |
|---|---:|---:|---:|
| 2026-01 | 54,755 | 48,571 | $16,679,288 |
| 2026-02 | 60,726 | 53,763 | $19,265,513 |
| 2026-03 | 75,052 | 65,735 | $24,753,796 |
| 2026-04 | 77,645 | 68,082 | $25,408,576 |
| 2026-05 | 92,746 | 80,753 | $30,303,038 |
| 2026-06 | 89,289 | 78,247 | $30,038,058 |
| 2026-07 | 96,149 | 83,850 | $32,372,631 |
| 2026-08 | 101,232 | 87,848 | $33,614,833 |
| 2026-09 (partial) | 73,036 | 66,207 | $24,640,105 |

Unresolved successful payments by age at the extract end:

| Outcome | Under 2 days | 2 to 30 days | Over 30 days | Chargebacks |
|---|---:|---:|---:|---:|
| In flight or unknown (1,279) | 755 | 368 | 156 | 0 |
| All attempts failed (182) | 20 | 52 | 110 | 9 |

All 109 `transmitted` disbursements are over 30 days old.

Of the 182 payments in the "All attempts failed" row, 37 ($18,527) have a `CANCELLED` attempt with raw `PAID` or `COMPLETED`, and no other delivered attempt (`sql/08_review_checks.sql`).

Delivered payouts on payments that are not `SUCCESSFUL` (`sql/09_source_checks.sql`):

| Payment status | Payments | USD | Details |
|---|---:|---:|---|
| `FAILED` | 2 | $513 | Both ACH with `FAILED_DUE_TO_INSUFFICIENT_FUNDS`; payment updated 2 to 5 days after creation |
| `REFUNDED` | 7 | $1,897 | All card, with no chargebacks; on 5, the payout's last update is after the payment's last update |

Ten ACH payments ($3,942) are `SUCCESSFUL` with detailed status `PENDING_USER_ACTION_ACH_SETTLEMENT`. They have 10 delivered attempts.

Promotions:

- 13,983 receipts have a promotion, totaling $746,479. The maximum is $620.
- 2,953 receipts are fully funded by promotion, with `amount_charged` of 0.
- Delivered attempts total $234.19M charged, $2.89M fees, and $0.72M promotions.
- Delivered value sent is therefore $234.91M, and customers paid $237.08M.
- Of the 2,953 fully funded receipts, 20 belong to users with an earlier refund.
- Of delivered attempts with a promotion, 9,414 are a user's first delivered attempt and 3,955 are later ones.

Successful payments without receipts start in June and grow quickly:

| Month | Payments | USD |
|---|---:|---:|
| 2026-06 | 29 | $539 |
| 2026-07 | 148 | $2,302 |
| 2026-08 | 733 | $13,292 |
| 2026-09 (partial) | 1,051 | $24,558 |

Their most common amounts are $1.00 (704), $24.75 (549), $37.25 (276), and $12.25 (153). They belong to 1,845 users, of whom 1,255 also have receipts.

Provider failure rates are in `results/06_business_baselines.md`. Retry attempts fail much more often than first attempts:

| Provider | First attempts | First-attempt failure | Retry attempts | Retry failure |
|---|---:|---:|---:|---:|
| Provider 3 | 241,034 | 0.17% | 2,014 | 0.99% |
| Provider 12 | 200,528 | 1.04% | 5,806 | 11.32% |
| Provider 8 | 126,785 | 0.30% | 5,022 | 3.52% |
| Provider 11 | 65,112 | 1.71% | 854 | 19.20% |
| Provider 7 | 39,111 | 2.66% | 708 | 18.93% |
| Provider 5 | 24,028 | 2.51% | 496 | 16.73% |
| Provider 4 | 22,997 | 1.66% | 429 | 16.08% |
| Provider 9 | 5,078 | 3.03% | 88 | 44.32% |
| Provider 2 | 3,119 | 4.42% | 277 | 41.88% |

Failures here use `raw_status` of `failed` or `rejected`. Under the adopted rule, Provider 3 is 1.32% on first attempts.

Of 18,313 payments with a failed or cancelled attempt, 11,975 also have a delivered attempt, and on 11,968 the delivery came after that attempt. The other 6,338 were never delivered.

Under a 2-month rule, the recurring share falls steadily with first delivered month: 61.1% for January, 37.4% for May, 11.4% for August, and 0% for September. With an equal 60-day window, the repeat rate falls much less: 32.9% for January and 26.1% for June (`sql/08_review_checks.sql`).

Failed-payment rate differs by method: card 7.35%, Apple Pay 10.27%, cash 46.46%, and ACH 35.48%. In all, 28,905 of 421,412 users never had a successful payment.

## Hypotheses

| # | Hypothesis | Evidence | Confidence | How to confirm |
|---|---|---|---|---|
| H1 | `beneficiary_id` is a sender-scoped recipient record, or was hashed per user. It is not a person key. | No sharing across 554,117 IDs; ID changes on 2,987 retries | High | Source owner review |
| H2 | Multi-receipt payments are payout retries and re-routes, not duplicates. | Same amount on all but 1; provider changes; failures precede success | High | Source owner review |
| H3 | The 8 and 9 decimal amounts come from a float32 column in a cash payment path. | 687 match the float32 pattern; cash dominates | High | Source system review |
| H4 | The 138 amounts with 3 to 5 decimals come from calculated amounts that were not rounded: reverse-FX quotes on local payouts, and sub-cent fees on USD payouts. | 125 of 138 tie to a calculation; the fee formula is unknown | Medium | Source system review |
| H5 | Provider 3's `Failed` with raw `cancelled` is a mapping choice, so the provider did not fail technically. | Other providers keep `cancelled` as a distinct status | Medium | Source owner review |
| H6 | `CANCELLED` with raw `PAID` or `COMPLETED` means an internal cancel or reversal after the provider reported payment. | 60 of these 64 rows sit on `SUCCESSFUL` payments | Medium | Source owner review |
| H7 | Successful no-receipt payments are another product, or a card validation. | They begin in June, grow, and repeat fixed amounts | Medium | Source owner review |
| H8 | `promotion_amount` holds more than marketing discounts, possibly credits or referral balances. | Values up to $620; refund credit explains few cases | Medium | Source owner review |
| H9 | Payment and receipt gaps of +2.99 and +4.98 are fees collected on the payment but waived on a retry receipt. | Gaps equal standard fees | Medium | Compare within retry chains |
| H10 | Differences between receipt and disbursement amounts on Providers 8 and 12 come from provider-side FX or rounding. | Limited to 2 providers; gaps stay near or under 1% | Medium | Provider documentation |
| H11 | `provider_status` is the last raw provider message, so it can be stale. | 604 `COMPLETED` rows show a hold code | Medium | Source system review |
| H12 | Old `transmitted` rows are stale statuses, not real in-flight payouts. | All 109 are over 30 days old | Medium | Source owner review |
| H13 | The chargeback flag comes from another process and does not touch `updated_at`. | Flagged rows show no update lag | Medium | Source owner review |
| H14 | The June 12 gap is a pause in activity or a missing data window. | 169 minutes against about 2 payments per minute | Medium | Compare with incident records |
| H15 | The 2 `FAILED` payments with payouts are ACH settlement bounces: paid out first, then failed when funds did not settle. | Both are ACH, insufficient funds, and updated days later | High | Source system review |
| H16 | Some refunds overlapped payouts that were still open. | 5 of 7 show the payout updating after the payment | Low | Ledger or operations review |
| H17 | Whole-second `updated_at` values come from a separate write path or provider callback. | Nearly all are Provider 3 | Low | Source system review |

### Hypothesis updates from the assumption research

Scripts 10 to 14 tested these against the data, and script 15 rechecked the figures that changed. Adopted assumptions are in [docs/02-assumptions-and-rules.md](../docs/02-assumptions-and-rules.md).

| # | Update | Confidence now |
|---|---|---|
| H1 | Supported: IDs behave like a sender's saved recipient record, and no honest cross-user link exists | High |
| H5 | Reversed in part: Provider 3's rows behave like its fast failures, so `status` is the better provisional reading. This doesn't prove which source is authoritative | Medium to high |
| H6 | Refined: the 36 Provider 12 rows may have been delivered. The Provider 4 rows are one event on 2026-01-22, retried within seconds | Medium to high |
| H7 | Supported that nearly all aren't ordinary remittances. Many look like scheduled charges on saved cards, but not all do, and subscriptions can't be ruled out. The product is unknown | High on "not remittances", low on the product |
| H8 | Refund credit rejected. Partial promotions under $50 look like coupons, and fully funded ones are unexplained. The funder is unknown | High on the rejection |
| H13 | Consistent: flags don't touch `updated_at` or `status` | Medium |

New hypotheses:

| # | Hypothesis | Evidence | Confidence | How to confirm |
|---|---|---|---|---|
| H18 | `failed` and `cancelled` aren't comparable across providers | Provider 12's `cancelled` label ends on 2026-08-10 with steady non-delivery; Provider 8 uses `failed` only for instant rejections | High | Provider mapping review |
| H19 | Attempts cancelled with raw `PAID` or `COMPLETED` and then delivered on a later attempt need review against provider records | 23 payments, $7,315.48: 17 Provider 4 rows on 2026-01-22 retried on Provider 3, and 6 Provider 12 retries | Low | Provider statement |
| H20 | Chargeback flags usually lag payments | 0 flags on 28,728 card payments under 8 days old, where about 20 would be expected. This doesn't set a minimum delay, because payment age at extract end isn't a flag date | Medium | A dispute date |

### Later checks

Script 15 also covers these (`R11` to `R15`):

- 97 delivered remittances have a $0 payment, on 96 users, with $11,494 of value sent. 35 users have only these.
- The 887-row payment gap breaks down as 717 receipts with a $0 fee (+$3,141.25), 146 receipts higher than the payment (−$194.20), and 24 other (+$23.90).
- 753 disbursements were created over a minute before their receipt, the longest by 69 days. The cause is unknown. Ordering attempts by disbursement time would change the first attempt on 3 payments.
- No disbursement is on two receipts, and every disbursement has a receipt.
- Returning senders rise from 17.1% of active senders in February to 56.0% in September, partly because activity before January isn't visible.
- Script 16 compares recurring definitions. Calendar months favor late-month starters (17.8% against 26.8% within 60 days), while a 60-day repeat is flat at about 28%. Both predict later activity about equally, so the adopted rule is a gap of over 1 day and at most 90 days: 133,760 users. 1,289 users have 2 or more sends with every gap within 1 day, so they don't qualify.

## Implications

| Area | Decision |
|---|---|
| Raw layer | Load all columns as text, with load metadata. Keep the raw values unchanged. |
| USD amounts | `payments.amount` stays `DECIMAL(18,9)` in staging, because not every sub-cent value is an artifact. Other USD amounts are `DECIMAL(18,2)`. |
| Local amounts | `DECIMAL(18,2)`. Never sum across currencies. |
| Exchange rate | `DECIMAL(18,4)`. |
| Timestamps | Timezone-aware UTC. Derive months in UTC explicitly. |
| Deduplication | Keep the logic for repeated loads. The latest file wins, then `updated_at`, using `created_at` when it is null. Treat 0 rows removed as the expected result here. |
| Retries | Keep every attempt. Roll up to one row per payment, keeping payments without attempts. |
| Status | Use one standardized mapping, with a test that catches unknown values. |
| Country | Map `COSTA RICA` to `CR`; use the receipt's country and currency as the primary values. |
| Promised local amount | Use the receipt, and keep the disbursement amount for provider analysis. |
| Dropped columns | Exclude `error_code`, `reason`, and `total_intents` from later layers. Keep them in raw. |
| Test severity | Use errors for keys and grain. Use warnings for known source issues. |
| Chronology | Compare `updated_at` with `created_at` truncated to the second, so truncation is not reported as a reversal. |
| Payment status | Treat it as the latest state, not a final one. ACH payments can fail after payout. |

## Verification

A separate Python script, using only the standard library and exact decimals, re-derived the key values without DuckDB and without reading the SQL. It covers row counts, nulls, precision, volume, payment outcomes, beneficiaries, providers, chargebacks, concentration, recurring users, promotions, and retry rescue.

- Results: [verification/independent_check_results.md](verification/independent_check_results.md).
- Its first run found 13 USD differences below $0.0001. A `DECIMAL(18,6)` helper in `sql/00_setup.sql` was truncating float32 amounts. The helper now keeps 9 decimals, and the totals match exactly.
- The DuckDB comparison values in that script are transcribed from `results/`. After changing the SQL, update them before rerunning.
- It predates scripts 08 to 16, so figures unique to them are not independently verified, apart from the recurring count.
- The verification does not test the hypotheses above. Only source-system evidence can do that.
