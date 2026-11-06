# Assumptions and Rules

The assessment leaves these definitions open, so each one below is an **adopted assumption**: a reasoned choice for this assessment, not a fact about Félix's business.

Evidence comes from `analysis/sql/10` to `16`, with results in `analysis/results/`. Scripts 10 to 14 used an earlier status rule; section 10 explains what that affects.

## 1. Adopted assumptions

| ID | Topic | Adopted assumption | Result | Limitation |
|---|---|---|---|---|
| A1 | Headline amount | Customer-paid amount on delivered remittances, with value sent beside it | $237.08M against $234.90M | Félix may report another figure |
| A2 | Promotions | An additional component of quoted value sent: inside value sent, outside customer-paid | $0.72M | The funding source is unknown |
| A3 | Zero-amount remittances | Delivered payments of $0 count as delivered remittances, because they carry value sent | 97 remittances, $11,494 of value sent, $0 customer-paid | 35 users have only these, so they count as users with delivered remittances and add no volume |
| A4 | No-receipt payments | Excluded from remittances, because there's no payout evidence, and monitored by amount family | 1,961 payments, $40.7K | The product is unknown, and a few may be late receipts |
| A5 | Recurring customer | Two consecutive delivered remittances more than 1 day and at most 90 days apart, with a 90-day repeat rate by cohort beside it | 133,760 users (34.2%) | Recent users have had less time to qualify, so comparisons use the cohort rate. Someone with no gap over 1 day never qualifies, which affects 1,289 users |
| A6 | Top-user window | Full extract, plus each month's concentration | 59,511 of 391,244 users; 13.1% to 14.1% a month | Favors tenure, and it isn't a stable VIP list |
| A7 | Beneficiary clusters | Literal output on all observed pairs, segments on first observed attempts, and no proxy links | 0 shared | `beneficiary_id` is treated as a sender's saved record |
| A8 | Status conflicts | `status` decides, and `raw_status` only raises a conflict flag | 3,137 flagged rows; Provider 3 is 1.44% `medium` | Supported by behavior, not proven. 37 payments ($18,527) may have been delivered and stay excluded |
| A9 | Provider classes | Failed rate under 1% is `low`, under 3% is `medium`, otherwise `high`; under 1,000 attempts is `insufficient_volume`. A second class uses the unsuccessful terminal rate | Providers 7, 8, and 12 are label-sensitive | The thresholds are a convention, and `failed` and `cancelled` aren't comparable across providers |
| A10 | Chargebacks | The flag means a dispute was raised, whatever the outcome. Settled payments are the denominator, by payment month | 526 of 730,271 = 0.072% | There's no dispute date or outcome |
| A11 | Chargeback maturity | A month is mature 120 days after it ends. Section 8.3 gives the reasoning | January to April: 0.079% | Outside knowledge about dispute windows, not measured from the data |
| A12 | In-flight payouts | `SUCCESSFUL` payments whose payout isn't confirmed stay out of the headline, and `all_successful_payments_usd` sits beside it | 1,279 payments, $563K | Some will deliver later, so recent months can rise |

### Foundations

| ID | Decision |
|---|---|
| S1 | A remittance is one payment. An attempt is one receipt plus its disbursement. |
| S2 | `fct_remittances` keeps all payments, and eligibility flags decide what each metric uses. |
| S3 | A delivered remittance is a `SUCCESSFUL` payment with at least 1 delivered attempt, counted once. |
| S4 | `payments.amount` stays exact in staging. Rounding happens only in tests and display. |
| S5 | The primary attempt is the earliest delivered attempt, and it supplies payment-level fee and promotion. |
| S6 | Failed rate is `failed / (delivered + failed)`, and cancellations have their own rate. |
| S7 | No `fct_` model exists without added logic. |
| S8 | Raw data loads through `dbt run-operation load_raw`. |
| S9 | Months use UTC, set explicitly. |
| S10 | No-receipt payments stay in `fct_remittances` and are excluded from delivered metrics. |

## 2. Why each definition was chosen

