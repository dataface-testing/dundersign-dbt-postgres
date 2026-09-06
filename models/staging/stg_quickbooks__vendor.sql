{{ config(materialized='view') }}

select
    id                                           as vendor_id,
    coalesce(nullif(company_name, ''), display_name) as name,
    cast(_fivetran_synced as timestamp)          as _fivetran_synced
from {{ source('quickbooks', 'vendor') }}
where coalesce(_fivetran_active, true)
