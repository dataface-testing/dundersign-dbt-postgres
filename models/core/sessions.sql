select
    session_id                                  as id,
    user_id,
    started_at,
    ended_at,
    duration_seconds,
    pages_viewed,
    documents_created,
    documents_sent,
    ip_address,
    user_agent,
    country,
    device_type,
    browser,
    _fivetran_synced
from {{ ref('stg_product_db__session') }}
