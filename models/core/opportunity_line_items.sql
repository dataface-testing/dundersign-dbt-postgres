-- Opportunity line items, conformed (Nimble). Thin in this fixture (1 row),
-- modeled anyway per the initiative's entity list. opportunity_id and
-- product_id come through blank ('') on the raw row rather than null --
-- nullif'd here so an unresolved FK reads as null, not a dangling empty
-- string.
select
    oli.opportunity_line_item_id                as id,
    nullif(oli.opportunity_id, '')              as opportunity_id,
    nullif(oli.product_2_id, '')                as product_id,
    oli.opportunity_line_item_name              as name,
    oli.quantity,
    oli.unit_price,
    oli.total_price,
    oli.list_price,
    oli.discount,
    cast(oli.service_date as date)              as service_at
from {{ ref('stg_salesforce__opportunity_line_item') }} oli
