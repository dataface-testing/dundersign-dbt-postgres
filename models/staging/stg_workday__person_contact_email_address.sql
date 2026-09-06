{{ config(materialized='view') }}

select
    id                                          as person_contact_email_address_id,
    personal_info_system_id,
    email_address,
    email_code,
    cast(_fivetran_synced as timestamp)         as _fivetran_synced
from {{ source('workday', 'person_contact_email_address') }}
where coalesce(_fivetran_active, true)
