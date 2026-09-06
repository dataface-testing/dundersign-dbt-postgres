select
    audit_log_id                                as id,
    occurred_at,
    user_id,
    team_id,
    document_id,
    action,
    ip_address,
    user_agent,
    metadata,
    _fivetran_synced
from {{ ref('stg_product_db__audit_log') }}
