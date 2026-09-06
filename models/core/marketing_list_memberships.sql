-- Core marketing list memberships (bridge, one row per contact-list-member
-- link). Built on Fivetran hubspot_source staging; contact_id matches
-- persons.hubspot_contact_id directly. (contact_list_id, contact_id) is a
-- unique natural key.
select
    m.contact_list_id || '_' || m.contact_id    as id,
    m.contact_list_id                            as marketing_list_id,
    m.contact_id                                  as hubspot_contact_id,
    p.id                                           as person_id,
    m.added_timestamp,
    m.is_contact_list_member_deleted,
    m._fivetran_synced
from {{ ref('stg_hubspot__contact_list_member') }} m
left join {{ ref('persons') }} p
    on p.hubspot_contact_id = m.contact_id
