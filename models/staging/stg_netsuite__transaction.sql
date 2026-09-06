{{ config(materialized='view') }}

-- type: CustInvc (customer invoice), CustPymt (customer payment),
-- VendBill (vendor bill), VendPymt (vendor payment), Journal.
-- entity is a customer id for Cust* types, a vendor id for Vend* types, and
-- blank for Journal.
select
    id                                           as transaction_id,
    transactionnumber                            as transaction_number,
    type                                         as transaction_type,
    memo,
    status,
    entity                                       as entity_id,
    postingperiod                                as accounting_period_id,
    cast(trandate as timestamp)                  as transaction_at,
    cast(createddate as timestamp)                as created_at,
    cast(closedate as timestamp)                  as closed_at,
    cast(_fivetran_synced as timestamp)          as _fivetran_synced
from {{ source('netsuite', 'transaction') }}
where coalesce(_fivetran_active, true)