The assessment leaves these open, so each row records the choice and the reasoning.

| ID | What was ambiguous | Options considered | Why this choice |
|---|---|---|---|
| A1 | What "amount transacted" counts | All rows ($268.0M), `SUCCESSFUL` payments ($237.73M), delivered customer-paid ($237.08M), delivered value sent ($234.90M) | A remittance is transacted when the money reaches the beneficiary, so delivery is required. Customer-paid comes straight from one payment row, and the two delivered measures differ by about 1% with the same trend |
| A2 | Whether promotions are transacted value | Add to the headline, ignore them, or report them separately | The arithmetic shows promotions in the quoted value, so value sent includes them. The customer didn't pay them, so customer-paid doesn't. Their funder is unknown, so nothing claims one |
| A3 | Whether a $0 payment is a remittance | Exclude, as a non-transaction, or keep | These payments delivered $11,494 of value, so a remittance did happen. Keeping them adds nothing to volume and changes recurring by only 20 users |
| A4 | Whether successful payments with no receipt are remittances | Count, as missing receipts, or exclude | A receipt is the only payout evidence. The exclusion rests on that fact, so it needs no theory about the product |
| A5 | What "recurring" means | Any 2 sends, 2 or 3 calendar months, a 60 or 90-day gap | A habit is about time between sends, so a day window measures it directly. Calendar months depend on where a first send falls in the month, and they count two sends 8 months apart. 90 days keeps a monthly sender who skips one month, and it covers 83.9% of gaps against 70.8% for 60. The 1-day floor keeps split same-day sends out |
| A6 | Over which period to rank top users | Full extract, or each month | The assessment asks for users, so the full extract answers it. Monthly concentration sits beside it, because a month's top group barely repeats |
| A7 | How to cluster users when no beneficiary is shared | Literal output, proxy links through payer or amount, or segments | The literal answer is correct and empty. Proxy links would be invented: payers are institutions, and shuffled data explains about 91% of the best rule's pairs. Segments give a useful answer to a different question, and they're labeled that way |
| A8 | Which status field wins | `status`, `raw_status`, or a rule mixing both | Provider 3's conflict rows behave like its failures, not like cancellations. One rule is also easier to test, and every conflict stays flagged |
| A9 | Whether cancellations count as failures, and what classes mean | Failed only, failed plus cancelled, absolute thresholds, or relative ranks | The assessment asks about failures, so `failure_class` uses that. Labels differ by provider, so a second class stops a label choice from looking like reliability. Absolute thresholds keep a class stable when the provider mix changes |
| A10 | What the flag means, and the denominator | Any dispute or lost disputes only; delivered, settled, or card payments | A dispute attaches to a captured charge whatever happened to the payout, so settled payments fit. Nothing in the data separates won from lost, so the widest reading is the honest one |
| A11 | When a month's chargeback rate can be trusted | 60, 90, or 120 days | The data can't separate them. Dispute windows commonly run to about 120 days, reading too early understates risk, and the flag removes no data |
| A12 | Whether unconfirmed payouts count | Count all `SUCCESSFUL` payments, or wait for delivery | Same reasoning as A1. 755 of the 1,279 are under 2 days old, so most are simply recent, and `all_successful_payments_usd` keeps the difference visible |

## 3. Decisions driven by the data

These came from profiling, not from a preference. Each one prevents a specific wrong answer.

