-- Core invoice line items. Built on Fivetran stripe_source staging.
-- Amounts normalized from Stripe's raw cents to dollars.
select
    invoice_line_item_id                        as id,
    invoice_id,
    subscription_id,
    price_id,
    amount / 100.0                              as amount,
    currency,
    description,
    quantity,
    type,
    is_discountable,
    proration
from {{ ref('stg_stripe__invoice_line_item') }}
