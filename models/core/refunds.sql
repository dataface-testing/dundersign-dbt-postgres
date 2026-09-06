-- Core refunds. Built on Fivetran stripe_source staging.
-- Amount normalized from Stripe's raw cents to dollars.
select
    refund_id                                    as id,
    charge_id,
    amount / 100.0                               as amount,
    currency,
    reason,
    status,
    description,
    cast(created_at as timestamp)                as created_at
from {{ ref('stg_stripe__refund') }}
