{{ config(materialized='view') }}

select
    id                                           as vendor_id,
    companyname                                  as name,
    category,
    cast(datecreated as timestamp)               as created_at,
    cast(_fivetran_synced as timestamp)          as _fivetran_synced
from {{ source('netsuite', 'vendor') }}
where coalesce(_fivetran_active, true)
