select
    concat(personal_info_system_id, ':', coalesce(name_type, 'unknown'), ':', person_name_index) as id,
    person_name_index,
    personal_info_system_id,
    name_type,
    first_name,
    last_name,
    middle_name,
    country,
    _fivetran_synced
from {{ ref('stg_workday__person_name') }}
