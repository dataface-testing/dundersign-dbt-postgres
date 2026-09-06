-- Vendors, conformed. Same rationale as gl_accounts: NetSuite and QuickBooks
-- share the exact same 3 vendors (AWS, Google Workspace, WeWork) by name, so
-- this collapses to one row per vendor rather than a source_system-tagged
-- union.
with netsuite_vendor as (
    select vendor_id, name, category, created_at
    from {{ ref('stg_netsuite__vendor') }}
),
quickbooks_vendor as (
    select vendor_id, name
    from {{ ref('stg_quickbooks__vendor') }}
)
select
    coalesce(ns.name, qb.name)                  as id,
    coalesce(ns.name, qb.name)                  as name,
    ns.category,
    ns.vendor_id                                 as netsuite_vendor_id,
    qb.vendor_id                                 as quickbooks_vendor_id
from netsuite_vendor ns
full outer join quickbooks_vendor qb on qb.name = ns.name
