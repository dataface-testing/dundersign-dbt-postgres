-- Recruiting: application x stage transition history. The raw feed has no
-- id column, so the PK is minted per-application from the transition order
-- (same convention as gl_transaction_lines' invoice_id || '_' || line_index).
select
    h.application_id || '_' || cast(
        row_number() over (partition by h.application_id order by h.updated_at, h.new_stage_id)
        as {{ dbt.type_string() }}
    )                                               as id,
    h.application_id,
    h.new_stage_id,
    h.new_status,
    h.updated_at
from {{ ref('stg_greenhouse__application_history') }} h
