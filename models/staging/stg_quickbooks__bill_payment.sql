{{ config(materialized='view') }}

-- Vendor payment (AP cash-out). Distinct from payment (AR cash-in).
select
    id                                           as bill_payment_id,
    vendor_id,
    total_amount,
    pay_type,
    cast(transaction_date as date)               as transaction_at,
    cast(_fivetran_synced as timestamp)          as _fivetran_synced
from {{ source('quickbooks', 'bill_payment') }}
where coalesce(_fivetran_active, true)
