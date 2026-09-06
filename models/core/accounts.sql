-- Accounts spine (Nimble conformance). One row per company, keyed on
-- salesforce.account -- the CRM is where an account is minted exactly once
-- per company name (`_sales_account` in the generator caches by name), so
-- every other system's customer record collapses onto it 1:1 by
-- construction.
--
-- netsuite.customer and quickbooks.customer are NOT joined in here: both
-- mint a new billing-system customer per *payer*, not per company (a company
-- can show up as several GL customer records over time), so the
-- relationship is many-to-one. Rather than lossily picking one GL customer
-- id per account, downstream GL/billing models carry `account_id`, resolved
-- by joining this table's `name` against the billing/GL customer name.
select
    a.account_id                                as id,
    a.account_name                               as name,
    nullif(a.website, '')                        as website,
    nullif(a.industry, '')                       as industry,
    nullif(a.type, '')                            as account_type,
    a.account_source,
    a.annual_revenue,
    a.number_of_employees,
    a.billing_city,
    a.billing_state,
    a.billing_country,
    e.id                                          as employee_id
from {{ ref('stg_salesforce__account') }} a
left join {{ ref('employees') }} e on e.salesforce_user_id = a.owner_id
