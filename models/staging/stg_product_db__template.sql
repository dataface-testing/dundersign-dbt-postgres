{{ config(materialized='view') }}

select
    id                                          as template_id,
    owner_user_id,
    team_id,
    name,
    description,
    cast(created_at as timestamp)               as created_at,
    cast(updated_at as timestamp)               as updated_at,
    is_active,
    usage_count,
    file_size_bytes,
    page_count,
    cast(_fivetran_synced as timestamp)         as _fivetran_synced
from {{ source('product_db', 'template') }}
where coalesce(_fivetran_active, true)
