-- ============================================================
-- STAGING LAYER (v3 — final, based on actual downloaded CSVs)
-- Source: KAPSARC Data Portal (datasource.kapsarc.org), GASTAT data
--
-- IMPORTANT — BOM warning: these CSVs start with a UTF-8 byte-order
-- mark (invisible character before "Year" in row 1). Most CSV
-- importers (including Supabase's) strip this automatically, but if
-- your first column ever imports as something odd like "ï»¿Year"
-- instead of "Year", that's the BOM — re-export or clean the file
-- with a text editor before re-importing.
--
-- Delimiter in all five source files is semicolon (;), not comma.
-- ============================================================

create schema if not exists staging;

-- ---------- Labor Force Survey Data ----------
-- Long/EAV format: one row per indicator measurement.
create table if not exists staging.raw_labor_force_survey (
    year integer,
    quarter text,
    indicator text,
    gender text,
    nationality text,
    age_group text,
    administrative_region text,
    educational_level text,
    job_search_method text,
    job_search_duration text,
    unemployment_duration text,
    previous_work_experience text,
    prefer_private_sector text,
    accepted_commuting_time text,
    accepted_working_hours text,
    reason_leaving_previous_work text,
    occupation text,
    economic_activity text,
    sector text,
    labor_force_attachment_degree text,
    relationship_to_labor_market text,
    educational_specialization text,
    value numeric,
    time_period text,
    main_economic_activity text,
    loaded_at timestamp default now()
);

-- ---------- GDP at Current Prices ----------
-- Same column shape as Real GDP below. "Unit" determines what
-- "gdp_value" represents (SAR millions vs growth rate %, etc.)
create table if not exists staging.raw_gdp_current_prices (
    year integer,
    quarter text,
    unit text,
    economic_activity text,
    gdp_value numeric,
    activity_date text,     -- source 'Date' column, format YYYY-MM; kept as text, parse in transform if needed
    loaded_at timestamp default now()
);

-- ---------- Real GDP (index-based, main economic activities) ----------
-- Identical shape to current-prices file above. Kept as a separate
-- staging table (rather than merged) so raw source data stays
-- traceable to its origin file; merged together in the fact table
-- via a price_basis flag during transform.
create table if not exists staging.raw_gdp_real (
    year integer,
    quarter text,
    unit text,
    economic_activity text,
    gdp_value numeric,
    activity_date text,
    loaded_at timestamp default now()
);

-- ---------- Real Estate Price Index ----------
-- No region breakdown in this file. "Indicator" encodes both
-- sector and property type together, e.g. 'Commercial: Building'.
-- "Quarter" is '-' for annual rows — normalized to null in transform.
create table if not exists staging.raw_real_estate_indices (
    periodicity text,       -- 'Annually' or 'Quarterly'
    year integer,
    quarter text,           -- 'Q1'-'Q4', or '-' for annual rows
    indicator text,
    value numeric,
    loaded_at timestamp default now()
);

-- ---------- (Dropped) Main Labor Market Indicators ----------
-- Excluded from this project: only covers 2017-2020, stale relative
-- to the other four datasets (2010/2014/2016 through 2024/2025),
-- and its indicators substantially overlap with the richer Labor
-- Force Survey Data file above.
