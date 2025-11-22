select 
  country_code,
  region as country_name,
  instrument_type,
  sum(deployed_capital_usd) as exposure
from metrics_exposure_timeseries
where period_type = 'Current'
group by country_code, region, instrument_type
order by exposure desc
