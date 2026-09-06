-- Regression guard for the bug where invoices.person_id/charges.person_id
-- were resolved via persons.primary_stripe_customer_id -- a column that
-- only keeps ONE Stripe customer per person, so any invoice/charge billed
-- to a person's other Stripe customer id silently got a null person_id
-- (dozens of rows were wrong this way on the fixture that caught it). Any
-- row returned here means that regression is back: a stripe customer whose
-- email resolves to a real person, but the invoice/charge FK failed to follow.
with invoice_should_resolve as (
    select i.id, 'invoice' as entity
    from {{ ref('invoices') }} i
    join {{ ref('stg_stripe__customer') }} c on c.customer_id = i.customer_id
    join {{ ref('persons') }} p on p.id = lower(trim(c.email))
    where c.email is not null and c.email <> '' and i.person_id is null
),
charge_should_resolve as (
    select ch.id, 'charge' as entity
    from {{ ref('charges') }} ch
    join {{ ref('stg_stripe__customer') }} c on c.customer_id = ch.customer_id
    join {{ ref('persons') }} p on p.id = lower(trim(c.email))
    where c.email is not null and c.email <> '' and ch.person_id is null
)
select * from invoice_should_resolve
union all
select * from charge_should_resolve
