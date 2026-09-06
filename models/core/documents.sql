-- One row per document. Atomic; FK to users via owner_user_id.
select
    document_id                                 as id,
    owner_user_id,
    team_id,
    template_id,
    title,
    status,
    page_count,
    file_size_bytes,
    created_at,
    updated_at,
    sent_at,
    completed_at,
    expires_at,
    voided_at,
    voided_reason,
    _fivetran_synced,
    case
        when completed_at is not null
            then {{ dbt.datediff('date(created_at)', 'date(completed_at)', 'day') }}
    end                                         as days_to_complete
from {{ ref('stg_product_db__document') }}
