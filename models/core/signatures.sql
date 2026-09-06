select
    signature_id                                as id,
    document_id,
    document_recipient_id,
    field_type,
    page_number,
    x_position,
    y_position,
    width,
    height,
    value,
    signed_at,
    _fivetran_synced
from {{ ref('stg_product_db__signature') }}
