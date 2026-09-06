-- Employees spine (Nimble conformance; extends the old `workers` entity).
-- Workday stays normalized in core via worker_histories / positions /
-- worker_positions / job_profiles; employees is the conformed "one row per
-- employee" entity, extended with the per-system ids every other domain
-- FKs into: the sales rep on an opportunity, the agent on a ticket, the
-- recruiter on an application, the owner on a marketing contact.
--
-- Every system in this company shares one @dundersign.com work-email
-- namespace, so the join key is that email, lowercased -- greenhouse.user
-- included, via its primary_email_address (its employee_id is '' on every
-- row, so the address is the only usable key back to the employee).
--
-- The address is allocated once per person by the generator, so two
-- employees who share a full name are still two people with two addresses.
-- Matching Greenhouse on full name instead -- which this model used to do --
-- fanned every downstream candidate/application join out 2x the moment a
-- namesake was hired, which at a 3-year roster is a near-certainty.
with worker as (
    select * from {{ ref('worker_histories') }}
),
person as (
    select personal_info_system_id, first_name, last_name
    from (
        select
            personal_info_system_id,
            first_name,
            last_name,
            row_number() over (
                partition by personal_info_system_id
                order by case when name_type = 'Legal' then 0 else 1 end, person_name_index
            ) as rn
        from {{ ref('person_names') }}
    ) ranked
    where rn = 1
),
email as (
    select personal_info_system_id, email_address, email_code
    from (
        select
            personal_info_system_id,
            email_address,
            email_code,
            row_number() over (
                partition by personal_info_system_id
                order by case when email_code = 'WORK' then 0 else 1 end, id
            ) as rn
        from {{ ref('person_contact_email_addresses') }}
    ) ranked
    where rn = 1
),
position_history as (
    select
        worker_id,
        position_id,
        job_profile_id,
        business_title,
        employee_type,
        scheduled_weekly_hours,
        full_time_equivalent_percentage,
        pay_rate,
        pay_rate_type,
        frequency,
        row_number() over (partition by worker_id order by effective_at desc, id desc) as rn
    from {{ ref('worker_positions') }}
),
job_profile as (
    select
        id                                      as job_profile_id,
        title,
        department
    from {{ ref('job_profiles') }}
),
sf_user as (
    select user_id, lower(trim(email)) as work_email
    from {{ ref('stg_salesforce__user') }}
    where email is not null and email <> ''
),
zd_agent as (
    select user_id, lower(trim(email)) as work_email
    from {{ ref('stg_zendesk__user') }}
    where role = 'agent' and email is not null and email <> ''
),
hs_owner as (
    select owner_id, lower(trim(email_address)) as work_email
    from {{ ref('stg_hubspot__owner') }}
    where email_address is not null and email_address <> ''
),
gh_user as (
    select id as user_id, lower(trim(primary_email_address)) as work_email
    from {{ source('greenhouse', 'user') }}
    where coalesce(_fivetran_active, true)
      and primary_email_address is not null and primary_email_address <> ''
)
select
    w.id                                        as id,
    w.worker_code,
    w.universal_id,
    w.user_id,
    w.home_country,
    pn.first_name,
    pn.last_name,
    em.email_address,
    em.email_code                               as primary_email_code,
    ph.position_id,
    ph.business_title,
    ph.employee_type,
    ph.scheduled_weekly_hours,
    ph.full_time_equivalent_percentage,
    ph.pay_rate,
    ph.pay_rate_type,
    ph.frequency,
    jp.title                                    as job_title,
    jp.department,
    w.is_active,
    w.hired_at,
    w.terminated_at,
    w.original_hired_at,
    w.first_day_of_work_at,
    w.is_rehire,
    w.is_retired,
    sf.user_id                                  as salesforce_user_id,
    zd.user_id                                  as zendesk_user_id,
    hs.owner_id                                 as hubspot_owner_id,
    gh.user_id                                  as greenhouse_user_id,
    w._fivetran_synced
from worker w
left join person pn       on pn.personal_info_system_id = w.id
left join email em        on em.personal_info_system_id = w.id
left join position_history ph on ph.worker_id = w.id and ph.rn = 1
left join job_profile jp  on jp.job_profile_id = ph.job_profile_id
left join sf_user sf      on sf.work_email = lower(trim(em.email_address))
left join zd_agent zd     on zd.work_email = lower(trim(em.email_address))
left join hs_owner hs     on hs.work_email = lower(trim(em.email_address))
left join gh_user gh      on gh.work_email = lower(trim(em.email_address))
