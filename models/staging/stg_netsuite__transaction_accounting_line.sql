{{ config(materialized='view') }}

-- Double-entry detail: one row per (transaction line x GL account) posting,
-- with its debit/credit split. transactionline has no synthetic id of its
-- own in the raw feed, so the natural key is the (transaction, transactionline)
-- pair, which is also the join back to transaction_line.
select
    transaction                                  as transaction_id,
    transactionline                               as transaction_line_id,
    account                                       as gl_account_id,
    amount,
    netamount                                     as net_amount,
    credit,
    debit,
    (posting = 'T')                               as is_posting,
    cast(_fivetran_synced as timestamp)          as _fivetran_synced
from {{ source('netsuite', 'transaction_accounting_line') }}
where coalesce(_fivetran_active, true)
