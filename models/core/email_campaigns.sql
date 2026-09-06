-- Core email campaigns. Built on Fivetran hubspot_source staging.
select
    email_campaign_id                           as id,
    email_campaign_name                         as name,
    email_campaign_type                         as campaign_type,
    email_campaign_sub_type                     as campaign_sub_type,
    email_campaign_subject                      as subject,
    app_id,
    app_name,
    content_id,
    num_included,
    num_queued,
    _fivetran_synced
from {{ ref('stg_hubspot__email_campaign') }}
