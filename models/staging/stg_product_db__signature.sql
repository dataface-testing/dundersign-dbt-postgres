{{ config(materialized='view') }}

select
    id                                          as signature_id,
    document_id,
    recipient_id                                as document_recipient_id,
    field_type,
    page_number,
    x_position,
    y_position,
    width,
    height,
    value,
    cast(signed_at as timestamp)                as signed_at,
    cast(_fivetran_synced as timestamp)         as _fivetran_synced
from {{ source('product_db', 'signature') }}
where coalesce(_fivetran_active, true)
