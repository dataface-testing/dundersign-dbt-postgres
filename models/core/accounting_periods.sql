-- Accounting periods. NetSuite-only: QuickBooks has no equivalent construct
-- in this fixture (see spec.md), so gl_transactions.accounting_period_id is
-- null for every QuickBooks-sourced row.
select
    accounting_period_id                        as id,
    period_name,
    start_at,
    end_at,
    is_closed
from {{ ref('stg_netsuite__accounting_period') }}
