-- Purpose: List all companies with key attributes for the overview table
-- Returns the latest record per company with fund and instrument counts

with latest_companies as (
    select distinct on (company_id)
        company_id,
        company_name,
        primary_country,
        primary_industry,
        period_end_date
    from metrics_company_performance
    order by company_id, period_end_date desc
),
company_metrics as (
    select
        company_id,
        count(distinct fund_id) as fund_count,
        count(distinct instrument_id) as instrument_count
    from metrics_position_performance
    where period_end_date = (
        select max(period_end_date)
        from metrics_position_performance
    )
    group by company_id
)
select
    lc.company_id,
    '/companies/' || lc.company_id as company_link,
    lc.company_name,
    lc.primary_country,
    lc.primary_industry,
    coalesce(cm.fund_count, 0) as funds,
    coalesce(cm.instrument_count, 0) as number_of_instruments
from latest_companies lc
left join company_metrics cm on lc.company_id = cm.company_id
order by lc.company_name
