set timezone = 'UTC';

-- Compares each provider with other providers on the same destination and payout type.
-- Uses the adopted rule, as 15_review_checks.sql does. Routing isn't random, so this describes, and doesn't prove cause.

create temp table mix_attempts as
select provider, country as country_code, payout_type,
    case
        when status_lc = 'cancelled' then 'cancelled'
        when status_lc in ('paid', 'success', 'completed', 'delivered') then 'delivered'
        when status_lc in ('failed', 'rejected', 'error_sending_payout_request', 'payout_not_processed') then 'failed'
    end as adopted_status
from attempts
where matched_disbursement_id is not null;

create temp table mix_cells as
select provider, country_code, payout_type,
    count(*) filter (where adopted_status = 'failed') as failed,
    count(*) filter (where adopted_status = 'cancelled') as cancelled,
    count(*) filter (where adopted_status in ('delivered', 'failed')) as decided,
    count(*) filter (where adopted_status in ('delivered', 'failed', 'cancelled')) as terminal
from mix_attempts
group by all;

.print ## M1 Failed rate by destination and payout type, at 1,000 or more decided attempts
select country_code, payout_type, sum(decided) as decided, sum(failed) as failed,
    round(100.0 * sum(failed) / sum(decided), 2) as failed_pct,
    count(*) filter (where decided > 0) as providers
from mix_cells
group by all
having sum(decided) >= 1000
order by failed_pct desc;

.print ## M2 Each provider against its peers on the same destination and payout type
.print Peers exclude the provider itself. Routes where peers have under 1,000 decided attempts are left out, because the rate would be too thin to compare.
with peers as (
    select *,
        sum(failed) over route - failed as peer_failed,
        sum(cancelled) over route - cancelled as peer_cancelled,
        sum(decided) over route - decided as peer_decided,
        sum(terminal) over route - terminal as peer_terminal
    from mix_cells
    window route as (partition by country_code, payout_type)
),

compared as (
    select provider,
        sum(decided) as decided,
        sum(failed) as failed,
        sum(case when peer_decided >= 1000 then decided else 0 end) as compared_decided,
        sum(case when peer_decided >= 1000 then failed else 0 end) as compared_failed,
        sum(case when peer_terminal >= 1000 then failed + cancelled else 0 end) as compared_unsuccessful,
        sum(case when peer_decided >= 1000 then decided * peer_failed / peer_decided else 0 end) as expected_failed,
        sum(case when peer_terminal >= 1000 then terminal * (peer_failed + peer_cancelled) / peer_terminal else 0 end) as expected_unsuccessful
    from peers
    group by 1
)

select provider, decided,
    round(100.0 * failed / decided, 2) as failed_pct,
    round(100.0 * compared_decided / decided, 1) as compared_pct,
    round(100.0 * compared_failed / nullif(compared_decided, 0), 2) as compared_failed_pct,
    round(100.0 * expected_failed / nullif(compared_decided, 0), 2) as peer_failed_pct,
    round(compared_failed / nullif(expected_failed, 0), 2) as failed_vs_peers,
    round(compared_unsuccessful / nullif(expected_unsuccessful, 0), 2) as unsuccessful_vs_peers
from compared
where decided >= 1000
order by decided desc;

.print ## M3 The largest gaps inside one route, at 3,000 or more decided attempts
select country_code, payout_type, provider, decided, failed, round(100.0 * failed / decided, 2) as failed_pct
from mix_cells
where decided >= 3000
order by country_code, payout_type, failed_pct desc;
