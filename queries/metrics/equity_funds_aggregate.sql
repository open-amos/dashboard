-- Aggregate metrics for equity funds only
with latest_periods as (
    select
        fund_id,
        max(period_end_date) as latest_period_end_date
    from metrics_fund_performance
    where fund_type = 'EQUITY'
    group by fund_id
)

select
    sum(mfp.total_commitments) as total_commitments,
    sum(mfp.unfunded_commitment) as unfunded_commitment,
    sum(mfp.total_distributions) as total_distributions,
    sum(mfp.fund_nav) as total_nav,
    count(distinct mfp.fund_id) as number_of_funds
from metrics_fund_performance mfp
inner join latest_periods lp
    on mfp.fund_id = lp.fund_id
    and mfp.period_end_date = lp.latest_period_end_date
where mfp.fund_type = 'EQUITY'
