{% set classes = var('provider_class') %}

with counts as (
    select
        provider,
        count(*) as attempts,
        count(*) filter (where attempt_status = 'delivered') as delivered,
        count(*) filter (where attempt_status = 'failed') as failed,
        count(*) filter (where attempt_status = 'cancelled') as cancelled,
        count(*) filter (where attempt_status = 'in_flight') as in_flight,
        count(*) filter (where attempt_status = 'delivered' and attempt_number = 1) as first_delivered,
        count(*) filter (where attempt_status = 'failed' and attempt_number = 1) as first_failed,
        count(*) filter (where attempt_status = 'delivered' and attempt_number > 1) as retry_delivered,
        count(*) filter (where attempt_status = 'failed' and attempt_number > 1) as retry_failed,
        count(*) filter (where is_followed_by_delivery) as rescued_attempts
    from {{ ref('int_payout_attempts') }}
    where attempt_status <> 'missing'
    group by 1
),

rates as (
    select
        provider,
        attempts,
        delivered,
        failed,
        cancelled,
        in_flight,
        rescued_attempts,
        failed * 1.0 / nullif(delivered + failed, 0) as failed_rate,
        first_failed * 1.0 / nullif(first_delivered + first_failed, 0) as first_attempt_failed_rate,
        retry_failed * 1.0 / nullif(retry_delivered + retry_failed, 0) as retry_failed_rate,
        cancelled * 1.0 / nullif(delivered + failed + cancelled, 0) as cancelled_rate,
        (failed + cancelled) * 1.0 / nullif(delivered + failed + cancelled, 0) as unsuccessful_terminal_rate
    from counts
),

classified as (
    select
        *,
        case
            when attempts < {{ classes.min_attempts }} then 'insufficient_volume'
            when failed_rate < {{ classes.low_below }} then 'low'
            when failed_rate < {{ classes.medium_below }} then 'medium'
            else 'high'
        end as failure_class,
        case
            when attempts < {{ classes.min_attempts }} then 'insufficient_volume'
            when unsuccessful_terminal_rate < {{ classes.low_below }} then 'low'
            when unsuccessful_terminal_rate < {{ classes.medium_below }} then 'medium'
            else 'high'
        end as unsuccessful_class
    from rates
)

select
    *,
    failure_class <> unsuccessful_class as is_label_sensitive
from classified
