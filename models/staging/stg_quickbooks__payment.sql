{{ config(materialized='view') }}

-- Customer payment (AR cash-in). Distinct from bill_payment (AP cash-out).
select
    id                                           as payment_id,
    customer_id,
    total_amount,
    unapplied_amount,
    cast(transaction_date as date)               as transaction_at,
    cast(_fivetran_synced as timestamp)          as _fivetran_synced
from {{ source('quickbooks', 'payment') }}
where coalesce(_fivetran_active, true)