| Finding | Decision | What it prevents |
|---|---|---|
| 13,215 payments have 2 to 8 receipts | Two grains: payment and attempt | $6.54M of overstated volume from joining payments to receipts |
| 60,749 payments have no receipt | Start `fct_remittances` from payments, with a left join | Losing those payments from reconciliation |
| Receipts on a retry are real attempts | Deduplicate on ID only | Removing retries as duplicates |
| 19 payments have 2 delivered attempts | A primary attempt, the earliest delivered, supplies fee and promotion | Counting fee or promotion twice |
| 138 amounts have 3 to 5 decimals that aren't float artifacts | `payments.amount` stays `DECIMAL(18,9)` | Rounding away source values in staging |
| Status vocabularies vary by provider, with 20 values | One ordered `CASE`, with a test that fails on any new value | A new status silently falling into a class |
| In-flight and missing attempts have no final result | Failed rate uses `failed / (delivered + failed)` | Diluting a provider's rate with unfinished attempts |
| Retries fail far more often than first attempts | A first-attempt rate sits beside the overall rate | Blaming fallback providers for harder cases |
| All 185 unmatched receipts carry an orphan ID | `missing` tests the joined disbursement | Those rows failing the build as `unknown` |
| 185 missing attempts have no provider | The provider mart excludes them | A null provider row |
| 2,060 users have IDs created only by retries | Segments use first observed attempts, and all pairs stay | Inflated segments, or a hidden shared beneficiary |
| The chargeback flag doesn't appear to move `updated_at` | Newer files win over `updated_at` in deduplication | Missing a late chargeback |
| Input order can decide between two rows tied on ID, file, and timestamp | The build fails on a conflicting tie, and identical rows collapse | A result that depends on row order |
| `updated_at` is null on 816 rows and earlier than `created_at` on 18 | Fall back to `created_at`, and compare at whole seconds | False chronology errors |
| All 18 chronology reversals are whole-second truncations | The chronology check truncates `created_at` | Reporting rounding as bad data |
| Grouping by month followed the session time zone | Months are `DATE` values, computed in UTC | A false December 2025 month |
| UTC and New York months differ by under 1.1% | UTC stays the reporting month | Adding a time zone decision for little effect |
| Median payment to disbursement time is about 5.5 seconds | Volume uses the payment month | A second date rule with no real difference |
| 137 null countries and 25 `COSTA RICA` values on disbursements | The receipt supplies country, and `COSTA RICA` maps to `CR` | Lost or split corridors |
| `error_code` and `reason` are empty, and `total_intents` holds only `1` | They stay in raw and leave later layers | Carrying columns with no information |
| Payment status can change after payout | It's treated as the latest state, and exceptions are named | Reading it as final |

## 4. Status rules

### 4.1 Attempt status

Applied in order, on lowercase values:

| Order | `attempt_status` | Condition |
|---:|---|---|
| 1 | `missing` | The receipt has no matching disbursement record; all 185 carry an ID that points to nothing |
| 2 | `cancelled` | `status` is `cancelled` |
| 3 | `delivered` | `status` is `paid`, `success`, `completed`, or `delivered` |
| 4 | `failed` | `status` is `failed`, `rejected`, `error_sending_payout_request`, or `payout_not_processed` |
| 5 | `in_flight` | `status` is `payable`, `wire_released`, `wire_confirmed`, `transmitted`, `in_progress`, `pending`, `to_be_processed`, `on_hold`, `hold_by_compliance`, `hold_by_payer`, or `cancellation_in_progress` |
| 6 | `unknown` | Anything else; a test fails the build if any row is here |

`status` decides. `status`, `raw_status`, and `provider_status` all stay on the attempt, and `status_conflict_type` records disagreements without changing the result:

| `status_conflict_type` | Source combination | Rows | `attempt_status` | Note |
|---|---|---:|---|---|
| `failed_raw_cancelled` | `Failed` with raw `cancelled` | 3,070 | `failed` | All Provider 3; they close as fast as its other failures |
| `cancelled_raw_paid` | `CANCELLED` with raw `PAID` or `COMPLETED` | 64 | `cancelled` | 37 with no delivered attempt, 23 delivered on a later attempt, 4 refunded |
| `cancelled_raw_created` | `CANCELLED` with raw `CREATED` | 3 | `cancelled` | Probably cancelled before sending |

Attempts are ordered by the receipt's `created_at`, then `receipt_id`. The first one is called the first observed attempt, because a retry history may not be complete. It's a different idea from the primary attempt, which is the earliest delivered one. 753 disbursements were created over a minute before their receipt, but ordering by disbursement time would change the first attempt on only 3 payments.

### 4.2 Payout outcome

