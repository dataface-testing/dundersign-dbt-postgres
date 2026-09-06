{{ config(materialized='view') }}

select
    id                                          as job_profile_id,
    title,
    description,
    summary,
    job_profile_code,
    level,
    management_level,
    cast(effective_date as timestamp)           as effective_at,
    inactive                                    as is_inactive,
    critical_job                                as is_critical_job,
    difficulty_to_fill,
    cast(_fivetran_synced as timestamp)         as _fivetran_synced
from {{ source('workday', 'job_profile') }}
where coalesce(_fivetran_active, true)
