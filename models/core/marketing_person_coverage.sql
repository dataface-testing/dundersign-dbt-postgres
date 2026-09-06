-- What share of the people the company knows about has marketing actually
-- reached? One row per signup cohort month.
--
-- This exists because the persons spine used to be built from
-- hubspot.contact alone, which made "did marketing mint a contact?" a
-- structural precondition for existing at all: the ~500 bot signups HubSpot
-- legitimately never sees fell out of the spine entirely, and the only
-- signal was a build failure. Coverage is a business question, so it is
-- measured here and left visible rather than gating the build.
--
-- Junk signups are reported separately, not filtered away: a coverage number
-- that quietly excludes them overstates reach.
--
-- count(case when ...) rather than count(*) filter (where ...), and
-- dbt.date_trunc rather than a bare date_trunc: these models run on BigQuery
-- as well as DuckDB (tests/scripts/test_examples_portable_sql.py).
select
    -- Bucket on the signup, not on persons.created_at: that column prefers
    -- HubSpot's date, so having a contact would push a person into a later
    -- cohort than they signed up in -- biasing the very measure taken here.
    cast({{ dbt.date_trunc('month', 'signup_at') }} as date)    as cohort_month,
    count(*)                                                    as persons,
    count(case when has_marketing_contact then 1 end)           as with_marketing_contact,
    count(case when is_junk_signup then 1 end)                  as junk_signups,
    count(case when not is_junk_signup then 1 end)              as real_persons,
    count(case when has_marketing_contact and not is_junk_signup then 1 end)
                                                                as real_with_marketing_contact,
    round(
        100.0 * count(case when has_marketing_contact and not is_junk_signup then 1 end)
        / nullif(count(case when not is_junk_signup then 1 end), 0),
        1
    )                                                           as real_coverage_pct
from (
    select *, coalesce(product_signup_at, created_at) as signup_at
    from {{ ref('persons') }}
) p
where signup_at is not null
group by 1
