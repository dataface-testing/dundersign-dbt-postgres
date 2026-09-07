# Dundersign — analytics dbt project

dbt models for Dundersign, a fictional e-signature SaaS. Raw connector tables
(Salesforce, Stripe, Zendesk, HubSpot, Workday, Greenhouse, NetSuite,
QuickBooks, and the product database) land in the `dundersign` Postgres
database, one schema per source; this project builds staging, core and
serving models on top (`analytics_serving.daily_metrics`,
`analytics_serving.monthly_metrics`).

Connection comes from the environment: `DUNDERSIGN_PG_HOST`,
`DUNDERSIGN_PG_USER`, `DUNDERSIGN_PG_PASSWORD`, and optionally
`DUNDERSIGN_PG_PORT` and `DUNDERSIGN_PG_SSLMODE` (see `profiles.yml`).

```bash
dbt deps
dbt build
```

## Roles

- `dundersign_dbt` owns the raw and analytics schemas and runs dbt.
- `dundersign_ro` is read-only over `analytics*`, for BI tools and dashboards.
  Its grants are managed with the database itself (terraform), including
  default privileges, so a rebuild needs no grant step.

## Loading the raw schemas

One-time, from the DuckDB export: `load_postgres.py` copies the nine raw
schemas across unchanged so the sources in `models/` resolve as-is, then
`fixups.sql` (run as `dundersign_dbt`) corrects the column types the export
got wrong.

## Dashboards (dbt charts Cloud)

Boards live in `charts/`; `dbt_charts.yml` anchors the project and registers
the `analytics` source, which resolves through `profiles.yml` locally.

This repo publishes to organization **`r2-04`**, project
**`dundersign-dbt-postgres`** on https://dbtcharts.com — nothing in the git
remote implies that org slug, so recover it from here rather than guessing
(`dct cloud orgs`, then `dct cloud projects`, matching the `REPOSITORY`
column). `published_to:` in `dbt_charts.yml` is what the CLI reads.

To ship a board change: commit, `git push`, then `dct cloud project sync` — a
push alone does not publish. Confirm with `dct cloud boards`: the changed
board's `RENDERED_AT` and `COMMIT` both move once its re-render lands.

**The Cloud warehouse connection is not yet created.** `dundersign` runs on
Cloud SQL `internal-dataface-eng:us-west1:dataface-cloud-db` (34.53.51.213),
whose `authorizedNetworks` list two entries only. dbt charts Cloud is not one
of them, so `dct cloud connection create` fails its own credential test with
`timeout expired` and saves nothing. Until that instance authorizes Cloud's
egress address, the `analytics` source stays unmapped and boards that query
the warehouse cannot render.
