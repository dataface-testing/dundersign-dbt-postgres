{{ config(materialized='view') }}

select
    journal_entry_id,
    index                                        as line_index,
    account_id                                   as gl_account_id,
    amount,
    posting_type,
    description,
    cast(_fivetran_synced as timestamp)          as _fivetran_synced
from {{ source('quickbooks', 'journal_entry_line') }}
where coalesce(_fivetran_active, true)
