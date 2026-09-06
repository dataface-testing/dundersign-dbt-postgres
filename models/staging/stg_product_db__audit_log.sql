{{ config(materialized='view') }}

select
    id                                          as audit_log_id,
    cast(timestamp as timestamp)                as occurred_at,
    user_id,
    team_id,
    document_id,
    action,
    ip_address,
    user_agent,
    metadata,
    cast(_fivetran_synced as timestamp)         as _fivetran_synced
from {{ source('product_db', 'audit_log') }}
where coalesce(_fivetran_active, true)
