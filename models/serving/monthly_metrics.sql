-- Pre-aggregated monthly rollup. Declared SERVING_EXCEPTION per Nimble — like
-- daily_metrics, a denormalized convenience model for dashboard performance,
-- here at month grain so the docs copy/paste fences never call a date
-- function (DATE_TRUNC argument order differs between DuckDB and BigQuery).
-- Cross-database macros only: this file syncs verbatim to the BigQuery
-- deployment, and every dbt.date_trunc is cast to DATE because the macro
-- returns TIMESTAMP on BigQuery (see test_examples_portable_sql.py).
-- The month spine unions every contributing model so a month with only
-- payment activity still gets a row. Owner: dave. Review horizon: with
-- daily_metrics.
with monthly as (
    select
        cast({{ dbt.date_trunc("month", "date") }} as date) as month,
        sum(new_users) as new_users,
        sum(sessions) as sessions,
        sum(documents_created) as documents_created,
        sum(documents_completed) as documents_completed,
        sum(tickets_created) as tickets_created,
        sum(tickets_resolved) as tickets_resolved
    from {{ ref('daily_metrics') }}
    group by 1
),
active_monthly as (
    select
        cast({{ dbt.date_trunc("month", "started_at") }} as date) as month,
        count(distinct user_id) as active_users
    from {{ ref('sessions') }}
    group by 1
),
revenue_monthly as (
    select
        cast({{ dbt.date_trunc("month", "created_at") }} as date) as month,
        round(sum(amount - amount_refunded), 2) as revenue
    from {{ ref('charges') }}
    where is_paid
    group by 1
),
months as (
    select month from monthly
    union distinct
    select month from active_monthly
    union distinct
    select month from revenue_monthly
)
select
    mo.month,
    coalesce(m.new_users, 0) as new_users,
    coalesce(a.active_users, 0) as active_users,
    coalesce(m.sessions, 0) as sessions,
    coalesce(m.documents_created, 0) as documents_created,
    coalesce(m.documents_completed, 0) as documents_completed,
    coalesce(r.revenue, 0) as revenue,
    coalesce(m.tickets_created, 0) as tickets_created,
    coalesce(m.tickets_resolved, 0) as tickets_resolved
from months mo
left join monthly m on mo.month = m.month
left join active_monthly a on mo.month = a.month
left join revenue_monthly r on mo.month = r.month
order by mo.month
