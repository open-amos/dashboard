-- Credit Yield Distribution
-- Shows yield distribution across credit instruments for portfolio analysis
-- Provides visibility into yield characteristics by security rank and interest index

select
    security_rank,
    interest_index,
    count(distinct instrument_id) as number_of_loans,
    count(distinct company_id) as number_of_companies,
    sum(principal_outstanding) as total_principal_outstanding,
    -- Yield statistics
    avg(all_in_yield) as avg_yield,
    min(all_in_yield) as min_yield,
    max(all_in_yield) as max_yield,
    avg(spread_bps) as avg_spread_bps,
    min(spread_bps) as min_spread_bps,
    max(spread_bps) as max_spread_bps,
    -- Yield buckets for distribution analysis
    case
        when all_in_yield < 0.05 then '0-5%'
        when all_in_yield >= 0.05 and all_in_yield < 0.08 then '5-8%'
        when all_in_yield >= 0.08 and all_in_yield < 0.10 then '8-10%'
        when all_in_yield >= 0.10 and all_in_yield < 0.12 then '10-12%'
        when all_in_yield >= 0.12 then '12%+'
        else 'Unknown'
    end as yield_bucket
from metrics_position_performance
where instrument_type = 'CREDIT'
    and all_in_yield is not null
    and period_end_date = (
        select max(period_end_date) 
        from metrics_position_performance
    )
group by security_rank, interest_index, yield_bucket
order by security_rank, avg_yield desc
