# Dundersign — analytics dbt project

dbt models for Dundersign, a fictional e-signature SaaS. Raw connector tables
(Salesforce, Stripe, Zendesk, HubSpot, Workday, Greenhouse, NetSuite,
QuickBooks, and the product database) land in the `dundersign` Postgres
database, one schema per source; this project builds staging, core and
serving models on top (`analytics_serving.daily_metrics`,
`analytics_serving.monthly_metrics`).

Connection comes from the environment: `DUNDERSIGN_PG_HOST`,
`DUNDERSIGN_PG_USER`, `DUNDERSIGN_PG_PASSWORD` (see `profiles.yml`).

```bash
dbt deps
dbt build
```
