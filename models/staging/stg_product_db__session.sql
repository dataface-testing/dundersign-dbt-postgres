{{ config(materialized='view') }}

select
    id                                          as session_id,
    user_id,
    duration_seconds,
    pages_viewed,
    documents_created,
    documents_sent,
    ip_address,
    user_agent,
    country,
    device_type,
    browser,
    cast(started_at as timestamp)               as started_at,
    cast(ended_at as timestamp)                 as ended_at,
    cast(_fivetran_synced as timestamp)         as _fivetran_synced
from {{ source('product_db', 'session') }}
where coalesce(_fivetran_active, true)
