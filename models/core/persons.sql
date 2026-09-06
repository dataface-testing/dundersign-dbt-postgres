-- Persons spine (Nimble conformance). One row per distinct human, keyed on
-- lowercased email -- the invariant the generator guarantees per person.
--
-- Every person-shaped source is unioned in: a person exists here because some
-- system holds a record of them, not because marketing happened to mint a
-- contact. An earlier version built the spine from hubspot.contact alone and
-- relied on a test to prove HubSpot covered everything; that inverts the
-- dependency -- it makes identity a function of marketing activity, so the
-- bot signups HubSpot legitimately never sees fall out of the spine. That
-- population only appears past day 600, so it is invisible at the committed
-- 350-day horizon and shows up at the 3-year one the BigQuery mirror runs
-- (~500 rows there). Coverage is a business question ("what share of signups does
-- marketing reach?"), answered by marketing_person_coverage.sql, not a
-- structural property of who exists.
--
-- Junk/bot signups are kept and flagged, never dropped. They are real rows in
-- the product database, so excluding them here would make person counts stop
-- reconciling against it with no visible reason. `is_junk` is the product
-- database's own signup-fraud flag -- the source system's judgement, not a
-- guess made here from the email domain.
--
-- salesforce.leads is deliberately NOT unioned in -- one person can generate
-- multiple lead records (re-touches, tracking-id duplicates), and a large
-- share of lead rows carry a null/corrupted email (the days 250-260 "email
-- validation broken" anomaly). Those rows stay in `leads` with a null
-- person_id rather than vanishing or getting force-matched.
--
-- product_user_id and salesforce_contact_id are safe scalar FKs: both source
-- tables are already 1:1 on email in this fixture (verified, not assumed).
-- stripe.customer is NOT -- some people have more than one Stripe customer
-- record (resubscribes, etc.) -- so primary_stripe_customer_id below is
-- explicitly named to say what it is: the earliest of possibly several, not
-- "the" customer id for that person. Anything that needs to resolve a
-- specific stripe.customer row to a person (invoices, charges) must join
-- stg_stripe__customer's own email back to persons.id directly, not through
-- this column -- see invoices.sql's header and
-- assert_billing_person_id_resolves.sql.
with contact as (
    select
        lower(trim(email))                        as email,
        contact_id,
        first_name,
        last_name,
        contact_company,
        job_title,
        created_date
    from {{ ref('stg_hubspot__contact') }}
    where email is not null and email <> ''
),
product_user as (
    select
        user_id                                   as product_user_id,
        lower(trim(email))                        as email,
        first_name,
        last_name,
        company_name,
        job_title,
        is_junk,
        email_verified,
        created_at
    from {{ ref('stg_product_db__user') }}
    where email is not null and email <> ''
),
sales_contact as (
    select
        contact_id                                as salesforce_contact_id,
        lower(trim(email))                        as email,
        first_name,
        last_name
    from {{ ref('stg_salesforce__contact') }}
    where email is not null and email <> ''
),
billing_customer as (
    select
        customer_id                               as primary_stripe_customer_id,
        lower(trim(email))                        as email,
        created_at
    from {{ ref('stg_stripe__customer') }}
    where email is not null and email <> '' and not is_deleted
    qualify row_number() over (partition by lower(trim(email)) order by created_at) = 1
),
-- Structural completeness: every email any source holds, deduped.
person_email as (
    select email from contact
    union distinct
    select email from product_user
    union distinct
    select email from sales_contact
    union distinct
    select email from billing_customer
)
select
    pe.email                                                 as id,
    pe.email                                                 as email,
    coalesce(c.first_name, pu.first_name, sc.first_name)     as first_name,
    coalesce(c.last_name, pu.last_name, sc.last_name)        as last_name,
    nullif(coalesce(c.contact_company, pu.company_name), '') as company_name,
    nullif(coalesce(c.job_title, pu.job_title), '')          as job_title,
    pu.product_user_id,
    sc.salesforce_contact_id,
    c.contact_id                                             as hubspot_contact_id,
    bc.primary_stripe_customer_id,
    -- Quality flags: analysts filter on these; the row is never silently gone.
    -- false, not NULL: "no product signup" is itself evidence this is not
    -- a junk *signup*. email_verified below is the opposite case -- there
    -- the absence of a signup means verification was never attempted, and
    -- false would assert it was attempted and failed.
    coalesce(pu.is_junk, false)                              as is_junk_signup,
    pu.email_verified,
    c.contact_id is not null                                 as has_marketing_contact,
    -- When this person signed up for the product, if they ever did. Distinct
    -- from created_at below, which is "first seen in any system".
    pu.created_at                                            as product_signup_at,
    coalesce(c.created_date, pu.created_at, bc.created_at)
                                                             as created_at
from person_email pe
left join contact c           on c.email = pe.email
left join product_user pu     on pu.email = pe.email
left join sales_contact sc    on sc.email = pe.email
left join billing_customer bc on bc.email = pe.email
