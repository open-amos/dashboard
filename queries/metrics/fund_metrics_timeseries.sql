select
    period_end_date,
    fund_nav,
    tvpi,
    dpi,
    rvpi,
    total_distributions,
    total_called_capital
from metrics_fund_performance
where fund_id = '${params.id}'
order by period_end_date asc
