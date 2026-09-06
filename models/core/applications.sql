-- Recruiting: one row per candidate application to a job. current_stage_id
-- and prospect_stage_id are raw greenhouse.job_stage ids, carried through
-- unchanged (job_stages.id conforms 1:1 to the raw id -- no join needed,
-- see gl_transactions.accounting_period_id for the same convention).
-- credited_to_user_id resolves through employees the same way
-- candidates.recruiter_id/coordinator_id do (greenhouse_user_id bridge).
-- prospect_owner_id does not resolve in this fixture -- the raw feed leaves
-- it blank on every row, so prospect_owner_employee_id is null throughout.
select
    a.application_id                               as id,
    a.candidate_id,
    a.current_stage_id,
    a.prospect_stage_id,
    a.source_id,
    credited.id                                     as credited_to_employee_id,
    owner.id                                        as prospect_owner_employee_id,
    a.prospect_pool_id,
    a.rejected_reason_id,
    a.status,
    a.is_prospect,
    a.is_deleted,
    a.location_address,
    a.applied_at,
    a.last_activity_at,
    a.rejected_at
from {{ ref('stg_greenhouse__application') }} a
left join {{ ref('employees') }} credited on credited.greenhouse_user_id = a.credited_to_user_id
left join {{ ref('employees') }} owner     on owner.greenhouse_user_id = a.prospect_owner_id
