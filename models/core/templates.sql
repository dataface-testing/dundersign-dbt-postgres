select
    template_id                                 as id,
    owner_user_id,
    team_id,
    name,
    description,
    created_at,
    updated_at,
    is_active,
    usage_count,
    file_size_bytes,
    page_count,
    _fivetran_synced
from {{ ref('stg_product_db__template') }}
