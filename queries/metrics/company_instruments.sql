select
    instrument_id,
    instrument_name,
    instrument_type,
    fund_name,
    initial_investment_date,
    exit_date,
    initial_cost,
    cumulative_invested,
    realized_proceeds,
    current_fair_value,
    total_value,
    gross_moic,
    gross_irr,
    ownership_pct_current,
    holding_period_years
from metrics_position_performance
where company_id = '${params.id}'
order by initial_investment_date desc
