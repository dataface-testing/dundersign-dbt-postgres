-- Recruiting: one row per job requisition.
select
    j.job_id                                       as id,
    j.name,
    j.requisition_id,
    j.status,
    j.is_confidential,
    j.notes,
    j.created_at,
    j.updated_at,
    j.closed_at
from {{ ref('stg_greenhouse__job') }} j
