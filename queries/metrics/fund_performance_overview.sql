select
    f.fund_id,
    '/funds/' || f.fund_id as fund_link,
    f.fund_name,
    f.period_end_date,
    f.fund_nav,
    f.total_commitments,
    f.total_called_capital,
    f.unfunded_commitment,
    f.total_distributions,
    f.dpi,
    f.rvpi,
    f.tvpi,
    f.expected_coc,
    coalesce(count(distinct p.company_id), 0) as number_of_portfolio_companies,
    f.number_of_positions,
    f.lines_of_credit_outstanding,
    f.peak_outstanding_credit,
    f.interest_income,
    f.as_of_date
from metrics_fund_performance f
left join metrics_position_performance p
    on f.fund_id = p.fund_id
    and f.period_end_date = p.period_end_date
group by
    f.fund_id, f.fund_name, f.period_end_date, f.fund_nav,
    f.total_commitments, f.total_called_capital, f.unfunded_commitment,
    f.total_distributions, f.dpi, f.rvpi, f.tvpi, f.expected_coc,
    f.number_of_positions, f.lines_of_credit_outstanding,
    f.peak_outstanding_credit, f.interest_income, f.as_of_date
order by f.period_end_date desc
