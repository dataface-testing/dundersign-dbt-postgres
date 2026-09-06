{{ config(materialized='view') }}

select
    id                                            as candidate_id,
    first_name,
    last_name,
    title,
    nullif(company, '')                           as company,
    is_private,
    recruiter_id,
    coordinator_id,
    nullif(new_candidate_id, '')                  as new_candidate_id,
    nullif(photo_url, '')                         as photo_url,
    cast(created_at as timestamp)                 as created_at,
    cast(last_activity as timestamp)               as last_activity_at,
    cast(updated_at as timestamp)                  as updated_at,
    cast(_fivetran_synced as timestamp)            as _fivetran_synced
from {{ source('greenhouse', 'candidate') }}
where coalesce(_fivetran_active, true)
