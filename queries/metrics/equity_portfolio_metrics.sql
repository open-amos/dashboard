-- Equity Portfolio Metrics
-- Aggregates fund-level performance metrics across all equity funds
-- Filters to fund_type='EQUITY' to show only PE fund metrics

select
    sum(fund_nav) as total_nav,
    sum(total_commitments) as total_commitments,
    sum(total_called_capital) as total_called_capital,
    sum(unfunded_commitment) as unfunded_commitment,
    sum(total_distributions) as total_distributions,
    -- Portfolio-level PE metrics
    sum(total_distributions) / nullif(sum(total_called_capital), 0) as dpi_portfolio,
    sum(fund_nav) / nullif(sum(total_called_capital), 0) as rvpi_portfolio,
    (sum(fund_nav) + sum(total_distributions)) / nullif(sum(total_called_capital), 0) as tvpi_portfolio,
    -- Portfolio statistics
    count(distinct fund_id) as number_of_equity_funds,
    sum(number_of_portfolio_companies) as total_portfolio_companies,
    sum(number_of_positions) as total_positions
from metrics_fund_performance
where fund_type = 'EQUITY'
    and period_end_date = (
        select max(period_end_date) 
        from metrics_fund_performance
    )
