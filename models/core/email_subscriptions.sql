-- Core email subscriptions (HubSpot subscription-type catalog -- a tiny
-- reference table, 3 rows: "Marketing", "Product Updates", "Weekly
-- Digest"). Built on the hand-rolled stg_hubspot__email_subscription.
select
    email_subscription_id                       as id,
    name,
    description,
    active,
    portal_id,
    _fivetran_synced
from {{ ref('stg_hubspot__email_subscription') }}
