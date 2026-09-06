-- Core marketing forms. Built on Fivetran hubspot_source staging.
select
    form_id                                     as id,
    form_name                                   as name,
    form_type,
    action,
    method,
    submit_text,
    redirect,
    css_class,
    follow_up_id,
    lead_nurturing_campaign_id,
    notify_recipients,
    portal_id,
    created_at,
    updated_at
from {{ ref('stg_hubspot__form') }}
