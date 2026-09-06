{{ config(materialized='view') }}

select
    id                                            as job_stage_id,
    job_id,
    name,
    cast(created_at as timestamp)                  as created_at,
    cast(updated_at as timestamp)                  as updated_at,
    cast(_fivetran_synced as timestamp)            as _fivetran_synced
from {{ source('greenhouse', 'job_stage') }}
where coalesce(_fivetran_active, true)
