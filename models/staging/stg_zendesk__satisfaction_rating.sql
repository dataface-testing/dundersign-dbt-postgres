{{ config(materialized='view') }}

-- Hand-rolled 1:1 staging model: no Fivetran zendesk_source staging model
-- exists for satisfaction_rating (checked dbt_packages/zendesk_source/models/).
select
    id,
    ticket_id,
    cast(created_at as timestamp)               as created_at,
    score,
    comment,
    reason,
    requester_id,
    assignee_id,
    group_id,
    cast(_fivetran_synced as timestamp)          as _fivetran_synced
from {{ source('zendesk', 'satisfaction_rating') }}
where coalesce(_fivetran_active, true)
