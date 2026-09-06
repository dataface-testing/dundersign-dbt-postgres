select
    o.opportunity_id                            as id,
    o.account_id,
    o.owner_id,
    u.user_name                                 as owner_name,
    o.campaign_id,
    o.opportunity_name                          as name,
    o.opportunity_description                   as description,
    o.type                                      as opportunity_type,
    o.stage_name,
    o.lead_source,
    o.amount,
    o.expected_revenue,
    o.probability,
    o.is_closed,
    o.is_won,
    o.is_deleted,
    cast(o.created_date as timestamp)           as created_at,
    cast(o.close_date as timestamp)             as close_at
from {{ ref('stg_salesforce__opportunity') }} o
left join {{ ref('stg_salesforce__user') }} u on o.owner_id = u.user_id
where not coalesce(o.is_deleted, false)
