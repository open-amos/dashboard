select
    instrument_id,
    instrument_name,
    company_id,
    company_name,
    instrument_type,
    initial_investment_date,
    exit_date,
    cumulative_invested,
    current_fair_value,
    total_value,
    gross_moic,
    gross_irr,
    ownership_pct_current,
    holding_period_years
from metrics_position_performance
where fund_id = '${params.id}'
  and period_end_date = (
      select max(period_end_date)
      from metrics_position_performance
      where fund_id = '${params.id}'
  )
order by gross_moic desc
