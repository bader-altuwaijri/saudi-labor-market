# Saudi Labor Market & Economic Analytics Dashboard

Public BI portfolio project built on GASTAT data (sourced via the
KAPSARC Data Portal), modeled in Supabase (Postgres) and visualized
in Tableau Public.

## Data sources

| Dataset | Coverage | Source |
|---|---|---|
| Labor Force Survey Data | 2016–2025, quarterly | datasource.kapsarc.org |
| GDP by Kind of Economic Activity, Current Prices | 2010–2025, quarterly | datasource.kapsarc.org |
| Real GDP by Main Economic Activities (index) | 2010–2025, quarterly | datasource.kapsarc.org |
| Real Estate Price Index by Sector & Type | 2014–2024, quarterly + annual | datasource.kapsarc.org |

All originally published by GASTAT (General Authority for Statistics,
Saudi Arabia); KAPSARC republishes them in clean English CSV/API form.

**Analytical window**: dashboards standardize on **2017–2024**, the
overlapping range across all four sources, for consistency even
though some tables have wider raw coverage.

**Excluded**: "Main Labor Market Indicators" (also KAPSARC/GASTAT)
was evaluated but dropped — its data stops at 2020 (stale relative
to the other four) and its indicators substantially overlap with the
richer Labor Force Survey Data file.

## Architecture

```
KAPSARC CSV downloads
        │
        ▼
Supabase Postgres  ──►  staging.raw_* tables (exact source columns)
        │
        ▼
   Transformation SQL (CTEs / joins) ──► star schema (analytics.dim_* / fact_*)
        │
        ▼
   Export final tables as CSV
        │
        ▼
   Tableau Public (published dashboard)
```

Tableau Public cannot hold a live connection to Postgres, so Supabase
is the source of truth and modeling layer, and Tableau Public
consumes a CSV export of the final star schema.

## Schema design notes

- **Domain-specific fact tables**: Labor Force, GDP, and Real Estate
  each have genuinely different dimension shapes (e.g. Real Estate
  has no region breakdown at all), so each gets its own fact table
  rather than forcing everything into one generic table. All three
  share `dim_time` so cross-domain analysis is still a simple join.
- **GDP current vs. real merged**: both GDP source files have an
  identical column shape, so they're merged into one `fact_gdp` table
  distinguished by a `price_basis` ('current' / 'real') column,
  rather than kept as two separate fact tables.
- **EAV source pattern**: Labor Force Survey Data and both GDP files
  are "long format" — a category column (`Indicator`, `Unit`, or
  `Economic Activity`) determines what the numeric value in that row
  actually represents, rather than each metric having its own column.
  The transform layer resolves these into proper dimension tables.
- **v1 scope**: the Labor Force Survey source has ~20 dimension
  columns (job search method, occupation, educational specialization,
  etc.), most only populated for specific indicators. This version
  models the core dimensions (gender, nationality, age group, region,
  time, indicator) and leaves the rest in staging, untouched —
  straightforward to extend as a v2 migration later.

## Setup steps

1. Create a free Supabase project (done — see project "Saudi Labor Market").
2. Push `supabase/migrations/` to GitHub — auto-deploys via the
   Supabase GitHub integration.
3. Import each source CSV into its matching `staging.raw_*` table via
   Supabase's Table Editor. **Delimiter is semicolon (;), not comma**
   for all five files.
4. Run the transform migration (already included, runs automatically
   after staging + star schema migrations via GitHub integration).
5. Export each `analytics.dim_*` / `fact_*` table as CSV.
6. Load those CSVs into Tableau Public and build the dashboard.

## Refresh cadence

GASTAT/KAPSARC update these on a rolling basis (quarterly for most).
Re-running steps 3–5 periodically keeps the dashboard current;
exact frequency is a manual decision since Tableau Public can't poll
Supabase directly.
