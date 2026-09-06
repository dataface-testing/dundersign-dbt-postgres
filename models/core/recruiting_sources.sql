-- Recruiting: one row per candidate source (referral, job board, etc).
select
    s.source_id                                    as id,
    s.name,
    s.source_type_id,
    s.source_type_name
from {{ ref('stg_greenhouse__source') }} s
