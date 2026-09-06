{{ config(materialized='view') }}

-- QuickBooks writes '' (not NULL) on every column it doesn't populate, so
-- gl_account_id needs nullif or a blank string silently survives as a value
-- and fails a downstream join without ever looking like NULL.
select
    invoice_id,
    index                                        as line_index,
    amount,
    description,
    quantity,
    detail_type,
    coalesce(nullif(account_id, ''), nullif(sales_item_account_id, '')) as gl_account_id,
    cast(_fivetran_synced as timestamp)          as _fivetran_synced
from {{ source('quickbooks', 'invoice_line') }}
where coalesce(_fivetran_active, true)