Applied in order, per payment:

| Order | `payout_outcome` | Condition | Payments |
|---:|---|---|---:|
| 1 | `no_receipt` | No attempts | 60,749 |
| 2 | `multiple_delivered` | 2 or more delivered attempts | 19 |
| 3 | `delivered` | Exactly 1 delivered attempt | 720,620 |
| 4 | `in_flight` | Any in-flight attempt | 1,281 |
| 5 | `missing_payout` | Any missing attempt | 18 |
| 6 | `not_delivered` | All attempts failed or cancelled | 6,289 |

The outcome describes the payout only. Metric eligibility combines it with payment status, so the 9 `FAILED` or `REFUNDED` payments with a delivered attempt stay visible without counting as volume.

Payment status is the latest state in this extract, not a final one. ACH payments can fail after payout, so the 10 `SUCCESSFUL` ACH payments pending settlement ($3,942) count as delivered for now and are monitored.

## 5. Money rules

| Measure | Source | Grain | Total on delivered remittances |
|---|---|---|---:|
| `customer_paid_usd` | `payments.amount`, counted once | Payment | $237,075,837 |
| `value_sent_usd` | Primary attempt: `amount_charged + promotion_amount` | Payment | $234,902,590 |
| `fee_usd` | Primary attempt | Payment | $2,891,351 |
| `promotion_usd` | Primary attempt | Payment | $721,075 |
| `extra_delivered_value_usd` | Delivered attempts after the primary | Payment | $5,480 on 19 payments |

Rules:

- Payment-level measures never sum across attempts. Promotions repeat on retries: the amount is the same on every attempt of a payment.
- Attempt-level economics stay on `int_payout_attempts` as quoted values.
- `customer_paid_usd` does not always equal `value_sent_usd + fee_usd - promotion_usd`. On 887 delivered remittances, the payment doesn't tie to the primary attempt, for a net $2,971. On 717 of them the receipt shows a $0 fee while the payment includes one (+$3,141), so `fee_usd` is understated by about $3.1K. A warning test tracks this, and the fee isn't corrected.
- Local amounts are never summed across currencies.
- Promotions are treated as an additional component of quoted value sent. The funding source is unknown.

## 6. Types

| Fields | dbt-duckdb type | BigQuery equivalent |
|---|---|---|
| IDs and categorical fields | `VARCHAR` | `STRING` |
| `payments.amount` | `DECIMAL(18,9)` | `NUMERIC` |
| Other USD and local amounts | `DECIMAL(18,2)` | `NUMERIC` |
| `exchange_rate` | `DECIMAL(18,4)` | `NUMERIC` |
| `created_at`, `updated_at` | `TIMESTAMPTZ` | `TIMESTAMP` |
| Chargeback flag | `BOOLEAN` | `BOOL` |

Deduplication keeps one row per `id`: the row from the latest file wins, then the latest `updated_at`, with `created_at` as the fallback. File order comes first because setting the chargeback flag doesn't appear to move `updated_at`. It removes 0 rows on this extract, and retries are not duplicates.

Identical rows collapse. Two different rows tied on ID, file, and timestamp fail the build, because no rule can say which state is right and input order would otherwise decide. This extract has none.

## 7. Metrics

Eligibility flags on `fct_remittances`:

| Flag | Condition | Rows |
|---|---|---:|
| `is_delivered_remittance` | `SUCCESSFUL` and outcome is `delivered` or `multiple_delivered` | 720,630 |
| `is_chargeback_eligible` | Status is `SUCCESSFUL` or `REFUNDED` | 730,271 |
| `is_successful_without_receipt` | `SUCCESSFUL` and outcome is `no_receipt` | 1,961 |

### Metric definitions

