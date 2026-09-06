-- Core charges. Built on Fivetran stripe_source staging.
-- person_id/account_id resolve the same way as invoices.sql -- see that
-- model's header for why person_id joins stg_stripe__customer directly
-- rather than persons.primary_stripe_customer_id.
-- Amounts normalized from Stripe's raw cents to dollars.
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
    c.charge_id                                 as id,
    c.customer_id,
    cp.person_id,
    ca.account_id,
    nullif(c.invoice_id, '')                    as invoice_id,
    c.status,
    c.amount / 100.0                            as amount,
    c.amount_refunded / 100.0                   as amount_refunded,
    c.currency,
    c.is_paid,
    c.is_captured,
    c.is_refunded,
    c.description,
    c.failure_code,
    c.failure_message,
    cast(c.created_at as timestamp)             as created_at
from {{ ref('stg_stripe__charge') }} c
left join customer_person cp on cp.customer_id = c.customer_id
left join customer_account ca on ca.customer_id = c.customer_id
