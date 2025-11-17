-- Purpose: Detailed financial metrics table for single company page
-- Parameters: ${params.id} - company_id from URL
-- Returns all historical financial data for the specified company

select
    period_end_date,
    revenue,
    ebitda,
    ebitda_margin,
    cash,
    total_assets,
    total_liabilities,
    equity,
    net_debt,
    enterprise_value,
    ev_to_ebitda,
    ev_to_revenue,
    reporting_currency
from metrics_company_performance
where company_id = '${params.id}'
order by period_end_date desc
