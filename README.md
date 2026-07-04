-- ============================================================
-- STAGING LAYER
-- Raw tables that mirror the source CSVs as closely as possible.
-- IMPORTANT: When you import each CSV via Supabase's Table Editor,
-- it will auto-create columns based on the file's actual headers.
-- These CREATE TABLE statements are a best-guess starting point —
-- replace/adjust once you see the real column names from the
-- downloaded files. Keeping raw data untouched here (no renaming,
-- no type coercion) protects the transform step below from breaking
-- if a future export has slightly different formatting.
-- ============================================================

create schema if not exists staging;

-- Labour Force Participation Rate by gender, nationality, and region
create table if not exists staging.raw_labor_force_participation (
    region text,
    year integer,
    quarter integer,
    gender text,
    nationality text,
    participation_rate numeric,
    loaded_at timestamp default now()
);

-- Unemployment rate
create table if not exists staging.raw_unemployment_rate (
    region text,
    year integer,
    quarter integer,
    gender text,
    nationality text,
    age_group text,
    unemployment_rate numeric,
    loaded_at timestamp default now()
);

-- Main Labor Market Indicators (employed persons, job seekers)
create table if not exists staging.raw_labor_market_indicators (
    year integer,
    quarter integer,
    indicator_name text,
    nationality text,
    value numeric,
    unit text,
    loaded_at timestamp default now()
);

-- GDP and National Accounts
create table if not exists staging.raw_gdp_national_accounts (
    year integer,
    quarter integer,
    economic_activity text,
    gdp_current_prices numeric,
    gdp_growth_rate numeric,
    price_basis text,          -- e.g. 'real' vs 'nominal'
    loaded_at timestamp default now()
);

-- Consumer Price Index
create table if not exists staging.raw_cpi (
    year integer,
    month integer,
    category text,
    cpi_value numeric,
    annual_inflation_rate numeric,
    loaded_at timestamp default now()
);

-- Real Estate Price Index
create table if not exists staging.raw_real_estate_price_index (
    region text,
    year integer,
    quarter integer,
    property_type text,
    price_index_value numeric,
    yoy_change_pct numeric,
    loaded_at timestamp default now()
);

-- 2022 Census-based population estimates
create table if not exists staging.raw_population_census (
    region text,
    year integer,
    gender text,
    nationality text,
    age_group text,
    population_count bigint,
    loaded_at timestamp default now()
);
