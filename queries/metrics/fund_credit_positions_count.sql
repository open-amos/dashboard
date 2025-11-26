-- Count of credit positions for a credit fund
with latest_snapshots as (
  select instrument_id, max(period_end_date) as latest_period
  from metrics_position_performance
  where fund_id = '${params.id}'
  group by instrument_id
)
select count(*) as position_count
from metrics_position_performance mpp
inner join latest_snapshots ls 
  on mpp.instrument_id = ls.instrument_id 
  and mpp.period_end_date = ls.latest_period
where mpp.fund_id = '${params.id}'
  and mpp.instrument_type = 'CREDIT'
