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
    substr(summary, strpos(summary, ' in ') + 4) as department,
    _fivetran_synced
from {{ ref('stg_workday__job_profile') }}
