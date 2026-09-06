-- Recruiting: bridge between jobs and departments (a job can span more than
-- one department). No natural id in the raw feed -- PK minted from the
-- (department_id, job_id) pair.
select
    d.department_id || '_' || d.job_id             as id,
    d.department_id,
    d.job_id
from {{ ref('stg_greenhouse__job_department') }} d
