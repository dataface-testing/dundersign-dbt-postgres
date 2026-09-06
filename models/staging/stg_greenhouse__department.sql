{{ config(materialized='view') }}

select
    id                                            as department_id,
    nullif(external_id, '')                       as external_id,
    name,
    nullif(parent_id, '')                         as parent_id,
    cast(_fivetran_synced as timestamp)            as _fivetran_synced
from {{ source('greenhouse', 'department') }}
where coalesce(_fivetran_active, true)
