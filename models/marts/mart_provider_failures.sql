{% set classes = var('provider_class') %}

with counts as (
    select
        provider,
        count(*) as attempts,
        count(case when attempt_status = 'delivered' then 1 end) as delivered,
        count(case when attempt_status = 'failed' then 1 end) as failed,
        count(case when attempt_status = 'cancelled' then 1 end) as cancelled,
        count(case when attempt_status = 'in_flight' then 1 end) as in_flight,
        count(case when attempt_status = 'delivered' and attempt_number = 1 then 1 end) as first_delivered,
        count(case when attempt_status = 'failed' and attempt_number = 1 then 1 end) as first_failed,
        count(case when attempt_status = 'delivered' and attempt_number > 1 then 1 end) as retry_delivered,
        count(case when attempt_status = 'failed' and attempt_number > 1 then 1 end) as retry_failed,
        count(case when is_followed_by_delivery then 1 end) as rescued_attempts
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
            when failed_rate is null then 'insufficient_volume'
            when failed_rate < {{ classes.low_below }} then 'low'
            when failed_rate < {{ classes.medium_below }} then 'medium'
            else 'high'
        end as failure_class,
        case
            when attempts < {{ classes.min_attempts }} then 'insufficient_volume'
            when unsuccessful_terminal_rate is null then 'insufficient_volume'
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
