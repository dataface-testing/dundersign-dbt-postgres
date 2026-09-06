-- Core subscriptions. Built on Fivetran stripe_source staging.
-- customer_id strips the 'cus_' prefix to land on user_id (1:1 in our sim).
-- price_id comes from stg_stripe__subscription_price, not from
-- stg_stripe__subscription: the Fivetran package drops it, and it is the only
-- carrier of plan identity in the feed (see that model's header).
select
    s.subscription_id                           as id,
    s.customer_id,
    replace(s.customer_id, 'cus_', '')          as user_id,
    p.price_id,
    s.latest_invoice_id,
    s.default_payment_method_id,
    s.status,
    s.billing,
    s.days_until_due,
    cast(s.created_at as timestamp)             as created_at,
    cast(s.billing_cycle_anchor as timestamp)   as billing_cycle_anchor_at,
    cast(s.current_period_start as timestamp)   as current_period_start_at,
    cast(s.current_period_end as timestamp)     as current_period_end_at,
    cast(s.canceled_at as timestamp)            as canceled_at,
    cast(s.cancel_at as timestamp)              as cancel_at,
    s.is_cancel_at_period_end,
    cast(s.start_date_at as timestamp)          as start_date_at,
    cast(s.ended_at as timestamp)               as ended_at
from {{ ref('stg_stripe__subscription') }} s
left join {{ ref('stg_stripe__subscription_price') }} p
    on p.subscription_id = s.subscription_id
