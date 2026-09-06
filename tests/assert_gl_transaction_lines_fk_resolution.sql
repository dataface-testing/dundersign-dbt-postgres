-- Regression guard for the bug where 94% of QuickBooks GL lines had an
-- unresolvable gl_account_id: stg_quickbooks__invoice_line/bill_line
-- coalesced over raw columns that are '' (not NULL) on every row, so the
-- join to gl_accounts always missed, and dbt's `relationships` test never
-- caught it because it skips NULLs by construction. Row-count guards
-- (assert_gl_transaction_lines_row_count.sql) don't catch it either -- they
-- count rows, not FK resolution. This asserts resolution directly, per
-- ledger, so a ledger-specific join regression can't hide behind the
-- other ledger's success.
select source_system, count(*) as total_lines, count(gl_account_id) as resolved_lines
from {{ ref('gl_transaction_lines') }}
group by 1
having count(*) <> count(gl_account_id)
