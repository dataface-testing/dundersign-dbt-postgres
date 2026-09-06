{{ config(materialized='view') }}

-- No natural id column in the raw feed -- the surrogate PK is minted in
-- models/core/application_stages.sql, same convention as gl_transaction_lines.
select
    application_id,
    new_stage_id,
    new_status,
    cast(updated_at as timestamp)                  as updated_at,
    cast(_fivetran_synced as timestamp)            as _fivetran_synced
from {{ source('greenhouse', 'application_history') }}
where coalesce(_fivetran_active, true)
