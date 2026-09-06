-- Core form submissions. Built on Fivetran hubspot_source staging;
-- contact_id matches persons.hubspot_contact_id directly (bigint join, no
-- email normalization needed). conversion_id is a unique natural key.
select
    fs.conversion_id                            as id,
    fs.form_id                                   as marketing_form_id,
    fs.contact_id                                 as hubspot_contact_id,
    p.id                                           as person_id,
    fs.page_id,
    fs.page_url,
    fs.title,
    fs.portal_id,
    fs.occurred_timestamp,
    fs._fivetran_synced
from {{ ref('stg_hubspot__contact_form_submission') }} fs
left join {{ ref('persons') }} p
    on p.hubspot_contact_id = fs.contact_id
