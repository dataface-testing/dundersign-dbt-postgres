{{ config(materialized='view') }}

select
    id                                          as document_recipient_id,
    document_id,
    email,
    name                                        as recipient_name,
    role                                        as recipient_role,
    signing_order,
    status,
    reminder_count,
    cast(sent_at as timestamp)                  as sent_at,
    cast(viewed_at as timestamp)                as viewed_at,
    cast(signed_at as timestamp)                as signed_at,
    cast(declined_at as timestamp)              as declined_at,
    declined_reason,
    cast(_fivetran_synced as timestamp)         as _fivetran_synced
from {{ source('product_db', 'document_recipient') }}
where coalesce(_fivetran_active, true)
