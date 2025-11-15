select
    company_id,
    company_name,
    website,
    description,
    primary_country,
    primary_industry
from metrics_company_performance
where company_id = '${params.id}'
limit 1
