-- Data quality check: Fund-level variance between reported and calculated metrics
-- Identifies discrepancies that may indicate data quality issues

select
    fund_name,
    fund_type,
    period_end_date,
    -- NAV
    fund_nav_reported,
    fund_nav_calculated,
    nav_variance,
    nav_variance_pct,
    -- Called Capital
    called_capital_reported,
    called_capital_calculated,
    called_capital_variance,
    called_capital_variance_pct,
    -- Distributions
    total_distributions_reported,
    total_distributions_calculated,
    distributions_variance,
    distributions_variance_pct,
    -- Flag significant variances
    case
        when abs(nav_variance_pct) > 0.02 then 'NAV Variance > 2%'
        when abs(called_capital_variance_pct) > 0.001 then 'Called Capital Variance > 0.1%'
        when abs(distributions_variance_pct) > 0.001 then 'Distributions Variance > 0.1%'
        else 'OK'
    end as variance_flag
from metrics_fund_performance
where fund_type = 'EQUITY'
    and period_end_date >= current_date - interval '2 years'
    and (
        fund_nav_reported is not null 
        or called_capital_reported is not null 
        or total_distributions_reported is not null
    )
order by period_end_date desc, fund_name
