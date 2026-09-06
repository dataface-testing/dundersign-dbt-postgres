-- Core email subscription changes. Deviation from spec.md, which said this
-- table needed no modeling -- true when the spec was written, but the raw
-- event log is no longer empty (thousands of rows, same order of magnitude
-- as the other populated marketing tables), so per the Nimble acceptance
-- criterion ("every populated raw table is covered or deliberately
-- excluded") it earns its own entity here.
--
-- recipient is a bare email string on this raw table (no contact_id),
-- matched to persons by lowercased email. (recipient, email_subscription_id,
-- changed_at) is a unique natural key.
select
    c.recipient || '_' || c.email_subscription_id || '_' || cast(c.changed_at as {{ dbt.type_string() }}) as id,
    lower(trim(c.recipient))                    as recipient_email,
    p.id                                         as person_id,
    c.email_subscription_id,
    c.change,
    c.change_type,
    c.source,
    c.changed_at,
    c.portal_id,
    c._fivetran_synced
from {{ ref('stg_hubspot__email_subscription_change') }} c
left join {{ ref('persons') }} p
    on p.id = lower(trim(c.recipient))
