-- ============================================================
-- TRANSFORM (v3): staging -> star schema
-- ============================================================

-- ---------- dim_time: union of every year/quarter across all sources ----------
insert into analytics.dim_time (year, quarter)
select distinct year, quarter from staging.raw_labor_force_survey where year is not null
union
select distinct year, quarter from staging.raw_gdp_current_prices where year is not null
union
select distinct year, quarter from staging.raw_gdp_real where year is not null
union
select distinct year, nullif(quarter, '-') from staging.raw_real_estate_indices where year is not null
on conflict (year, quarter) do nothing;

-- ============================================================
-- LABOR FORCE
-- ============================================================

insert into analytics.dim_demographic (gender, nationality, age_group)
select distinct
    coalesce(nullif(trim(gender), ''), 'Total'),
    coalesce(nullif(trim(nationality), ''), 'Total'),
    coalesce(nullif(trim(age_group), ''), 'Total')
from staging.raw_labor_force_survey
on conflict (gender, nationality, age_group) do nothing;

insert into analytics.dim_indicator (indicator_name)
select distinct indicator
from staging.raw_labor_force_survey
where indicator is not null
on conflict (indicator_name) do nothing;

insert into analytics.fact_labor_force (indicator_id, time_id, region_id, demographic_id, value)
select
    ind.indicator_id,
    t.time_id,
    coalesce(r.region_id, r_total.region_id),
    d.demographic_id,
    s.value
from staging.raw_labor_force_survey s
join analytics.dim_indicator ind on ind.indicator_name = s.indicator
join analytics.dim_time t on t.year = s.year and t.quarter = s.quarter
join analytics.dim_demographic d
    on d.gender = coalesce(nullif(trim(s.gender), ''), 'Total')
    and d.nationality = coalesce(nullif(trim(s.nationality), ''), 'Total')
    and d.age_group = coalesce(nullif(trim(s.age_group), ''), 'Total')
left join analytics.dim_region r on r.region_name = nullif(trim(s.administrative_region), '')
left join analytics.dim_region r_total on r_total.region_name = 'Total';

-- ============================================================
-- GDP (current prices + real, merged via price_basis)
-- ============================================================

insert into analytics.dim_economic_activity (activity_name)
select distinct economic_activity from staging.raw_gdp_current_prices where economic_activity is not null
union
select distinct economic_activity from staging.raw_gdp_real where economic_activity is not null
on conflict (activity_name) do nothing;

insert into analytics.dim_gdp_unit (unit_name)
select distinct unit from staging.raw_gdp_current_prices where unit is not null
union
select distinct unit from staging.raw_gdp_real where unit is not null
on conflict (unit_name) do nothing;

insert into analytics.fact_gdp (time_id, economic_activity_id, unit_id, price_basis, value)
select
    t.time_id,
    ea.economic_activity_id,
    u.unit_id,
    'current',
    s.gdp_value
from staging.raw_gdp_current_prices s
join analytics.dim_time t on t.year = s.year and t.quarter = s.quarter
join analytics.dim_economic_activity ea on ea.activity_name = s.economic_activity
join analytics.dim_gdp_unit u on u.unit_name = s.unit;

insert into analytics.fact_gdp (time_id, economic_activity_id, unit_id, price_basis, value)
select
    t.time_id,
    ea.economic_activity_id,
    u.unit_id,
    'real',
    s.gdp_value
from staging.raw_gdp_real s
join analytics.dim_time t on t.year = s.year and t.quarter = s.quarter
join analytics.dim_economic_activity ea on ea.activity_name = s.economic_activity
join analytics.dim_gdp_unit u on u.unit_name = s.unit;

-- ============================================================
-- REAL ESTATE
-- ============================================================

insert into analytics.dim_real_estate_indicator (indicator_name)
select distinct indicator
from staging.raw_real_estate_indices
where indicator is not null
on conflict (indicator_name) do nothing;

insert into analytics.fact_real_estate (time_id, real_estate_indicator_id, periodicity, value)
select
    t.time_id,
    ri.real_estate_indicator_id,
    s.periodicity,
    s.value
from staging.raw_real_estate_indices s
join analytics.dim_time t on t.year = s.year and t.quarter = nullif(s.quarter, '-')
join analytics.dim_real_estate_indicator ri on ri.indicator_name = s.indicator;
