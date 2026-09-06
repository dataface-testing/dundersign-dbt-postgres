{{ config(materialized='view') }}

select
    id                                           as transaction_line_id,
    transaction                                  as transaction_id,
    linesequencenumber                           as line_sequence_number,
    item                                          as item_id,
    (mainline = 'T')                              as is_mainline,
    netamount                                     as net_amount,
    cast(_fivetran_synced as timestamp)          as _fivetran_synced
from {{ source('netsuite', 'transaction_line') }}
where coalesce(_fivetran_active, true)
