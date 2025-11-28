-- Pipeline stage velocity and conversion metrics
-- Note: Conversion rates use funnel-style calculation (cumulative approach)
-- since we don't have historical stage transitions
with stage_data as (
    select
        opp.opportunity_id,
        opp.amount,
        stg.name as stage_name,
        stg."order" as stage_order,
        current_date - opp.created_at::date as days_in_pipeline
    from dim_opportunities opp
    inner join dim_stages stg on opp.stage_id = stg.stage_id
    where stg.name not in ('Lost', 'Declined')
      and (opp.fund_id = '${inputs.fund.value}' or '${inputs.fund.value}' = 'ALL' or '${inputs.fund.value}' is null)
),
stage_metrics as (
    select
        stage_name,
        stage_order,
        count(distinct opportunity_id) as deal_count,
        sum(amount) as pipeline_value,
        avg(days_in_pipeline) as avg_days_in_stage
    from stage_data
    group by stage_name, stage_order
),
cumulative_counts as (
    select
        stage_name,
        stage_order,
        deal_count,
        pipeline_value,
        avg_days_in_stage,
        -- Cumulative count from this stage forward (this + all later stages)
        sum(deal_count) over (
            order by stage_order 
            rows between current row and unbounded following
        ) as cumulative_deals_from_here
    from stage_metrics
)
select
    stage_name,
    stage_order,
    avg_days_in_stage,
    -- Conversion = (deals in next+ stages) / (deals in current+ stages)
    -- Example: Stage B conversion = (C+D+E deals) / (B+C+D+E deals)
    case 
        when cumulative_deals_from_here > deal_count 
        then (cumulative_deals_from_here - deal_count)::float / cumulative_deals_from_here
        else null 
    end as conversion_to_next_stage
from cumulative_counts
order by stage_order
