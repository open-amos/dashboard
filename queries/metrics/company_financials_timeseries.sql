select
    period_end_date,
    revenue,
    ebitda,
    ebitda_margin,
    reporting_currency
from metrics_company_performance
where company_id = '${params.id}'
order by period_end_date asc
