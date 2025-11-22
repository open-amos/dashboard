-- Aggregate metrics for credit funds only
with latest_periods as (
    select
        fund_id,
        max(period_end_date) as latest_period_end_date
    from metrics_fund_performance
    where fund_type = 'CREDIT'
    group by fund_id
)

select
    sum(mfp.total_exposure) as total_exposure,
    sum(mfp.principal_outstanding) as principal_outstanding,
    sum(mfp.undrawn_commitment) as undrawn_commitment,
    sum(mfp.interest_income) as interest_income,
    sum(mfp.total_commitments) as total_commitments,
    count(distinct mfp.fund_id) as number_of_funds
from metrics_fund_performance mfp
inner join latest_periods lp
    on mfp.fund_id = lp.fund_id
    and mfp.period_end_date = lp.latest_period_end_date
where mfp.fund_type = 'CREDIT'
