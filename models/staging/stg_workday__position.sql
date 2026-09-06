{{ config(materialized='view') }}

select
    id                                          as position_id,
    position_code,
    cast(effective_date as timestamp)           as effective_at,
    closed                                      as is_closed,
    cast(availability_date as timestamp)        as available_at,
    available_for_hire                          as is_available_for_hire,
    available_for_recruiting                    as is_available_for_recruiting,
    hiring_freeze                               as is_hiring_frozen,
    job_description,
    job_posting_title,
    supervisory_organization_id,
    worker_type_code,
    position_time_type_code,
    cast(_fivetran_synced as timestamp)         as _fivetran_synced
from {{ source('workday', 'position') }}
where coalesce(_fivetran_active, true)
