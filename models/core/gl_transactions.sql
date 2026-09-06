-- GL transaction headers, conformed across both ledgers. `source_system`
-- discriminates NetSuite from QuickBooks: unlike gl_accounts/vendors, a
-- transaction is a disjoint economic event -- each conversion's invoice
-- posts to exactly one system (QuickBooks before MIGRATION_DAY, NetSuite
-- from then on; see the generator's `current_gl_system()`) -- so there is no
-- shared identity to collapse and no risk of double-counting across the
-- cutover.
--
-- Unit note: NetSuite amounts are stored in cents in the raw feed (the
-- generator posts `amount_cents` directly), QuickBooks amounts in dollars
-- (the generator divides by 100 before posting). Both are normalized to
-- dollars here so the two ledgers are comparable.
with netsuite_customer_account as (
    select c.customer_id, a.id as account_id
    from {{ ref('stg_netsuite__customer') }} c
    join {{ ref('accounts') }} a on a.name = c.company_name
),
netsuite_vendor_ref as (
    select v.vendor_id, gv.id as vendor_id_conformed
    from {{ ref('stg_netsuite__vendor') }} v
    join {{ ref('vendors') }} gv on gv.name = v.name
),
netsuite_txn as (
    select
        t.transaction_id                        as id,
        'netsuite'                                as source_system,
        t.transaction_type,
        t.transaction_at,
        cast(null as timestamp)                   as due_at,
        tl.net_amount / 100.0                      as amount,
        case when t.transaction_type in ('CustInvc', 'CustPymt') then nca.account_id end as account_id,
        case when t.transaction_type in ('VendBill', 'VendPymt') then nvr.vendor_id_conformed end as vendor_id,
        t.accounting_period_id
    from {{ ref('stg_netsuite__transaction') }} t
    join {{ ref('stg_netsuite__transaction_line') }} tl
        on tl.transaction_id = t.transaction_id and tl.is_mainline
    left join netsuite_customer_account nca on nca.customer_id = t.entity_id
    left join netsuite_vendor_ref nvr on nvr.vendor_id = t.entity_id
),
quickbooks_customer_account as (
    select c.customer_id, a.id as account_id
    from {{ ref('stg_quickbooks__customer') }} c
    join {{ ref('accounts') }} a on a.name = c.company_name
),
quickbooks_vendor_ref as (
    select v.vendor_id, gv.id as vendor_id_conformed
    from {{ ref('stg_quickbooks__vendor') }} v
    join {{ ref('vendors') }} gv on gv.name = v.name
),
quickbooks_txn as (
    select invoice_id as id, 'invoice' as transaction_type, transaction_at, due_at, total_amount as amount,
           customer_id as ref_id, 'customer' as ref_type
    from {{ ref('stg_quickbooks__invoice') }}
    union all
    select bill_id, 'bill', transaction_at, due_at, total_amount, vendor_id, 'vendor'
    from {{ ref('stg_quickbooks__bill') }}
    union all
    select payment_id, 'payment', transaction_at, cast(null as date), total_amount, customer_id, 'customer'
    from {{ ref('stg_quickbooks__payment') }}
    union all
    select bill_payment_id, 'bill_payment', transaction_at, cast(null as date), total_amount, vendor_id, 'vendor'
    from {{ ref('stg_quickbooks__bill_payment') }}
    union all
    select journal_entry_id, 'journal_entry', transaction_at, cast(null as date), total_amount, cast(null as {{ dbt.type_string() }}), cast(null as {{ dbt.type_string() }})
    from {{ ref('stg_quickbooks__journal_entry') }}
),
quickbooks_final as (
    select
        qt.id,
        'quickbooks'                              as source_system,
        qt.transaction_type,
        cast(qt.transaction_at as timestamp)      as transaction_at,
        cast(qt.due_at as timestamp)              as due_at,
        qt.amount,
        case when qt.ref_type = 'customer' then qca.account_id end as account_id,
        case when qt.ref_type = 'vendor' then qvr.vendor_id_conformed end as vendor_id,
        cast(null as {{ dbt.type_string() }})     as accounting_period_id
    from quickbooks_txn qt
    left join quickbooks_customer_account qca on qca.customer_id = qt.ref_id and qt.ref_type = 'customer'
    left join quickbooks_vendor_ref qvr on qvr.vendor_id = qt.ref_id and qt.ref_type = 'vendor'
)
select * from netsuite_txn
union all
select * from quickbooks_final
