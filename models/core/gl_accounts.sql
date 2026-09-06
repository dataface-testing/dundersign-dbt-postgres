-- GL chart of accounts, conformed. NetSuite and QuickBooks each carry the
-- same 7-account chart (Cash, Accounts Receivable, Accounts Payable,
-- Subscription Revenue, Payroll Expense, Software & Cloud Expense, Office
-- Expense) under identical names -- unlike gl_transactions, this is a shared
-- reference concept, not a disjoint stream of events, so it collapses to one
-- row per account with both systems' ids retained (no source_system needed).
with netsuite_account as (
    select account_id, account_number, account_type, name, is_inactive
    from {{ ref('stg_netsuite__account') }}
),
quickbooks_account as (
    select account_id, account_number, account_type, name, is_inactive
    from {{ ref('stg_quickbooks__account') }}
)
select
    coalesce(ns.name, qb.name)                  as id,
    coalesce(ns.name, qb.name)                  as name,
    ns.account_id                                as netsuite_account_id,
    ns.account_type                              as netsuite_account_type,
    qb.account_id                                as quickbooks_account_id,
    qb.account_type                              as quickbooks_account_type,
    coalesce(ns.is_inactive, false) or coalesce(qb.is_inactive, false) as is_inactive
from netsuite_account ns
full outer join quickbooks_account qb on qb.name = ns.name
