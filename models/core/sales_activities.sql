-- Sales activities, conformed (Nimble): salesforce.task + salesforce.event
-- unioned with an activity_type discriminator. Salesforce's who_id/what_id
-- are polymorphic lookups (who_id -> Contact/Lead, what_id ->
-- Account/Opportunity/etc). Investigated all 4 rows in this fixture (3
-- tasks, 1 event) rather than guessing a generic resolution: every
-- account_id/what_id/who_id on every row is blank, so there is nothing to
-- resolve to a concrete entity here. They're carried through as raw
-- nullable ids (blank normalized to null) instead of being force-matched --
-- no relationships test is declared for them since a single column can't be
-- tested against two possible parent tables.
with task_activity as (
    select
        task_id                                    as id,
        'task'                                       as activity_type,
        subject,
        task_description                             as description,
        status,
        priority,
        nullif(account_id, '')                        as account_id,
        nullif(what_id, '')                           as what_id,
        nullif(who_id, '')                            as who_id,
        nullif(owner_id, '')                          as owner_id_raw,
        cast(activity_date as date)                   as activity_at,
        cast(created_date as timestamp)               as created_at
    from {{ ref('stg_salesforce__task') }}
),
event_activity as (
    select
        event_id                                     as id,
        'event'                                        as activity_type,
        subject,
        event_description                              as description,
        cast(null as {{ dbt.type_string() }})          as status,
        cast(null as {{ dbt.type_string() }})          as priority,
        nullif(account_id, '')                          as account_id,
        nullif(what_id, '')                             as what_id,
        nullif(who_id, '')                              as who_id,
        nullif(owner_id, '')                            as owner_id_raw,
        cast(activity_date as date)                     as activity_at,
        cast(created_date as timestamp)                 as created_at
    from {{ ref('stg_salesforce__event') }}
),
activity as (
    select * from task_activity
    union all
    select * from event_activity
)
select
    a.id,
    a.activity_type,
    a.subject,
    a.description,
    a.status,
    a.priority,
    a.account_id,
    a.what_id,
    a.who_id,
    e.id                                              as owner_id,
    a.activity_at,
    a.created_at
from activity a
left join {{ ref('employees') }} e on e.salesforce_user_id = a.owner_id_raw
