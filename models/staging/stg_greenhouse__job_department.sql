{{ config(materialized='view') }}

-- Pure bridge, no natural id column -- the surrogate PK is minted in
-- models/core/job_departments.sql from the (department_id, job_id) pair.
select
    department_id,
    job_id,
    cast(_fivetran_synced as timestamp)            as _fivetran_synced
from {{ source('greenhouse', 'job_department') }}
where coalesce(_fivetran_active, true)
