#!/usr/bin/env python3
"""Load the raw connector schemas from the dundersign DuckDB export into Postgres.

    DUNDERSIGN_PG_DSN='host=... dbname=dundersign user=... password=...' \
      uv run --project ~/Fivetran/dataface python load_postgres.py [path/to/dundersign.duckdb]

Copies every table in the nine raw schemas as-is (schema.table -> schema.table)
so the dbt sources in models/_sources.yml resolve unchanged. Run once; re-run
replaces the tables.
"""

import os
import sys

import duckdb

RAW_SCHEMAS = (
    "greenhouse", "hubspot", "netsuite", "product_db", "quickbooks",
    "salesforce", "stripe", "workday", "zendesk",
)

duck = sys.argv[1] if len(sys.argv) > 1 else os.path.expanduser(
    "~/Fivetran/tmp/dundersign-9-5-26/dundersign.duckdb"
)
con = duckdb.connect()
con.execute("INSTALL postgres; LOAD postgres;")
con.execute(f"ATTACH '{duck}' AS src (READ_ONLY)")
con.execute(f"ATTACH '{os.environ['DUNDERSIGN_PG_DSN']}' AS pg (TYPE postgres)")
for schema in RAW_SCHEMAS:
    con.execute(f"CREATE SCHEMA IF NOT EXISTS pg.{schema}")
    tables = con.execute(
        "SELECT table_name FROM information_schema.tables "
        "WHERE table_catalog = 'src' AND table_schema = ?",
        [schema],
    ).fetchall()
    for (table,) in tables:
        con.execute(f'CREATE OR REPLACE TABLE pg.{schema}."{table}" AS SELECT * FROM src.{schema}."{table}"')
    print(f"{schema}: {len(tables)} tables")
