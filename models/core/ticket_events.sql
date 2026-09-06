-- Ticket field-history events (status/priority transitions). Built on
-- Fivetran zendesk_source staging. The raw feed has no id column; the PK is
-- minted from the (ticket_id, field_name, valid_starting_at) triple, which
-- is unique in this fixture (same convention as worker_positions.id).
select
    concat(
        f.ticket_id, ':', f.field_name, ':',
        cast(f.valid_starting_at as {{ dbt.type_string() }})
    )                                            as id,
    f.ticket_id,
    f.field_name,
    f.value,
    f.valid_starting_at,
    f.valid_ending_at
from {{ ref('stg_zendesk__ticket_field_history') }} f
