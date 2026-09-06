{{ config(materialized='view') }}

select
    id                                           as bill_id,
    doc_number,
    vendor_id,
    total_amount,
    balance,
    cast(transaction_date as date)               as transaction_at,
    cast(due_date as date)                       as due_at,
    cast(_fivetran_synced as timestamp)          as _fivetran_synced
from {{ source('quickbooks', 'bill') }}
where coalesce(_fivetran_active, true)
