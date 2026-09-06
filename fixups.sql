-- Run as dundersign_dbt after load_postgres.py, before dbt build. Re-runnable.

-- The DuckDB export left its empty HubSpot stub tables typed as text; the
-- Fivetran package joins them to bigint ids. Zero rows, so retyping is free.
-- Skipped once applied: after a dbt build the staging views depend on these
-- columns and Postgres refuses to retype them.
DO $$
DECLARE r record;
BEGIN
  FOR r IN
    SELECT * FROM (VALUES ('company', 'id'), ('deal', 'owner_id'), ('users', 'role_id')) v(tbl, col)
    WHERE (SELECT data_type FROM information_schema.columns
           WHERE table_schema = 'hubspot' AND table_name = v.tbl AND column_name = v.col) <> 'bigint'
  LOOP
    EXECUTE format('ALTER TABLE hubspot.%I ALTER COLUMN %I TYPE bigint USING %I::bigint', r.tbl, r.col, r.col);
  END LOOP;
END $$;

-- The export has no zendesk ticket_tag or group tables, and the package has no
-- var to switch those two off (dbt_project.yml disables the rest). Without them
-- the package stubs each with integer ids, which cannot join the text ticket and
-- group ids here. Empty tables with text ids let the package fill the remaining
-- columns itself.
CREATE TABLE IF NOT EXISTS zendesk.ticket_tag (
  ticket_id text,
  tag text,
  _fivetran_synced timestamp
);
CREATE TABLE IF NOT EXISTS zendesk."group" (
  id text,
  name text,
  _fivetran_synced timestamp
);
