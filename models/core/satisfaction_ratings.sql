-- CSAT ratings. Hand-rolled staging (no Fivetran package model for this
-- table -- see stg_zendesk__satisfaction_rating.sql).
--
-- person_id resolves the same way as ticket_comments.person_id: requester_id
-- is a "zd_"-prefixed product_db user id, not a zendesk.user FK -- strip the
-- prefix and match persons.product_user_id. assignee_id, group_id, and
-- reason are 100% blank in this fixture (the generator never populates
-- them) and are dropped rather than carried through as dead columns.
select
    s.id,
    s.ticket_id,
    p.id                                         as person_id,
    s.created_at,
    s.score,
    nullif(s.comment, '')                        as comment,
    s._fivetran_synced
from {{ ref('stg_zendesk__satisfaction_rating') }} s
left join {{ ref('persons') }} p
    on p.product_user_id = substr(nullif(s.requester_id, ''), 4)