| Metric | Definition |
|---|---|
| Amount transacted | Sum of `customer_paid_usd` where `is_delivered_remittance`, by UTC month of the payment. The mart also shows value sent, fee, promotion, counts, `all_successful_payments_usd`, and `is_partial_month`. |
| Top users | Top 50% of extract volume: users ranked by delivered `customer_paid_usd`, with `user_id` as the tie-break. `top_50_pct_volume` includes the user who crosses 50%. |
| Monthly concentration | `top_50_pct_user_share`: the share of a month's senders who make 50% of that month's volume. |
| Monthly senders | `active_senders` had a delivered remittance in the month. `first_seen_senders` had their first one in the extract, and `returning_senders` had an earlier one. All January senders are first seen because earlier activity isn't visible, so the returning share rises partly by construction. |
| Recurring | `is_recurring`: two consecutive delivered remittances more than 1 day and at most 90 days apart. |
| Comparable retention | Share of a cohort with another delivered remittance from over 1 day to 90 days after the first. Reported only for users with a full 90-day window. It starts from the first send, while `is_recurring` looks at every gap between consecutive sends. |
| Provider failed rate | `failed / (delivered + failed)`, for all attempts and first observed attempts. In-flight and missing attempts are excluded. |
| Provider cancelled rate | `cancelled / (delivered + failed + cancelled)`. |
| Unsuccessful terminal rate | `(failed + cancelled) / (delivered + failed + cancelled)`. This counts outcomes, and doesn't blame the provider for every cancellation. |
| Provider failure class | `failure_class` uses the all-attempt failed rate, and `unsuccessful_class` uses the unsuccessful terminal rate, with the thresholds in A9. `is_label_sensitive` is true when they differ. |
| Shared beneficiaries | Beneficiary IDs with more than 1 distinct user, across all observed attempts. |
| Beneficiary segment | Distinct beneficiaries per user on first observed attempts: `none`, `1`, `2-3`, `4-9`, or `10+`. |
| Chargeback count rate | Flagged payments divided by payments with status `SUCCESSFUL` or `REFUNDED`, by payment month. |
| Chargeback value rate | `flagged_payment_value_usd` divided by the value of the same eligible payments. This is the payment value, not confirmed disputed or lost money. |
| Chargeback maturity | `is_mature` is true when month end plus 120 days is on or before the extract end. |

Provider classes are the same under all-attempt and first-observed rates on this extract. Providers 5 and 7 are within sampling noise of 3% on all attempts, and clearly `medium` on first observed attempts.

## 8. Evidence

### 8.1 Money

#### Promotions

- **The quoted value includes the promotion.** On all 2,953 fully funded receipts, the destination amount ties to the promotion, and the payment equals only the fee on 2,942 of them. This shows what was quoted. It doesn't show who funded the promotion, and it isn't separate proof of what the beneficiary received.
- **Refund credit isn't the driver.** 0.66% of fully funded payments have an earlier refund, against 0.64% of ordinary payments.
- **There are at least two kinds.** Partial promotions under $50 look like marketing coupons: fixed tiers, and 77% on the first payment. Fully funded ones are capped at $600 and grew from 143 to 623 a month. The data doesn't show what those are.

#### Headline amount

- The 50% group is 59,511 users on customer-paid and 59,100 on value sent, and 996 of the top 1,000 stay the same.
- January to August growth is 101.54% against 101.75%, so the trend doesn't change.
- The primary-attempt rule doesn't affect the total. Earliest delivered, last delivered, and first attempt agree within $0.01.

Customer-paid stays the headline because it comes straight from one payment row. If a reader wants the value quoted to beneficiaries, value sent is the better number, and it sits in the next column.

#### No-receipt payments

| Family | Payments | USD | Pattern |
|---|---:|---:|---|
| `6.25 × n − 0.25` ($12.25, $24.75, $37.25) | 1,173 | $36,019 | 66% on Saturdays, 60% at 11:00 UTC |
| $1.00 | 704 | $704 | No schedule |
| Other | 84 | $3,967 | Includes 8 remittance-shaped amounts from September 18 to 22 |

The exclusion rests on one fact: these payments have no payout evidence. It doesn't need a theory about the product. The patterns below are suggestive only:

