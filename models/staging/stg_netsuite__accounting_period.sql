{{ config(materialized='view') }}

select
    id                                           as accounting_period_id,
    periodname                                   as period_name,
    cast(startdate as timestamp)                 as start_at,
    cast(enddate as timestamp)                   as end_at,
    (closed = 'T')                                as is_closed,
    cast(_fivetran_synced as timestamp)          as _fivetran_synced
from {{ source('netsuite', 'accounting_period') }}
where coalesce(_fivetran_active, true)
