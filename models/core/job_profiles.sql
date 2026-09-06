select
    job_profile_id                              as id,
    title,
    description,
    summary,
    job_profile_code,
    level,
    management_level,
    effective_at,
    is_inactive,
    is_critical_job,
    difficulty_to_fill,
    substring(summary from ' in (.*)$')         as department,
    _fivetran_synced
from {{ ref('stg_workday__job_profile') }}
