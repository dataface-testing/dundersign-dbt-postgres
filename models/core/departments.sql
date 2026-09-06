-- Recruiting: one row per department. parent_id self-references for
-- sub-departments; null for top-level departments.
select
    d.department_id                                as id,
    d.external_id,
    d.name,
    d.parent_id
from {{ ref('stg_greenhouse__department') }} d
