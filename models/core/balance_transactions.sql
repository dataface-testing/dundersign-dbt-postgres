-- Core balance transactions. Built on Fivetran stripe_source staging.
-- `source` is polymorphic in this fixture: it settles either a charge or a
-- refund, distinguished by id prefix (ch_/re_) -- verified by id prefix, not
-- assumed. charge_id is derived from it and left null on refund-settling
-- rows rather than force-matched.
-- Amounts normalized from Stripe's raw cents to dollars.
select
    bt.balance_transaction_id                    as id,
    bt.source,
    c.id                                          as charge_id,
    bt.type,
    bt.status,
    bt.amount / 100.0                            as amount,
    bt.fee / 100.0                                as fee,
    bt.net / 100.0                                as net,
    bt.currency,
    bt.reporting_category,
    bt.description,
    cast(bt.created_at as timestamp)              as created_at,
    cast(bt.available_on as timestamp)            as available_on_at
from {{ ref('stg_stripe__balance_transaction') }} bt
left join {{ ref('charges') }} c on c.id = bt.source
