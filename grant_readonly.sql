-- Run as dundersign_dbt after `dbt build`: lets the read-only warehouse role
-- read every analytics schema, including tables dbt creates later.
DO $$
DECLARE s text;
BEGIN
  FOR s IN SELECT nspname FROM pg_namespace WHERE nspname LIKE 'analytics%' LOOP
    EXECUTE format('GRANT USAGE ON SCHEMA %I TO dundersign_ro', s);
    EXECUTE format('GRANT SELECT ON ALL TABLES IN SCHEMA %I TO dundersign_ro', s);
    EXECUTE format('ALTER DEFAULT PRIVILEGES IN SCHEMA %I GRANT SELECT ON TABLES TO dundersign_ro', s);
  END LOOP;
END $$;
