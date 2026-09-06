{{ config(materialized='view') }}

select
    id                                          as worker_id,
    active                                      as is_active,
    cast(hire_date as timestamp)                as hired_at,
    cast(termination_date as timestamp)         as terminated_at,
    terminated                                  as is_terminated,
    cast(original_hire_date as timestamp)       as original_hired_at,
    cast(first_day_of_work as timestamp)        as first_day_of_work_at,
    rehire                                      as is_rehire,
    retired                                     as is_retired,
    user_id,
    worker_code,
    universal_id,
    home_country,
    cast(_fivetran_synced as timestamp)         as _fivetran_synced
from {{ source('workday', 'worker_history') }}
where coalesce(_fivetran_active, true)
