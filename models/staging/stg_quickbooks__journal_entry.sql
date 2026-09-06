{{ config(materialized='view') }}

select
    id                                           as journal_entry_id,
    doc_number,
    total_amount,
    adjustment                                   as is_adjustment,
    cast(transaction_date as date)               as transaction_at,
    cast(_fivetran_synced as timestamp)          as _fivetran_synced
from {{ source('quickbooks', 'journal_entry') }}
where coalesce(_fivetran_active, true)
