{{ config(materialized='view') }}

select
    id                                            as application_id,
    candidate_id,
    current_stage_id,
    nullif(prospect_stage_id, '')                 as prospect_stage_id,
    nullif(prospect_pool_id, '')                  as prospect_pool_id,
    source_id,
    credited_to_user_id,
    nullif(prospect_owner_id, '')                 as prospect_owner_id,
    nullif(rejected_reason_id, '')                as rejected_reason_id,
    status,
    prospect                                      as is_prospect,
    is_deleted,
    nullif(location_address, '')                  as location_address,
    cast(applied_at as timestamp)                  as applied_at,
    cast(last_activity_at as timestamp)            as last_activity_at,
    cast(rejected_at as timestamp)                 as rejected_at,
    cast(_fivetran_synced as timestamp)            as _fivetran_synced
from {{ source('greenhouse', 'application') }}
where coalesce(_fivetran_active, true)
