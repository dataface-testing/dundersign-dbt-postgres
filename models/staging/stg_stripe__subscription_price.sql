{{ config(materialized='view') }}

-- Hand-rolled staging for the one subscription field the Fivetran
-- stripe_source package drops: price_id. Stripe's modern API hangs the price
-- off subscription *items*, so stg_stripe__subscription models the item-less
-- shape -- but this feed flattens the price onto the subscription row, and it
-- is the only carrier of plan identity (monthly vs annual) anywhere in the
-- warehouse: invoice_line_item.price_id is blank on every row. Same reason
-- stg_zendesk__satisfaction_rating.sql exists.
select
    id                                          as subscription_id,
    nullif(price_id, '')                        as price_id
from {{ source('stripe', 'subscription') }}
where coalesce(_fivetran_active, true)
