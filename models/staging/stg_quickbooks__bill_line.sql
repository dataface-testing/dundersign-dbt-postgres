{{ config(materialized='view') }}

-- gl_account_id only comes from account_expense_account_id -- QuickBooks
-- writes '' (not NULL) on every column it doesn't populate, so nullif is
-- required or a blank string silently survives as a value. item_expense_item_id
-- is deliberately NOT a fallback here: it's an item id, not an account id --
-- coalescing it in put the wrong kind of id in an account-id column.
select
    bill_id,
    index                                        as line_index,
    amount,
    description,
    nullif(account_expense_account_id, '')       as gl_account_id,
    cast(_fivetran_synced as timestamp)          as _fivetran_synced
from {{ source('quickbooks', 'bill_line') }}
where coalesce(_fivetran_active, true)
