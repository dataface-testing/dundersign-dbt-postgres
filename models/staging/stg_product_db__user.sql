{{ config(materialized='view') }}

-- 1:1 cleanup of product_db.user. Naming + types normalized so core models
-- can join without per-row gymnastics. `is_junk` is carried through, not
-- dropped: persons.is_junk_signup is the product database's own
-- signup-fraud verdict rather than a domain guess made downstream.
select
    id                                              as user_id,
    email,
    first_name,
    last_name,
    coalesce(nullif(company_name, ''), 'Unknown')   as company_name,
    coalesce(nullif(job_title, ''), 'Unknown')      as job_title,
    plan,
    source                                          as signup_source,
    role,
    is_active,
    email_verified,
    is_junk,
    team_id,
    cast(created_at as timestamp)                   as created_at,
    cast(plan_started_at as timestamp)              as plan_started_at,
    cast(trial_ends_at as timestamp)                as trial_ends_at,
    cast(last_login_at as timestamp)                as last_login_at,
    login_count,
    cast(_fivetran_synced as timestamp)             as _fivetran_synced
from {{ source('product_db', 'user') }}
where coalesce(_fivetran_active, true)
