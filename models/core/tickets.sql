-- Core support tickets. Built on Fivetran zendesk_source staging.
select
    ticket_id                                   as id,
    requester_id,
    submitter_id,
    assignee_id,
    organization_id,
    group_id,
    brand_id,
    subject,
    description,
    type                                        as ticket_type,
    priority,
    status,
    created_channel                             as via_channel,
    is_public,
    cast(created_at as timestamp)               as created_at,
    cast(updated_at as timestamp)               as updated_at,
    cast(due_at as timestamp)                   as due_at
from {{ ref('stg_zendesk__ticket') }}
