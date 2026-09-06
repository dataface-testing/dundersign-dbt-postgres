select
    concat(worker_id, ':', position_id, ':', coalesce(cast(effective_at as {{ dbt.type_string() }}), '1970-01-01 00:00:00')) as id,
    worker_id,
    position_id,
    effective_at,
    started_at,
    ended_at,
    job_profile_id,
    business_title,
    employee_type,
    is_primary_job,
    scheduled_weekly_hours,
    full_time_equivalent_percentage,
    pay_rate,
    pay_rate_type,
    frequency,
    _fivetran_synced
from {{ ref('stg_workday__worker_position_history') }}
