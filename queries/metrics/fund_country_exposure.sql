-- Country exposure for a specific fund
select 
  country_name,
  sum(deployed_capital_usd) as exposure
from metrics_exposure_timeseries
where period_type = 'Current'
  and fund_id = '${params.id}'
group by country_name
order by exposure desc
