-- Leads, conformed (Nimble). salesforce.lead.email is corrupted for a large
-- share of rows -- a deliberate generator anomaly (days 250-260 "email
-- validation broken") that set email to null/''/'invalid' on a huge share of
-- leads, not just ones created in that window. Those rows are kept with a null
-- person_id rather than dropped or force-matched: this is exactly the
-- conformance failure mode the initiative exists to catch, not a bug to
-- paper over.
select
    l.lead_id                                   as id,
    l.first_name,
    l.last_name,
    l.company,
    l.email,
    nullif(l.industry, '')                      as industry,
    l.annual_revenue,
    l.number_of_employees,
    p.id                                         as person_id,
    e.id                                         as owner_id,
    l.lead_source,
    l.status,
    l.is_converted,
    nullif(l.converted_account_id, '')          as converted_account_id,
    nullif(l.converted_contact_id, '')          as converted_contact_id,
    nullif(l.converted_opportunity_id, '')      as converted_opportunity_id,
    cast(l.created_date as timestamp)           as created_at
from {{ ref('stg_salesforce__lead') }} l
left join {{ ref('persons') }} p
    on p.id = lower(trim(l.email))
    and l.email is not null and l.email <> '' and lower(l.email) <> 'invalid'
left join {{ ref('employees') }} e on e.salesforce_user_id = l.owner_id
where not coalesce(l.is_deleted, false)
