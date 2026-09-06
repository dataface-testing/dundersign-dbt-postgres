-- Ticket comment thread. Built on Fivetran zendesk_source staging.
--
-- person_id resolves the requester side of the conversation: zendesk.user in
-- this fixture holds only support agents, never the end-user who wrote
-- the ticket -- the generator sets ticket_comment.user_id to a "zd_"-prefixed
-- product_db user id directly, with no matching zendesk.user row. Strip the
-- prefix and match against persons.product_user_id (== users.id for anyone
-- who signed up) instead of joining zendesk.user.
--
-- No employee-side FK: ticket.assignee_id (the field agent-authored comments
-- fall back to when user_id is blank) is never populated by the generator,
-- so a meaningful share of comments have no resolvable author on either
-- side. That's a fixture gap, not something this model can join around.
select
    c.ticket_comment_id                         as id,
    c.ticket_id,
    p.id                                         as person_id,
    c.body,
    c.created_at,
    c.is_public,
    c.is_facebook_comment,
    c.is_tweet,
    c.is_voice_comment,
    c._fivetran_synced
from {{ ref('stg_zendesk__ticket_comment') }} c
left join {{ ref('persons') }} p
    on p.product_user_id = substr(nullif(c.user_id, ''), 4)
