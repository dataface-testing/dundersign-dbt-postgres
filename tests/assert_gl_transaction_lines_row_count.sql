-- Same fan-out guard as assert_gl_transactions_row_count.sql, one layer
-- down: gl_transaction_lines joins each ledger's line detail to
-- gl_accounts (name-matched, not id-matched, for QuickBooks) which could
-- silently duplicate a line if two accounts ever shared a name.
with raw_total as (
    select
        (select count(*) from {{ ref('stg_netsuite__transaction_accounting_line') }})
        + (select count(*) from {{ ref('stg_quickbooks__invoice_line') }})
        + (select count(*) from {{ ref('stg_quickbooks__bill_line') }})
        + (select count(*) from {{ ref('stg_quickbooks__journal_entry_line') }})
        as expected
),
conformed_total as (
    select count(*) as actual from {{ ref('gl_transaction_lines') }}
)
select expected, actual
from raw_total, conformed_total
where expected <> actual
