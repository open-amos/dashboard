-- Equity Portfolio Time Series
-- Shows NAV and other metrics over time for equity funds only
-- Filters to fund_type='EQUITY' to show only PE fund trends

select
    period_end_date,
    sum(fund_nav) as total_nav,
    sum(total_called_capital) as total_called_capital,
    sum(total_distributions) as total_distributions,
    sum(unfunded_commitment) as unfunded_commitment,
    sum(period_net_flows) as net_cash_contributions_period,
    -- Portfolio-level PE metrics over time
    sum(total_distributions) / nullif(sum(total_called_capital), 0) as dpi_portfolio,
    sum(fund_nav) / nullif(sum(total_called_capital), 0) as rvpi_portfolio,
    (sum(fund_nav) + sum(total_distributions)) / nullif(sum(total_called_capital), 0) as tvpi_portfolio
from metrics_fund_performance
where fund_type = 'EQUITY'
group by period_end_date
order by period_end_date