- **Many look scheduled.** In the `6.25 × n − 0.25` family, failures are 87% insufficient funds and retry daily with the same amount, which fits a saved card charged automatically. The $1.00 family has no such schedule, so this doesn't cover every record.
- **Most don't look like late receipts.** 99.9% of receipts appear within 12 minutes, and the oldest batch charge is 52 days old. Only 1.6% fall within an hour of a delivered remittance. The 8 remittance-shaped amounts from the final days could still be missing receipts.
- **No clear subscription pattern.** 94% of these users have just one such payment, but only about 8 weeks are visible, so a subscription can't be ruled out.
- **Unknown:** what the product is. The documentation should say so instead of naming one.

### 8.2 Users

#### Beneficiaries

- **`beneficiary_id` behaves like a sender's saved recipient record.** 53% of repeat payments reuse an earlier ID, and IDs never span countries.
- **`payer_destination_name` is an institution, so it can't link people.** 118 payer and country combinations have 21 or more users each.
- **A proxy link isn't honest.** The best rule (same payer, type, and exact amount within 10 minutes) gives 14,439 user pairs, but shuffled data explains about 91% of them.
- **No velocity outliers.** The most new IDs any user added in 24 hours is 3.

Counting first observed attempts stops retries from inflating segments, because 2,060 users have 2,098 extra IDs created only by retries. This suits a segment about initial recipient choices. It isn't a correction to beneficiary identity, so `int_user_beneficiaries` keeps all 554,117 pairs with an `is_on_first_attempt` flag, and only the segment filters on it. Otherwise a shared beneficiary reached only on a retry would vanish from the literal output.

| Beneficiaries | All attempts | First observed attempts |
|---|---:|---:|
| 1 | 289,700 | 290,806 |
| 2 to 3 | 92,942 | 92,088 |
| 4 to 9 | 12,044 | 11,796 |
| 10 or more | 94 | 90 |

#### Recurring customers

- Sending is weekly in rhythm, with peaks at gaps of 7, 14, 21, and 28 days and a median of 33 days.
- No rule predicts future sending well: balanced accuracy is 59% to 62% across the options.

The comparison after the top-user findings shows why a day window was chosen.

#### Top users

- **The message is stable.** About 13% to 15% of users make 50% of volume, in every month and overall.
- **The people aren't.** Only 3.3% to 5.6% of a month's top group is still in it the next month, and 83% of those user-months are a single remittance.
- **Full extract favors tenure.** 21.2% of January's cohort are top users, against 10.0% of August's. With equal 90-day exposure the share is flat, at 13.6% to 16.5%.

So the output should say "top 50% of extract volume" and not imply a stable VIP group.

#### Calendar months against day windows

| Rule | Users | Share |
|---|---:|---:|
| Delivered in 2 or more calendar months | 144,758 | 37.0% |
| **Two consecutive delivered remittances more than 1 day and at most 90 days apart (adopted)** | **133,760** | **34.2%** |
| Two consecutive delivered remittances more than 1 day and at most 60 days apart | 117,010 | 29.9% |

- **Calendar months have a real bias.** Within the same 60 days, the 2-month rule qualifies 17.8% of users who start in a month's first week and 26.8% of those who start in the last. A 60-day repeat is flat at 27.9% to 28.3%.
- **The month rule also misses the idea of a habit.** Sends on January 31 and February 1 qualify, and so do two sends 8 months apart. 25,558 users qualify on months but have no gap of 90 days or less.
- **Prediction is about equal.** Read on a user's first 90 days, the 2-month rule gives 37.6% later activity against 18.0%, and a repeat within 90 days gives 36.3% against 17.3%.
- **90 days fits the rhythm better than 60.** 70.8% of gaps are within 60 days and 83.9% within 90, and the 75th percentile is 68 days, so 60 would drop a monthly sender who skips one month.
- **The 1-day floor has an edge.** 26,830 users have 2 or more sends and don't qualify. 25,541 of them have a gap over 90 days. The other 1,289 have every gap within 1 day, so someone sending about once a day never qualifies. Only 17 of those users have 3 or more sends, so the definition stays.
- **Recent users have had less time.** August's cohort is 17.7%, so comparisons use a full window: 36.9% repeat within 90 days, among the 268,255 users who have one. By cohort that runs from 41.9% for January to 34.2% for June.

