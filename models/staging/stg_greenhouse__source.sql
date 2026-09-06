{{ config(materialized='view') }}

select
    id                                            as source_id,
    name,
    source_type_id,
    source_type_name,
    cast(_fivetran_synced as timestamp)            as _fivetran_synced
from {{ source('greenhouse', 'source') }}
where coalesce(_fivetran_active, true)
