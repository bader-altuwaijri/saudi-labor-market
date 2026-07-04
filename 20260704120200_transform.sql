-- ============================================================
-- STAR SCHEMA
-- Dimension and fact tables that the Tableau dashboard will
-- ultimately be built on. Grain is documented on each fact table.
-- ============================================================

create schema if not exists analytics;

-- ---------- DIMENSIONS ----------

create table if not exists analytics.dim_region (
    region_id serial primary key,
    region_name text unique not null
);

insert into analytics.dim_region (region_name) values
    ('Riyadh'), ('Makkah'), ('Madinah'), ('Qassim'), ('Eastern Region'),
    ('Asir'), ('Tabuk'), ('Hail'), ('Northern Borders'), ('Jazan'),
    ('Najran'), ('Al-Baha'), ('Al-Jouf')
on conflict (region_name) do nothing;

create table if not exists analytics.dim_time (
    time_id serial primary key,
    year integer not null,
    quarter integer,       -- null for monthly-only records like CPI
    month integer,          -- null for quarterly-only records
    unique (year, quarter, month)
);

create table if not exists analytics.dim_demographic (
    demographic_id serial primary key,
    gender text,             -- 'Male' / 'Female' / 'Total'
    nationality text,        -- 'Saudi' / 'Non-Saudi' / 'Total'
    age_group text,          -- e.g. '15-24', '25-54', '55+', or null
    unique (gender, nationality, age_group)
);

-- ---------- FACTS ----------

-- Grain: one row per region x time x demographic combination
create table if not exists analytics.fact_labor_force (
    fact_id bigserial primary key,
    region_id integer references analytics.dim_region(region_id),
    time_id integer references analytics.dim_time(time_id),
    demographic_id integer references analytics.dim_demographic(demographic_id),
    participation_rate numeric,
    unemployment_rate numeric,
    employed_count numeric
);

-- Grain: one row per economic activity x time
create table if not exists analytics.fact_national_accounts (
    fact_id bigserial primary key,
    time_id integer references analytics.dim_time(time_id),
    economic_activity text,
    gdp_current_prices numeric,
    gdp_growth_rate numeric,
    price_basis text
);

-- Grain: one row per region (nullable, CPI has no region) x category x time
create table if not exists analytics.fact_price_index (
    fact_id bigserial primary key,
    region_id integer references analytics.dim_region(region_id),
    time_id integer references analytics.dim_time(time_id),
    index_type text,          -- 'CPI' or 'Real Estate'
    category text,
    index_value numeric,
    change_pct numeric
);

-- Grain: one row per region x time x demographic
create table if not exists analytics.fact_population (
    fact_id bigserial primary key,
    region_id integer references analytics.dim_region(region_id),
    time_id integer references analytics.dim_time(time_id),
    demographic_id integer references analytics.dim_demographic(demographic_id),
    population_count bigint
);