### 8.3 Providers and chargebacks

#### One rule for status conflicts

An alternative lets `raw_status` override `status` in some cases, and it was the first rule tried. The evidence supports a simpler one: **`status` decides, and `raw_status` only raises a conflict flag.** The behavior supports this without proving which source is authoritative, so it stays a provisional rule, and all 3,137 conflicts stay visible.

- **Provider 3's 3,070 rows behave like failures.** They close in a median of 0.47 minutes, with 95% within 5 minutes. That matches Provider 3's other failures (0.36 minutes), and not the cancellations at Provider 8 (146 minutes) or Provider 12 (223 minutes).
- **`CANCELLED` with raw `PAID` needs a closer look, but it's tiny.** 90% of those payments were never refunded, against 1.7% after plain cancels, so they may have been delivered. Staying with `status` excludes 37 payments and $18,527, which appear by name in `mart_known_issues`.
- **Cancelled, then delivered on another attempt.** On January 22, 18 Provider 4 rows ($4,562.58) were cancelled with raw `COMPLETED`. 17 of them ($4,159.59) were retried within seconds and delivered by Provider 3. The data can't show what the first provider did.
- **The issue is defined by the pattern, not the provider.** `cancelled_then_delivered` is a `cancelled_raw_paid` attempt followed by a delivered attempt on the same payment. That gives 23 payments ($7,315.48): the 17 above, plus 6 at Provider 12 that retried on Provider 12 between January and April. The 18th Provider 4 row had no retry, so it's among the 37.

All 64 rows with raw `PAID` or `COMPLETED` are accounted for: 37 with no delivered attempt, 23 delivered on a later attempt, and 4 refunded.

#### Provider classes

**The `failed` and `cancelled` labels aren't comparable across providers.**

- **Provider 12's labels shift during the year.** Its monthly failures rise from 76 to 620, its cancellations fall from 797 to 0, and the last one is on August 10. Non-delivery stays at 3.4% to 4.2%.
- **Provider 8 uses `failed` only for instant rejections.** They close in about a minute or less, and everything slower is `cancelled`. So its 0.44% failed rate sits beside 4.77% non-delivery.
- **Cancellations don't look user-driven,** though this is medium confidence. They show no user propensity or resend difference, and rates differ by provider within the same country and payout type. Only about 4% have an identifiable non-provider cause, and 73.7% can't be classified.

The second rate is the **unsuccessful terminal rate**: `(failed + cancelled) / (delivered + failed + cancelled)`. The name is deliberate, because it counts outcomes and doesn't blame the provider for every cancellation.

| Provider | Failed rate | Failed class | Unsuccessful terminal rate | Unsuccessful class | Label-sensitive |
|---|---:|---|---:|---|---|
| 3 | 1.44% | `medium` | 1.44% | `medium` | No |
| 8 | 0.44% | `low` | 4.77% | `high` | **Yes** |
| 12 | 1.37% | `medium` | 3.78% | `high` | **Yes** |
| 11 | 1.94% | `medium` | 1.94% | `medium` | No |
| 4 | 1.93% | `medium` | 2.00% | `medium` | No |
| 5 | 2.83% | `medium` | 2.87% | `medium` | No |
| 7 | 2.98% | `medium` | 3.34% | `high` | **Yes** |
| 9 | 3.74% | `high` | 3.74% | `high` | No |
| 2 | 7.48% | `high` | 7.48% | `high` | No |

`failure_class` stays on the failed rate, because that's what the assessment asks for. `unsuccessful_class` and `is_label_sensitive` sit beside it.

