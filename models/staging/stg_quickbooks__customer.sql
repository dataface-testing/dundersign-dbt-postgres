{{ config(materialized='view') }}

-- Billing-system customer record, one per payer (not one per company --
-- see accounts.sql). Kept as staging only, same rationale as
-- stg_netsuite__customer: no `email` column in the raw feed, only company_name.
select
    id                                           as customer_id,
    company_name,
    display_name,
    cast(_fivetran_synced as timestamp)          as _fivetran_synced
from {{ source('quickbooks', 'customer') }}
where coalesce(_fivetran_active, true)
