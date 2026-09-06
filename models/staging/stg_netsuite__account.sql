{{ config(materialized='view') }}

select
    id                                           as account_id,
    acctnumber                                   as account_number,
    accttype                                     as account_type,
    fullname                                     as name,
    description,
    (isinactive = 'T')                           as is_inactive,
    cast(_fivetran_synced as timestamp)          as _fivetran_synced
from {{ source('netsuite', 'account') }}
where coalesce(_fivetran_active, true)
