-- Core marketing lists (HubSpot contact-list catalog). Built on Fivetran
-- hubspot_source staging. Deliberately split from membership: a list's
-- name/metadata and a person's membership in it are different grains --
-- see marketing_list_memberships.sql and _schema_marketing.yml.
select
    contact_list_id                             as id,
    contact_list_name                           as name,
    processing_status,
    processing_type,
    is_dynamic,
    is_deletable,
    is_contact_list_deleted,
    list_version,
    object_type_id,
    created_by_id,
    created_timestamp,
    updated_timestamp,
    _fivetran_synced
from {{ ref('stg_hubspot__contact_list') }}
