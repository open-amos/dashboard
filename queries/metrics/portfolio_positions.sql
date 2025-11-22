-- All portfolio positions for scatter plot analysis
with latest_instrument_snapshots as (
    select
        instrument_id,
        max(period_end_date) as latest_period_end_date
    from metrics_position_performance
    group by instrument_id
)

select 
    mpp.instrument_id,
    mpp.instrument_name,
    mpp.company_name,
    mpp.fund_name,
    mpp.instrument_type,
    mpp.cumulative_invested,
    mpp.fair_value as current_fair_value,
    (mpp.fair_value + coalesce(mpp.cumulative_distributions, 0)) as total_value,
    mpp.moic as gross_moic,
    mpp.equity_irr as gross_irr,
    mpp.holding_period_years
from metrics_position_performance mpp
inner join latest_instrument_snapshots lis
    on mpp.instrument_id = lis.instrument_id
    and mpp.period_end_date = lis.latest_period_end_date
where mpp.cumulative_invested > 0
order by mpp.moic desc
