-- One row per product user. Core / silver layer: atomic, plural, FK-only joins.
select
    user_id                                     as id,
    email,
    first_name,
    last_name,
    company_name,
    job_title,
    plan,
    signup_source,
    role,
    is_active,
    email_verified,
    is_junk,
    team_id,
    created_at,
    plan_started_at,
    trial_ends_at,
    last_login_at,
    login_count,
    _fivetran_synced
from {{ ref('stg_product_db__user') }}
