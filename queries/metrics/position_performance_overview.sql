select
    instrument_id, instrument_name, period_end_date, fund_id, fund_name,
    company_id, company_name, instrument_type,
    initial_investment_date, exit_date, 
    cost_basis,
    realized_proceeds, 
    fair_value as current_fair_value,
    (coalesce(realized_proceeds, 0) + coalesce(fair_value, 0)) as total_value,
    moic as gross_moic, 
    equity_irr as gross_irr,
    ownership_pct_initial, ownership_pct_current, holding_period_years
from metrics_position_performance
where ('${inputs.fund_id.value}' = 'ALL' or fund_id = '${inputs.fund_id.value}')
  and ('${inputs.instrument_type.value}' = 'ALL' or instrument_type = '${inputs.instrument_type.value}')
order by gross_moic desc
