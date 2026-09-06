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

## Dashboards

`charts/` holds the dbt charts boards built on the analytics layer, read as
`dundersign_ro`:

- `company-overview.yml` — growth, product usage and revenue from
  `analytics_serving.monthly_metrics` / `daily_metrics`.
- `sales-pipeline.yml` — open pipeline, closed-won trend, win rate by source
  and the rep leaderboard, from `analytics.opportunities`.
- `support-health.yml` — backlog, resolution time and CSAT, from
  `analytics.tickets` / `ticket_events` / `satisfaction_ratings`.

The `dundersign` source in `dbt_charts.yml` takes its password from
`DUNDERSIGN_RO_PASSWORD`; nothing secret is committed. Locally it connects
over the Cloud SQL Auth Proxy socket, which is the default `host`:

```bash
export DUNDERSIGN_RO_PASSWORD="$(gcloud secrets versions access latest \
  --secret=dundersign-ro-db-password)"
dct serve
```
