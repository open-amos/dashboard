-- Sector exposure for a specific fund
select 
  industry_name,
  sum(deployed_capital_usd) as exposure
from metrics_exposure_timeseries
where period_type = 'Current'
  and fund_id = '${params.id}'
group by industry_name
order by exposure desc
