{{ config(materialized='view') }}

select
    id                                          as document_id,
    owner_user_id,
    team_id,
    title,
    status,
    template_id,
    page_count,
    file_size_bytes,
    cast(created_at as timestamp)               as created_at,
    cast(updated_at as timestamp)               as updated_at,
    cast(sent_at as timestamp)                  as sent_at,
    cast(completed_at as timestamp)             as completed_at,
    cast(expires_at as timestamp)               as expires_at,
    cast(voided_at as timestamp)                as voided_at,
    voided_reason,
    cast(_fivetran_synced as timestamp)         as _fivetran_synced
from {{ source('product_db', 'document') }}
where coalesce(_fivetran_active, true)
