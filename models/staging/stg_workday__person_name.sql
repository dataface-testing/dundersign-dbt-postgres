{{ config(materialized='view') }}

select
    "index"                                     as person_name_index,
    personal_info_system_id,
    type                                        as name_type,
    first_name,
    last_name,
    middle_name,
    country,
    cast(_fivetran_synced as timestamp)         as _fivetran_synced
from {{ source('workday', 'person_name') }}
where coalesce(_fivetran_active, true)
