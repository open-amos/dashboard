-- Shows exposure by country for selected month with optional filters
with selected_month as (
  select date_trunc('month', cast(date '1899-12-30' + (${inputs.month} * interval 1 day) as date)) as month
)
select
  country_code,
  country_name,
  sum(total_exposure_usd) as exposure
from metrics_exposure_timeseries
where date_trunc('month', cast(exposure_month as date)) = (select month from selected_month)
  and (fund_id = '${inputs.fund.value}' or '${inputs.fund.value}' = 'ALL')
  and (stage_id = '${inputs.stage.value}' or '${inputs.stage.value}' = 'ALL' or stage_id is null)
  and total_exposure_usd > 0
group by country_code, country_name
order by exposure desc


