{{ config(materialized='view') }}

select
    id                                            as item_id,
    fullname                                      as name,
    itemtype                                      as item_type,
    nullif(description, '')                       as description,
    cast(_fivetran_synced as timestamp)           as _fivetran_synced
from {{ source('netsuite', 'item') }}
where coalesce(_fivetran_active, true)
