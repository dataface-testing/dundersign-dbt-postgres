-- Orders, conformed (Nimble). Thin in this fixture (1 row), modeled anyway
-- per the initiative's entity list. account_id/opportunity_id/owner_id come
-- through blank ('') on the raw row rather than null -- nullif'd here so an
-- unresolved FK reads as null, not a dangling empty string.
select
    o.order_id                                  as id,
    o.order_number,
    nullif(o.account_id, '')                    as account_id,
    nullif(o.opportunity_id, '')                as opportunity_id,
    e.id                                        as owner_id,
    o.status,
    o.type                                      as order_type,
    o.total_amount,
    cast(o.created_date as timestamp)           as created_at,
    cast(o.activated_date as timestamp)         as activated_at,
    cast(o.end_date as date)                    as end_at,
    o.billing_city,
    o.billing_state,
    o.billing_country
from {{ ref('stg_salesforce__order') }} o
left join {{ ref('employees') }} e on e.salesforce_user_id = nullif(o.owner_id, '')
