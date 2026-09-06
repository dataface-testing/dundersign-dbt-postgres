-- Recruiting: one row per stage in a job's pipeline.
select
    s.job_stage_id                                 as id,
    s.job_id,
    s.name,
    s.created_at,
    s.updated_at
from {{ ref('stg_greenhouse__job_stage') }} s
