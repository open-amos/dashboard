-- Aggregate fund performance metrics across all funds
-- Returns a single row with totals for the latest common period
-- Uses the same logic as metrics_portfolio_overview for consistency

select
    sum(total_commitments) as total_commitments,
    sum(unfunded_commitment) as unfunded_commitment,
    sum(total_distributions) as total_distributions
from metrics_fund_performance
where period_end_date = (
    select max(period_end_date)
    from metrics_fund_performance
)
