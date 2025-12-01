-- Fund Key Metrics with Deltas
-- Shows current period metrics and quarter-over-quarter deltas for a specific fund
-- Includes delta calculations for NAV, TVPI, DPI, and RVPI

with latest_period as (
    select max(period_end_date) as max_date
    from metrics_fund_performance
    where fund_id = '${params.id}'
),

previous_period as (
    select max(period_end_date) as prev_date
    from metrics_fund_performance
    where fund_id = '${params.id}'
        and period_end_date < (select max_date from latest_period)
),

current_metrics as (
    select
        fund_id,
        fund_name,
        fund_type,
        period_end_date,
        fund_nav,
        total_commitments,
        total_called_capital,
        unfunded_commitment,
        total_distributions,
        dpi,
        rvpi,
        tvpi,
        expected_coc,
        number_of_portfolio_companies,
        number_of_positions,
        as_of_date,
        -- Credit-specific metrics
        total_exposure,
        principal_outstanding,
        undrawn_commitment,
        interest_income
    from metrics_fund_performance
    where fund_id = '${params.id}'
        and period_end_date = (select max_date from latest_period)
),

prior_metrics as (
    select
        fund_nav as prev_fund_nav,
        dpi as prev_dpi,
        rvpi as prev_rvpi,
        tvpi as prev_tvpi,
        unfunded_commitment as prev_unfunded_commitment
    from metrics_fund_performance
    where fund_id = '${params.id}'
        and period_end_date = (select prev_date from previous_period)
)

select
    -- Current values
    c.fund_id,
    c.fund_name,
    c.fund_type,
    c.period_end_date,
    c.fund_nav,
    c.total_commitments,
    c.total_called_capital,
    c.unfunded_commitment,
    c.total_distributions,
    c.dpi,
    c.rvpi,
    c.tvpi,
    c.expected_coc,
    c.number_of_portfolio_companies,
    c.number_of_positions,
    c.as_of_date,
    c.total_exposure,
    c.principal_outstanding,
    c.undrawn_commitment,
    c.interest_income,
    
    -- Previous period values
    p.prev_fund_nav,
    p.prev_dpi,
    p.prev_rvpi,
    p.prev_tvpi,
    p.prev_unfunded_commitment,
    
    -- Delta calculations
    -- NAV: percent delta
    case 
        when p.prev_fund_nav is not null and p.prev_fund_nav != 0
        then (c.fund_nav - p.prev_fund_nav) / p.prev_fund_nav
        else null
    end as nav_delta_pct,
    
    -- TVPI: absolute delta
    case 
        when p.prev_tvpi is not null
        then c.tvpi - p.prev_tvpi
        else null
    end as tvpi_delta,
    
    -- DPI: absolute delta
    case 
        when p.prev_dpi is not null
        then c.dpi - p.prev_dpi
        else null
    end as dpi_delta,
    
    -- RVPI: absolute delta
    case 
        when p.prev_rvpi is not null
        then c.rvpi - p.prev_rvpi
        else null
    end as rvpi_delta,
    
    -- Unfunded Commitment: absolute delta
    case 
        when p.prev_unfunded_commitment is not null
        then c.unfunded_commitment - p.prev_unfunded_commitment
        else null
    end as unfunded_delta

from current_metrics c
left join prior_metrics p on 1=1