**Thresholds:** 1% and 3% stay as a labeled convention. The 1% line falls in a real gap on failed rates. The 3% line doesn't: the 95% Wilson intervals for Provider 5 (2.63% to 3.05%) and Provider 7 (2.81% to 3.15%) cross it. The first-attempt rates settle both as `medium` (2.54% and 2.68%), and classes match on all and first attempts for every provider. So the mart doesn't carry Wilson columns, and its description names the two providers. Intervals also wouldn't correct for provider mix, repeated attempts, label changes, or routing. The 1,000-attempt minimum changes nothing, because no provider has between 268 and 3,394 terminal attempts.

#### Chargebacks

**Meaning:** "a dispute was raised" is the best reading, but the evidence is thin. No status mentions disputes, and 525 of 526 flagged payments stay `SUCCESSFUL`. The youngest flagged payment was 8.7 days old at the extract end, so at least one flag was set within 8.7 days. That seems early for a resolved dispute, though this relies on outside knowledge. The data can't separate won from lost.

**Who gets flagged:**

- 75.7% of flags are on a user's first settled payment.
- Flagged payments are associated with less later activity: 5.1% of flagged payments have a later successful payment within 7 days, against 13.3% for matched payments. Within 90 days it's 13.9% against 77.7%.
- The data has no flag date, so it can't show when each flag appeared relative to that activity. It can't say whether a dispute, an account restriction, or earlier customer behavior caused the difference.
- 5.03% of paid but undelivered, unrefunded payments are flagged (9 of 179 card payments), against 0.072% of delivered ones.

**Maturity,** on settled payments:

| Lag | Mature months | Count rate | Value rate |
|---|---|---:|---:|
| 60 days | January to June | 0.0851% | 0.1218% |
| 90 days | January to May | 0.0853% | 0.1123% |
| 120 days | January to April | 0.0793% | 0.1037% |
| None | All 9 | 0.0720% | 0.0950% |

- Recent payments are flagged less: none of the 28,728 card payments under 8 days old has a flag, where about 20 would be expected at the older rate. That points to a lag, but it doesn't set a minimum delay.
- **Why 120 days.** The data can't separate 60, 90, and 120, because months also differ in real risk (February 0.054%, April 0.094%). So the choice rests on three reasons: card networks commonly allow disputes for up to about 120 days, which is outside knowledge and not measured here; calling a month mature too early is the worse error, because it would understate risk; and `is_mature` is only a label, so it removes no data. A reader who prefers 90 can change one var.

**Denominator:** card and Apple Pay give 526 of 729,501, or 0.0721%, against 0.0720% on all settled payments. These are different populations that happen to match on this extract, so the mart states its denominator exactly and `payment_type` stays on `fct_remittances`. A separate card view adds nothing here, so it's dropped.

## 9. What the data can't settle

These stay stated assumptions in the README:

- What promotions are, and who funds them.
- What the no-receipt payments are, and whether all of them share one explanation.
- Who initiates most cancellations.
- Whether a chargeback was won or lost, and when it was raised.
- Why flagged users send less afterward.
- Whether `status` or `raw_status` is right when they disagree.
- What the first provider did before the January 22 cancellations.

## 10. Verification

Rechecked directly against the source files:

- Provider 12's monthly label shift, and the close times for Providers 3, 8, and 12.
- All 67 conflict rows by provider and outcome.
- The youngest chargeback age, and the 28,728 young card payments.
- The fully funded receipt ties.
- The no-receipt amount families and their Saturday pattern.
- Monthly top-group retention.

`analysis/verification/` re-derives 137 figures in plain Python with no DuckDB, including the recurring count, and all 137 match. It doesn't cover the adopted status rule. `analysis/sql/15_review_checks.sql` does, and it also covers zero-amount remittances, the payment gap, disbursement timing, and monthly senders. `16_recurring_definitions.sql` holds the recurring comparison.

Scripts 10 to 14 used the earlier rule, where raw `cancelled` overrode `status`. Payout outcomes and volume don't change under the adopted rule, but Provider 3's figures do, so this document's tables take priority over those results.

Exploratory and not independently checked:

- The user resend, retry persistence, and user propensity figures behind "cancellations don't look user-driven".
- The shuffled test for proxy links, which is a heuristic.
