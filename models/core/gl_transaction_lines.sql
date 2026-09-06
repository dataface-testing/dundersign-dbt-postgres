-- GL transaction line detail, conformed across both ledgers. Same
-- source_system rationale as gl_transactions: lines are children of a
-- disjoint transaction, so no collapsing across systems.
--
-- Sign convention (both ledgers, conformed): `amount` is signed
-- debit-positive / credit-negative, matching NetSuite's native
-- transaction_accounting_line.netamount. QuickBooks's invoice_line/bill_line
-- carry only an unsigned amount plus which side they're on by construction
-- (a sales-item line is always the credit/revenue side, an expense line
-- always the debit side) -- signed here to match. `debit`/`credit` are
-- always populated (0.0, never NULL, on the side that doesn't apply) so
-- `sum(debit)`/`count(debit)` mean the same thing on every row regardless
-- of ledger.
--
-- NetSuite: transaction_accounting_line already carries the double-entry
-- grain, one row per (transaction, transactionline); joined to
-- transaction_line only for the item reference.
--
-- Amounts normalized to dollars (see gl_transactions.sql for the NetSuite
-- cents vs. QuickBooks dollars unit note).
with netsuite_lines as (
    select
        tal.transaction_line_id                 as id,
        tal.transaction_id,
        'netsuite'                                as source_system,
        -- Fivetran's NetSuite package types this STRING; the QuickBooks branches
        -- below are INT64. DuckDB unions the two silently, BigQuery refuses.
        cast(tl.line_sequence_number as {{ dbt.type_int() }}) as line_sequence_number,
        ga.id                                      as gl_account_id,
        tal.amount / 100.0                          as amount,
        tal.debit / 100.0                           as debit,
        tal.credit / 100.0                          as credit,
        cast(null as {{ dbt.type_string() }})       as description
    from {{ ref('stg_netsuite__transaction_accounting_line') }} tal
    left join {{ ref('stg_netsuite__transaction_line') }} tl
        on tl.transaction_line_id = tal.transaction_line_id
    left join {{ ref('gl_accounts') }} ga
        on ga.netsuite_account_id = tal.gl_account_id
),
quickbooks_invoice_lines as (
    -- Every QuickBooks invoice line is revenue: the credit side.
    select
        invoice_id || '_' || line_index            as id,
        invoice_id                                   as transaction_id,
        'quickbooks'                                 as source_system,
        line_index                                   as line_sequence_number,
        ga.id                                          as gl_account_id,
        -1 * il.amount                                 as amount,
        0.0                                             as debit,
        il.amount                                      as credit,
        il.description
    from {{ ref('stg_quickbooks__invoice_line') }} il
    left join {{ ref('stg_quickbooks__account') }} qa on qa.account_id = il.gl_account_id
    left join {{ ref('gl_accounts') }} ga on ga.quickbooks_account_id = qa.account_id
),
quickbooks_bill_lines as (
    -- Every QuickBooks bill line is an expense: the debit side.
    select
        bill_id || '_' || line_index                as id,
        bill_id                                       as transaction_id,
        'quickbooks'                                  as source_system,
        line_index                                    as line_sequence_number,
        ga.id                                           as gl_account_id,
        bl.amount,
        bl.amount                                       as debit,
        0.0                                              as credit,
        bl.description
    from {{ ref('stg_quickbooks__bill_line') }} bl
    left join {{ ref('stg_quickbooks__account') }} qa on qa.account_id = bl.gl_account_id
    left join {{ ref('gl_accounts') }} ga on ga.quickbooks_account_id = qa.account_id
),
quickbooks_je_lines as (
    select
        journal_entry_id || '_' || line_index        as id,
        journal_entry_id                               as transaction_id,
        'quickbooks'                                    as source_system,
        line_index                                      as line_sequence_number,
        ga.id                                             as gl_account_id,
        case when jel.posting_type = 'Debit' then jel.amount else -1 * jel.amount end as amount,
        case when jel.posting_type = 'Debit' then jel.amount else 0.0 end  as debit,
        case when jel.posting_type = 'Credit' then jel.amount else 0.0 end as credit,
        jel.description
    from {{ ref('stg_quickbooks__journal_entry_line') }} jel
    left join {{ ref('stg_quickbooks__account') }} qa on qa.account_id = jel.gl_account_id
    left join {{ ref('gl_accounts') }} ga on ga.quickbooks_account_id = qa.account_id
)
select * from netsuite_lines
union all
select * from quickbooks_invoice_lines
union all
select * from quickbooks_bill_lines
union all
select * from quickbooks_je_lines
