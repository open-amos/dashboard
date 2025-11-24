with latest as (
  select max(period_end_date) as max_date 
  from metrics_position_performance
)
select 
  mp.company_id,
  '/companies/' || mp.company_id as company_link,
  mp.company_name,
  mp.fund_name,
  mp.instrument_name,
  mp.instrument_type,
  mp.fair_value as current_fair_value,
  mp.cost_basis,
  (mp.fair_value + coalesce(mp.realized_proceeds, 0) - mp.cost_basis) as total_return,
  mp.moic,
  mp.equity_irr_approx as irr_approx
from metrics_position_performance mp
join latest on mp.period_end_date = latest.max_date
where mp.instrument_type = 'EQUITY' and mp.cost_basis > 0
order by total_return asc nulls last
limit 20
