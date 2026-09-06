{{ config(materialized='view') }}

select
    id                                           as invoice_id,
    doc_number,
    customer_id,
    total_amount,
    balance,
    cast(transaction_date as date)               as transaction_at,
    cast(due_date as date)                       as due_at,
    cast(_fivetran_synced as timestamp)          as _fivetran_synced
from {{ source('quickbooks', 'invoice') }}
where coalesce(_fivetran_active, true)
