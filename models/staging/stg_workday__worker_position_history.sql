{{ config(materialized='view') }}

select
    position_id,
    worker_id,
    cast(effective_date as timestamp)           as effective_at,
    cast(start_date as timestamp)               as started_at,
    cast(end_date as timestamp)                 as ended_at,
    job_profile_id,
    business_title,
    employee_type,
    is_primary_job,
    scheduled_weekly_hours,
    full_time_equivalent_percentage,
    pay_rate,
    pay_rate_type,
    frequency,
    cast(_fivetran_synced as timestamp)         as _fivetran_synced
from {{ source('workday', 'worker_position_history') }}
where coalesce(_fivetran_active, true)
