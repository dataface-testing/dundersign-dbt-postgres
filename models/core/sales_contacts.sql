-- Sales contacts, conformed (Nimble). salesforce.contact.email is clean
-- (unlike leads), so person_id resolves for effectively every row.
-- account_id is the raw salesforce.account.id, which is the same id space as
-- accounts.id (see accounts.sql) -- no translation needed.
select
    c.contact_id                                as id,
    c.first_name,
    c.last_name,
    c.email,
    p.id                                         as person_id,
    c.account_id,
    e.id                                         as owner_id,
    c.title,
    c.department,
    c.lead_source,
    c.mailing_city,
    c.mailing_state,
    c.mailing_country,
    cast(c.last_activity_date as timestamp)     as last_activity_at
from {{ ref('stg_salesforce__contact') }} c
left join {{ ref('persons') }} p
    on p.id = lower(trim(c.email))
    and c.email is not null and c.email <> ''
left join {{ ref('employees') }} e on e.salesforce_user_id = c.owner_id
