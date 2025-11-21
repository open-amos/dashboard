-- Credit Portfolio Metrics
-- Aggregates fund-level performance metrics across all credit funds
-- Filters to fund_type='CREDIT' to show only credit fund metrics

select
    sum(total_exposure) as total_exposure,
    sum(principal_outstanding) as total_principal_outstanding,
    sum(undrawn_commitment) as total_undrawn_commitment,
    sum(total_commitments) as total_commitments,
    sum(total_called_capital) as total_called_capital,
    sum(unfunded_commitment) as unfunded_commitment,
    sum(total_distributions) as total_distributions,
    sum(interest_income) as total_interest_income,
    -- Portfolio statistics
    count(distinct fund_id) as number_of_credit_funds,
    sum(number_of_portfolio_companies) as total_portfolio_companies,
    sum(number_of_positions) as total_positions
from metrics_fund_performance
where fund_type = 'CREDIT'
    and period_end_date = (
        select max(period_end_date) 
        from metrics_fund_performance
    )
