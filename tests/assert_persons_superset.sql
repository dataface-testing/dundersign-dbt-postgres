-- persons must contain every person-shaped identity across all four source
-- systems. The spine unions them, so this holds by construction -- which is
-- precisely why it is worth pinning: a future edit that narrows a leg (adds a
-- WHERE, drops a UNION arm, filters junk "for cleanliness") would silently
-- shrink the spine, and every downstream person_id would start resolving to
-- NULL instead of failing.
--
-- hubspot.contact is a fourth leg here, not the base relation it used to be.
-- Any row returned is a real identity a source system holds and the spine
-- does not.
with source_emails as (
    select lower(trim(email)) as email
    from {{ ref('stg_product_db__user') }}
    where email is not null and email <> ''

    union distinct

    select lower(trim(email))
    from {{ ref('stg_hubspot__contact') }}
    where email is not null and email <> ''

    union distinct

    select lower(trim(email))
    from {{ ref('stg_salesforce__contact') }}
    where email is not null and email <> ''

    union distinct

    select lower(trim(email))
    from {{ ref('stg_stripe__customer') }}
    where email is not null and email <> '' and not is_deleted
)
select se.email
from source_emails se
left join {{ ref('persons') }} p on p.id = se.email
where p.id is null
