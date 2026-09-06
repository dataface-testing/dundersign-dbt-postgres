{{ config(materialized='view') }}

-- hubspot_source has no staging model for this table either (same source
-- gap as stg_hubspot__email_subscription). recipient is a bare email
-- string in this raw table -- no contact_id -- unlike most other hubspot
-- tables.
select
    email_subscription_id,
    portal_id,
    recipient,
    change,
    change_type,
    source,
    cast(timestamp as timestamp)                  as changed_at,
    cast(_fivetran_synced as timestamp)            as _fivetran_synced
from {{ source('hubspot', 'email_subscription_change') }}
where coalesce(_fivetran_active, true)
