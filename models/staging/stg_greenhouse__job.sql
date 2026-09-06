{{ config(materialized='view') }}

select
    id                                            as job_id,
    name,
    requisition_id,
    status,
    confidential                                  as is_confidential,
    nullif(notes, '')                             as notes,
    cast(created_at as timestamp)                  as created_at,
    cast(updated_at as timestamp)                  as updated_at,
    cast(closed_at as timestamp)                   as closed_at,
    cast(_fivetran_synced as timestamp)            as _fivetran_synced
from {{ source('greenhouse', 'job') }}
where coalesce(_fivetran_active, true)
