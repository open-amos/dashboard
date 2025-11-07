with filtered as (
  select
    date_trunc('month', cast(exposure_month as timestamp)) as month,
    industry_name,
    deployed_capital_usd,
    period_type,
    fund_id,
    stage_id
  from metrics_exposure_by_industry
  where 1=1
    and cast(fund_id as varchar) = '${inputs.fund.value}'
    and cast(stage_id as varchar) = '${inputs.stage.value}'
), first_current_month as (
  select min(month) as min_month from filtered where period_type = 'Current'
)
select
  industry_name,
  sum(coalesce(deployed_capital_usd, 0)) as total_exposure_usd
from filtered
where period_type = 'Current'
  and month = (select min_month from first_current_month)
group by 1
order by total_exposure_usd desc


