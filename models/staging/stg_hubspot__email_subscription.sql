{{ config(materialized='view') }}

-- hubspot_source has no staging model for this table (declared in the
-- package's src_hubspot.yml, but not built out) -- hand-rolled here
-- following the same 1:1 cleanup convention as the Fivetran packages.
select
    id                                            as email_subscription_id,
    portal_id,
    name,
    description,
    active,
    cast(_fivetran_synced as timestamp)           as _fivetran_synced
from {{ source('hubspot', 'email_subscription') }}
where coalesce(_fivetran_active, true)
