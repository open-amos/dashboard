-- Equity Portfolio Metrics with Deltas
-- Aggregates fund-level performance metrics across all equity funds
-- Includes quarter-over-quarter deltas for key metrics
-- Filters to fund_type='EQUITY' to show only PE fund metrics

with latest_period as (
    select max(period_end_date) as max_date
    from metrics_fund_performance
    where fund_type = 'EQUITY'
),

previous_period as (
    select max(period_end_date) as prev_date
    from metrics_fund_performance
    where fund_type = 'EQUITY'
        and period_end_date < (select max_date from latest_period)
),

current_metrics as (
    select
        sum(fund_nav) as total_nav,
        sum(total_commitments) as total_commitments,
        sum(total_called_capital) as total_called_capital,
        sum(unfunded_commitment) as unfunded_commitment,
        sum(total_distributions) as total_distributions,
        -- Portfolio-level PE metrics
        sum(total_distributions) / nullif(sum(total_called_capital), 0) as dpi_portfolio,
        sum(fund_nav) / nullif(sum(total_called_capital), 0) as rvpi_portfolio,
        (sum(fund_nav) + sum(total_distributions)) / nullif(sum(total_called_capital), 0) as tvpi_portfolio,
        -- Portfolio statistics
        count(distinct fund_id) as number_of_equity_funds,
        sum(number_of_portfolio_companies) as total_portfolio_companies,
        sum(number_of_positions) as total_positions
    from metrics_fund_performance
    where fund_type = 'EQUITY'
        and period_end_date = (select max_date from latest_period)
),

prior_metrics as (
    select
        sum(fund_nav) as prev_total_nav,
        sum(unfunded_commitment) as prev_unfunded_commitment,
        sum(total_distributions) / nullif(sum(total_called_capital), 0) as prev_dpi_portfolio,
        sum(fund_nav) / nullif(sum(total_called_capital), 0) as prev_rvpi_portfolio,
        (sum(fund_nav) + sum(total_distributions)) / nullif(sum(total_called_capital), 0) as prev_tvpi_portfolio
    from metrics_fund_performance
    where fund_type = 'EQUITY'
        and period_end_date = (select prev_date from previous_period)
)

select
    -- Current values
    c.total_nav,
    c.total_commitments,
    c.total_called_capital,
    c.unfunded_commitment,
    c.total_distributions,
    c.dpi_portfolio,
    c.rvpi_portfolio,
    c.tvpi_portfolio,
    c.number_of_equity_funds,
    c.total_portfolio_companies,
    c.total_positions,
    
    -- Previous period values
    p.prev_total_nav,
    p.prev_unfunded_commitment,
    p.prev_dpi_portfolio,
    p.prev_rvpi_portfolio,
    p.prev_tvpi_portfolio,
    
    -- Delta calculations
    -- NAV: percent delta
    case 
        when p.prev_total_nav is not null and p.prev_total_nav != 0
        then (c.total_nav - p.prev_total_nav) / p.prev_total_nav
        else null
    end as nav_delta_pct,
    
    -- TVPI: absolute delta
    case 
        when p.prev_tvpi_portfolio is not null
        then c.tvpi_portfolio - p.prev_tvpi_portfolio
        else null
    end as tvpi_delta,
    
    -- DPI: absolute delta
    case 
        when p.prev_dpi_portfolio is not null
        then c.dpi_portfolio - p.prev_dpi_portfolio
        else null
    end as dpi_delta,
    
    -- RVPI: absolute delta
    case 
        when p.prev_rvpi_portfolio is not null
        then c.rvpi_portfolio - p.prev_rvpi_portfolio
        else null
    end as rvpi_delta,
    
    -- Unfunded Commitment: absolute delta
    case 
        when p.prev_unfunded_commitment is not null
        then c.unfunded_commitment - p.prev_unfunded_commitment
        else null
    end as unfunded_delta,
    
    -- Validation checks (private markets realism)
    -- TVPI should always be >= DPI
    case 
        when c.tvpi_portfolio < c.dpi_portfolio 
        then 'WARNING: TVPI < DPI (impossible)'
        else 'OK'
    end as tvpi_dpi_check,
    
    -- RVPI should equal TVPI - DPI (within rounding)
    case 
        when abs(c.rvpi_portfolio - (c.tvpi_portfolio - c.dpi_portfolio)) > 0.01
        then 'WARNING: RVPI != TVPI - DPI'
        else 'OK'
    end as rvpi_consistency_check

from current_metrics c
cross join prior_metrics p
