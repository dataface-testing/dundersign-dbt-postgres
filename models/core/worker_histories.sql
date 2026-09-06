select
    worker_id                                   as id,
    is_active,
    hired_at,
    terminated_at,
    is_terminated,
    original_hired_at,
    first_day_of_work_at,
    is_rehire,
    is_retired,
    user_id,
    worker_code,
    universal_id,
    home_country,
    _fivetran_synced
from {{ ref('stg_workday__worker_history') }}
