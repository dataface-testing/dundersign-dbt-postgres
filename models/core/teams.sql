select
    team_id                                     as id,
    team_name,
    owner_user_id,
    plan,
    seats_purchased,
    billing_email,
    is_active,
    created_at,
    plan_started_at,
    _fivetran_synced
from {{ ref('stg_product_db__team') }}
