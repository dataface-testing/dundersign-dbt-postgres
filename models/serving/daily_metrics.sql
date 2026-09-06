-- Pre-aggregated daily rollup. Declared SERVING_EXCEPTION per Nimble — it's
-- a denormalized convenience model for dashboard performance on multi-year
-- timelines, not a core entity. Owner: dave. Review horizon: when overview
-- board moves to incremental aggregation.
with all_dates as (
    select date(created_at) as date from {{ ref('users') }}
    union distinct
    select date(created_at) from {{ ref('documents') }}
    union distinct
    select date(started_at) from {{ ref('sessions') }}
    union distinct
    select date(created_at) from {{ ref('opportunities') }}
    union distinct
    select date(created_at) from {{ ref('subscriptions') }}
    union distinct
    select date(created_at) from {{ ref('tickets') }}
),
users_daily as (
    select
        date(created_at) as date,
        count(*) as new_users,
        count(case when signup_source = 'paid' then 1 end) as paid_signup_users,
        count(case when is_junk then 1 end) as junk_signups
    from {{ ref('users') }}
    group by 1
),
documents_daily as (
    select
        date(created_at) as date,
        count(*) as documents_created,
        count(case when status = 'completed' then 1 end) as documents_completed,
        round(avg(page_count), 2) as avg_pages
    from {{ ref('documents') }}
    group by 1
),
sessions_daily as (
    select
        date(started_at) as date,
        count(*) as sessions,
        count(distinct user_id) as active_users,
        round(avg(duration_seconds) / 60.0, 2) as avg_session_minutes,
        sum(documents_created) as docs_created_in_sessions,
        sum(documents_sent) as docs_sent_in_sessions
    from {{ ref('sessions') }}
    group by 1
),
opportunities_daily as (
    select
        date(created_at) as date,
        count(*) as opportunities_created,
        round(sum(amount), 2) as pipeline_amount,
        round(sum(case when is_won then amount else 0 end), 2) as won_amount
    from {{ ref('opportunities') }}
    group by 1
),
subscriptions_daily as (
    select
        date(created_at) as date,
        count(*) as subscriptions_started,
        count(case when status = 'active' then 1 end) as active_subscriptions_started,
        count(case when status = 'canceled' then 1 end) as canceled_subscriptions_started
    from {{ ref('subscriptions') }}
    group by 1
),
tickets_daily as (
    select
        date(created_at) as date,
        count(*) as tickets_created,
        count(case when status in ('solved', 'closed') then 1 end) as tickets_resolved
    from {{ ref('tickets') }}
    group by 1
)
select
    d.date,
    coalesce(u.new_users, 0)                            as new_users,
    coalesce(u.paid_signup_users, 0)                    as paid_signup_users,
    coalesce(u.junk_signups, 0)                         as junk_signups,
    coalesce(doc.documents_created, 0)                  as documents_created,
    coalesce(doc.documents_completed, 0)                as documents_completed,
    coalesce(doc.avg_pages, 0)                          as avg_pages,
    coalesce(s.sessions, 0)                             as sessions,
    coalesce(s.active_users, 0)                         as active_users,
    coalesce(s.avg_session_minutes, 0)                  as avg_session_minutes,
    coalesce(s.docs_created_in_sessions, 0)             as docs_created_in_sessions,
    coalesce(s.docs_sent_in_sessions, 0)                as docs_sent_in_sessions,
    coalesce(o.opportunities_created, 0)                as opportunities_created,
    coalesce(o.pipeline_amount, 0)                      as pipeline_amount,
    coalesce(o.won_amount, 0)                           as won_amount,
    coalesce(sub.subscriptions_started, 0)              as subscriptions_started,
    coalesce(sub.active_subscriptions_started, 0)       as active_subscriptions_started,
    coalesce(sub.canceled_subscriptions_started, 0)     as canceled_subscriptions_started,
    coalesce(t.tickets_created, 0)                      as tickets_created,
    coalesce(t.tickets_resolved, 0)                     as tickets_resolved
from all_dates d
left join users_daily         u   on d.date = u.date
left join documents_daily     doc on d.date = doc.date
left join sessions_daily      s   on d.date = s.date
left join opportunities_daily o   on d.date = o.date
left join subscriptions_daily sub on d.date = sub.date
left join tickets_daily       t   on d.date = t.date
order by d.date
