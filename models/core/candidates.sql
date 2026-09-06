-- Recruiting: one row per Greenhouse candidate. recruiter_id/coordinator_id
-- on the raw table are greenhouse.user ids, resolved to employees.id via the
-- greenhouse_user_id bridge on the employees spine (see employees.sql --
-- only Toby Flenderson resolves; Holly Flax has no Workday record). That
-- bridge joins on greenhouse.user.primary_email_address, not on an id --
-- greenhouse.user.employee_id is unpopulated in this fixture.
select
    c.candidate_id                                as id,
    c.first_name,
    c.last_name,
    c.title,
    c.company,
    c.is_private,
    c.photo_url,
    c.new_candidate_id,
    rec.id                                         as recruiter_employee_id,
    coord.id                                       as coordinator_employee_id,
    c.created_at,
    c.last_activity_at,
    c.updated_at
from {{ ref('stg_greenhouse__candidate') }} c
left join {{ ref('employees') }} rec   on rec.greenhouse_user_id = c.recruiter_id
left join {{ ref('employees') }} coord on coord.greenhouse_user_id = c.coordinator_id
