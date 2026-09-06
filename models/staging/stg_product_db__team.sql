{{ config(materialized='view') }}

select
    id                                          as team_id,
    name                                        as team_name,
    owner_user_id,
    plan,
    seats_purchased,
    billing_email,
    is_active,
    cast(created_at as timestamp)               as created_at,
    cast(plan_started_at as timestamp)          as plan_started_at,
    cast(_fivetran_synced as timestamp)         as _fivetran_synced
from {{ source('product_db', 'team') }}
where coalesce(_fivetran_active, true)
