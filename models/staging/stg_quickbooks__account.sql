{{ config(materialized='view') }}

select
    id                                           as account_id,
    account_number,
    account_type,
    name,
    description,
    not coalesce(active, true)                    as is_inactive,
    cast(_fivetran_synced as timestamp)          as _fivetran_synced
from {{ source('quickbooks', 'account') }}
where coalesce(_fivetran_active, true)
