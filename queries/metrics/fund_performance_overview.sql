select
    fund_id,
    '/funds/' || fund_id as fund_link,
    fund_name,
    fund_type,
    period_end_date,
    fund_nav,
    total_commitments,
    total_called_capital,
    unfunded_commitment,
    total_distributions,
    dpi,
    rvpi,
    tvpi,
    expected_coc,
    number_of_portfolio_companies,
    number_of_positions,
    lines_of_credit_outstanding,
    peak_outstanding_credit,
    -- Credit-specific metrics
    total_exposure,
    principal_outstanding,
    undrawn_commitment,
    interest_income,
    as_of_date
from metrics_fund_performance
order by period_end_date desc
