-- ============================================================
-- FIX: rename staging GDP columns to match source CSV headers
-- exactly (Supabase's CSV importer matches column names
-- literally, converted to lowercase/underscore — it does not
-- do fuzzy or semantic matching).
-- ============================================================

alter table staging.raw_gdp_current_prices rename column gdp_value to gdp;
alter table staging.raw_gdp_current_prices rename column activity_date to date;

alter table staging.raw_gdp_real rename column gdp_value to gdp;
alter table staging.raw_gdp_real rename column activity_date to date;
