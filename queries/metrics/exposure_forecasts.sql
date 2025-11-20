-- Simplified query using metrics_exposure_timeseries
-- Current exposure remains constant, Forecast shows cumulative pipeline
with filtered as (
  select
    date_trunc('month', cast(exposure_month as timestamp)) as month,
    deployed_capital_usd,
    closed_pipeline_usd,
    period_type
  from metrics_exposure_timeseries
  where 1=1
    and (fund_id = '${inputs.fund.value}' or '${inputs.fund.value}' = 'ALL' or '${inputs.fund.value}' is null)
    and (stage_id = '${inputs.stage.value}' or '${inputs.stage.value}' = 'ALL' or stage_id is null or '${inputs.stage.value}' is null)
    and (region = '${inputs.region.value}' or '${inputs.region.value}' = 'ALL' or '${inputs.region.value}' is null)
    and (country_code = '${inputs.country.value}' or '${inputs.country.value}' = 'ALL' or '${inputs.country.value}' is null)
    and (industry_id = '${inputs.industry.value}' or '${inputs.industry.value}' = 'ALL' or '${inputs.industry.value}' is null)
),
current_baseline as (
  select sum(deployed_capital_usd) as baseline_exposure
  from filtered
  where period_type = 'Current'
),
all_months as (
  select distinct month from filtered
),
current_series as (
  select 
    m.month,
    'Current' as period_type,
    cb.baseline_exposure as total_exposure_usd
  from all_months m
  cross join current_baseline cb
),
forecast_series as (
  select
    month,
    'Forecast' as period_type,
    sum(closed_pipeline_usd) as total_exposure_usd
  from filtered
  where period_type = 'Forecast'
  group by month
)
select * from current_series
union all
select * from forecast_series
order by month asc, period_type


