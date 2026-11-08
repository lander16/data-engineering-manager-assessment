# Business Definitions

These are the company's agreed definitions. Timestamps are UTC, and months are UTC calendar months of the payment's `created_at`.

## Versions
`raw.*` tables are text and can hold more than one version of a record. Keep one row per `id`: the latest `_source_file`, then the latest `updated_at` (or `created_at` if null). Cast columns as needed.

## Grains
- A remittance is one row in `payments`.
- A payout attempt is one row in `receipts` plus the disbursement it points to through `disbursement_id`. A payment can have several attempts.

## Attempt status
Use lowercase `disbursements.status`. `raw_status` never decides.
- No matching disbursement: `missing`.
- `cancelled`: cancelled.
- `paid`, `success`, `completed`, `delivered`: delivered.
- `failed`, `rejected`, `error_sending_payout_request`, `payout_not_processed`: failed.
- Everything else known is in flight.

Attempts of a payment are ordered by the receipt's `created_at`, then receipt `id`. The primary attempt is the earliest delivered one.

## Delivered remittance
`payments.status = 'SUCCESSFUL'` and at least one delivered attempt.

## Amount transacted
Sum of `payments.amount` (customer-paid USD) on delivered remittances, counted once per payment.

## Promotion value
`receipts.promotion_amount` on the primary attempt of delivered remittances.

## Top users
Rank users by amount transacted, highest first, ties broken by `user_id`. The group runs until the cumulative amount first reaches 50% of the total, including the user who crosses it.

## Recurring customer
A user with two consecutive delivered remittances, ordered by `created_at` then payment `id`, where the gap is more than 1 day and at most 90 days. Measure the gap in fractional days.

## Failed disbursement rate
failed / (delivered + failed) attempts. Provider is `disbursements.disbursement_provider`. Payout type is `disbursements.type`. Country is `receipts.destination_country_code`, and attempt date is the receipt's `created_at`.

## Chargeback rate
`has_dispute_chargeback` true, divided by eligible payments, where eligible means `payments.status` is `SUCCESSFUL` or `REFUNDED`. A month is final 120 days after it ends, measured against the latest payment in the data.

## Shared beneficiaries
A cluster is one `beneficiary_id` used by two or more users.

## Route
A delivered remittance's destination country and payout type come from its primary attempt.

## Value sent
`receipts.amount_charged + receipts.promotion_amount` on the primary attempt of delivered remittances.

## First-attempt failed rate
The failed disbursement rate using only each payment's first attempt.

## Unsuccessful rate
(failed + cancelled) / (delivered + failed + cancelled) attempts.

## Payout outcome
A payment with no receipt is `no_receipt`. Otherwise: 2 or more delivered attempts is `multiple_delivered`, 1 is `delivered`, then any in-flight attempt is `in_flight`, then any missing disbursement is `missing_payout`, and the rest is `not_delivered`.

## First-seen and returning senders
A sender in a month is first-seen if that month is the user's first month with a delivered remittance, and returning otherwise.

## Monthly top group share
Within a month, rank that month's senders by amount transacted, highest first, ties by `user_id`. Count users until the cumulative amount first reaches 50% of the month, including the crossing user. The share is that count over the month's senders.

## 90-day repeat rate
For users whose first delivered remittance falls in a month, keep those whose first delivered timestamp plus 90 days is on or before the latest payment in the data. A user repeats if any delivered remittance falls more than 1 day and at most 90 days after the first one. Measure in fractional days.

## Beneficiary segment
`beneficiary_id` is the beneficiary key. Count a user's distinct beneficiaries that appeared on a payment's first attempt, including attempts on payments that weren't delivered. Segments are 1, 2-3, 4-9, and 10+.

## Chargeback value rate
Customer-paid amount of flagged eligible payments divided by customer-paid amount of all eligible payments.
