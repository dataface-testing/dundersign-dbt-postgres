-- gl_transactions is built on several joins per source system (mainline
-- transaction_line for NetSuite; customer/vendor resolution for both) that
-- could silently fan out a transaction into duplicates. Assert the row
-- count still matches the sum of the raw transaction-shaped tables instead
-- of trusting the join cardinality.
with raw_total as (
    select
        (select count(*) from {{ ref('stg_netsuite__transaction') }})
        + (select count(*) from {{ ref('stg_quickbooks__invoice') }})
        + (select count(*) from {{ ref('stg_quickbooks__bill') }})
        + (select count(*) from {{ ref('stg_quickbooks__payment') }})
        + (select count(*) from {{ ref('stg_quickbooks__bill_payment') }})
        + (select count(*) from {{ ref('stg_quickbooks__journal_entry') }})
        as expected
),
conformed_total as (
    select count(*) as actual from {{ ref('gl_transactions') }}
)
select expected, actual
from raw_total, conformed_total
where expected <> actual
