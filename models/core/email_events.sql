-- Core email events. Built on Fivetran hubspot_source staging; email_event
-- carries no contact_id, so the recipient is matched to persons by
-- lowercased email (the same key persons.id is built on).
select
    e.event_id                                  as id,
    e.email_campaign_id,
    lower(trim(e.recipient_email_address))      as recipient_email,
    p.id                                        as person_id,
    e.event_type,
    e.created_timestamp,
    e.sent_timestamp,
    e.sent_by_event_id,
    e.obsoleted_timestamp,
    e.obsoleted_by_event_id,
    e.caused_timestamp,
    e.caused_by_event_id,
    e.is_filtered_event,
    e.app_id,
    e.portal_id,
    e._fivetran_synced
from {{ ref('stg_hubspot__email_event') }} e
left join {{ ref('persons') }} p
    on p.id = lower(trim(e.recipient_email_address))
