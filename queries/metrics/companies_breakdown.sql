-- Purpose: Aggregate company counts by country and industry for pie charts
-- Returns combined breakdown data with dimension type indicator

with latest_companies as (
    select distinct on (company_id)
        company_id,
        company_name,
        primary_country,
        primary_industry
    from metrics_company_performance
    order by company_id, period_end_date desc
)
select
    primary_country as dimension,
    'country' as dimension_type,
    count(*) as company_count
from latest_companies
where primary_country is not null
group by primary_country

union all

select
    primary_industry as dimension,
    'industry' as dimension_type,
    count(*) as company_count
from latest_companies
where primary_industry is not null
group by primary_industry
