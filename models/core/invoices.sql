-- Core invoices. Built on Fivetran stripe_source staging.
-- person_id resolves by looking up THIS invoice's own stripe customer and
-- matching its email to persons.id directly -- not via
-- persons.primary_stripe_customer_id. That column only keeps one Stripe
-- customer per person, and some people have more than one Stripe customer
-- record (resubscribes, etc.), so routing through it silently drops
-- person_id for every invoice billed to a person's non-primary customer id.
-- Resolving from stg_stripe__customer directly makes the FK complete for
-- every row with a resolvable email (see
-- assert_billing_person_id_resolves.sql).
-- account_id resolves via stripe.customer.description, which matches
-- accounts.name 1:1 -- same pattern as gl_transactions.sql's
-- netsuite_customer_account CTE.
-- Amounts are normalized from Stripe's raw cents to dollars.
-- charge_id is always null in this fixture -- the raw feed never populates
-- it (empty string on every row); charges.invoice_id is the reliable
-- direction of this relationship.
with customer_account as (
    select c.customer_id, a.id as account_id
    from {{ ref('stg_stripe__customer') }} c
    join {{ ref('accounts') }} a on a.name = c.description
),
customer_person as (
    select c.customer_id, p.id as person_id
    from {{ ref('stg_stripe__customer') }} c
    join {{ ref('persons') }} p on p.id = lower(trim(c.email))
    where c.email is not null and c.email <> ''
)
select
    i.invoice_id                                as id,
    i.customer_id,
    cp.person_id,
    ca.account_id,
    i.subscription_id,
    nullif(i.charge_id, '')                     as charge_id,
    i.status,
    i.billing_reason,
    i.number,
    i.amount_due / 100.0                        as amount_due,
    i.amount_paid / 100.0                       as amount_paid,
    i.amount_remaining / 100.0                  as amount_remaining,
    i.subtotal / 100.0                          as subtotal,
    i.tax / 100.0                               as tax,
    i.total / 100.0                             as total,
    i.currency,
    i.is_paid,
    i.attempt_count,
    i.auto_advance,
    i.description,
    cast(i.created_at as timestamp)             as created_at,
    cast(i.due_date as timestamp)                as due_at,
    cast(i.period_start as timestamp)           as period_start_at,
    cast(i.period_end as timestamp)             as period_end_at,
    i.status_transitions_finalized_at           as finalized_at,
    i.status_transitions_paid_at                as paid_at
from {{ ref('stg_stripe__invoice') }} i
left join customer_person cp on cp.customer_id = i.customer_id
left join customer_account ca on ca.customer_id = i.customer_id
