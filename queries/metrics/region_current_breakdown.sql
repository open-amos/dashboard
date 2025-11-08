with first_current_month as (
  select min(month) as min_month
  from ${exposure_ts}
  where period_type = 'Current'
)
select
  region,
  sum(coalesce(deployed_capital_usd, 0)) as total_exposure_usd
from metrics_exposure_by_region
where 1=1
  and date_trunc('month', cast(exposure_month as timestamp)) = (select min_month from first_current_month)
  and cast(fund_id as varchar) = '${inputs.fund.value}'
  and cast(stage_id as varchar) = '${inputs.stage.value}'
group by 1
order by total_exposure_usd desc


