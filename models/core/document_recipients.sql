-- Bridge: M:N between documents and recipients (signers / viewers / approvers).
-- recipient_email is kept as the join key into users (faketran's recipients are
-- not always existing product users — leave the resolution to consumers).
select
    document_recipient_id                       as id,
    document_id,
    email                                       as recipient_email,
    recipient_name,
    recipient_role,
    signing_order,
    status,
    reminder_count,
    sent_at,
    viewed_at,
    signed_at,
    declined_at,
    declined_reason,
    _fivetran_synced
from {{ ref('stg_product_db__document_recipient') }}
