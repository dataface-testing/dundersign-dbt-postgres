select
    position_id                                 as id,
    position_code,
    effective_at,
    is_closed,
    available_at,
    is_available_for_hire,
    is_available_for_recruiting,
    is_hiring_frozen,
    job_description,
    job_posting_title,
    supervisory_organization_id,
    worker_type_code,
    position_time_type_code,
    _fivetran_synced
from {{ ref('stg_workday__position') }}
