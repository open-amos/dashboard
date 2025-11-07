with base as (
  select
    date_trunc('month', cast(exposure_month as date)) as month,
    country_code,
    sum(coalesce(total_exposure_usd,0)) as exposure
  from metrics_exposure_by_region
  where 1=1
    and cast(fund_id as varchar) = '${inputs.fund.value}'
    and cast(stage_id as varchar) = '${inputs.stage.value}'
  group by 1,2
), selected as (
  select date_trunc('month', cast(date '1899-12-30' + (${inputs.month} * interval 1 day) as date)) as selected_month
)
select b.country_code, b.exposure as exposure
from base b
where b.month = (select selected_month from selected)


