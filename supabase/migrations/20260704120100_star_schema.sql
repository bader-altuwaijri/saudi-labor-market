-- ============================================================
-- STAR SCHEMA (v3 — final, covers 4 datasets)
-- Domain-specific fact tables, since Labor Force, GDP, and Real
-- Estate each have genuinely different dimension shapes. They
-- share dim_time so cross-domain analysis (e.g. unemployment vs.
-- GDP growth over the same quarters) is still a simple join.
-- ============================================================

create schema if not exists analytics;

-- ---------- SHARED DIMENSIONS ----------

create table if not exists analytics.dim_time (
    time_id serial primary key,
    year integer not null,
    quarter text,           -- 'Q1'-'Q4', or null for annual-only records
    unique (year, quarter)
);

create table if not exists analytics.dim_region (
    region_id serial primary key,
    region_name text unique not null
);

insert into analytics.dim_region (region_name) values
    ('Riyadh'), ('Makkah'), ('Madinah'), ('Qassim'), ('Eastern Region'),
    ('Asir'), ('Tabuk'), ('Hail'), ('Northern Borders'), ('Jazan'),
    ('Najran'), ('Al-Baha'), ('Al-Jouf'), ('Total')
on conflict (region_name) do nothing;

-- ---------- LABOR FORCE ----------

create table if not exists analytics.dim_demographic (
    demographic_id serial primary key,
    gender text,
    nationality text,
    age_group text,
    unique (gender, nationality, age_group)
);

create table if not exists analytics.dim_indicator (
    indicator_id serial primary key,
    indicator_name text unique not null
);

-- Grain: one row per indicator x time x region x demographic
create table if not exists analytics.fact_labor_force (
    fact_id bigserial primary key,
    indicator_id integer references analytics.dim_indicator(indicator_id),
    time_id integer references analytics.dim_time(time_id),
    region_id integer references analytics.dim_region(region_id),
    demographic_id integer references analytics.dim_demographic(demographic_id),
    value numeric
);

-- ---------- GDP ----------

create table if not exists analytics.dim_economic_activity (
    economic_activity_id serial primary key,
    activity_name text unique not null
);

create table if not exists analytics.dim_gdp_unit (
    unit_id serial primary key,
    unit_name text unique not null   -- e.g. 'Million of Saudi Riyals', 'Growth Rates Y-o-Y', 'Index'
);

-- Grain: one row per economic activity x unit x time x price basis
create table if not exists analytics.fact_gdp (
    fact_id bigserial primary key,
    time_id integer references analytics.dim_time(time_id),
    economic_activity_id integer references analytics.dim_economic_activity(economic_activity_id),
    unit_id integer references analytics.dim_gdp_unit(unit_id),
    price_basis text not null,      -- 'current' or 'real'
    value numeric
);

-- ---------- REAL ESTATE ----------

create table if not exists analytics.dim_real_estate_indicator (
    real_estate_indicator_id serial primary key,
    indicator_name text unique not null   -- e.g. 'Commercial: Building', 'Agricultural: Land'
);

-- Grain: one row per indicator x time (region not available in this source)
create table if not exists analytics.fact_real_estate (
    fact_id bigserial primary key,
    time_id integer references analytics.dim_time(time_id),
    real_estate_indicator_id integer references analytics.dim_real_estate_indicator(real_estate_indicator_id),
    periodicity text not null,   -- 'Annually' or 'Quarterly'
    value numeric
);
