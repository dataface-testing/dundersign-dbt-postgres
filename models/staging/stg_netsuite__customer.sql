{{ config(materialized='view') }}

-- Billing-system customer record, one per payer (not one per company --
-- see accounts.sql). Kept as staging only: gl_transactions resolves the
-- account by joining companyname against accounts.name rather than exposing
-- this table as its own core entity.
select
    id                                           as customer_id,
    companyname                                  as company_name,
    email,
    cast(firstorderdate as timestamp)            as first_order_at,
    cast(_fivetran_synced as timestamp)          as _fivetran_synced
from {{ source('netsuite', 'customer') }}
where coalesce(_fivetran_active, true)
