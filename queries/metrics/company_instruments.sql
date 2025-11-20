-- Show all instruments for a company, including those without snapshots
-- For instruments without snapshots, performance metrics will be null

select
    i.instrument_id,
    i.name as instrument_name,
    i.instrument_type,
    f.name as fund_name,
    i.inception_date as initial_investment_date,
    coalesce(i.termination_date::text, '') as exit_date,
    mpp.initial_cost,
    mpp.cumulative_invested,
    mpp.realized_proceeds,
    mpp.current_fair_value,
    mpp.total_value,
    mpp.gross_moic,
    mpp.gross_irr,
    mpp.ownership_pct_current,
    mpp.holding_period_years
from dim_instruments i
inner join dim_funds f on i.fund_id = f.fund_id
left join (
    select 
        mpp.*,
        row_number() over (partition by instrument_id order by period_end_date desc) as rn
    from metrics_position_performance mpp
) mpp on i.instrument_id = mpp.instrument_id and mpp.rn = 1
where i.company_id = '${params.id}'
order by i.inception_date desc
