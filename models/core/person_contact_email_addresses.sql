select
    person_contact_email_address_id             as id,
    personal_info_system_id,
    email_address,
    email_code,
    _fivetran_synced
from {{ ref('stg_workday__person_contact_email_address') }}
