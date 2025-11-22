select 
  industry_name,
  instrument_type,
  sum(deployed_capital_usd) as exposure_usd
from metrics_exposure_timeseries
where period_type = 'Current'
group by industry_name, instrument_type
order by exposure_usd desc
