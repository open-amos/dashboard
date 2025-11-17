select
    f.fund_id,
    '/funds/' || f.fund_id as fund_link,
    f.fund_name,
    f.fund_nav,
    f.total_commitments,
    f.unfunded_commitment,
    f.total_distributions,
    f.dpi,
    f.rvpi,
    f.tvpi,
    coalesce(count(distinct p.company_id), 0) as number_of_portfolio_companies,
    f.period_end_date
from metrics_fund_performance f
left join metrics_position_performance p
    on f.fund_id = p.fund_id
    and f.period_end_date = p.period_end_date
where f.period_end_date = (
    select max(period_end_date)
    from metrics_fund_performance
    where fund_id = f.fund_id
)
group by
    f.fund_id, f.fund_name, f.period_end_date, f.fund_nav,
    f.total_commitments, f.unfunded_commitment,
    f.total_distributions, f.dpi, f.rvpi, f.tvpi
order by f.fund_name
