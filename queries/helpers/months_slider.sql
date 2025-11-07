with months as (
  select distinct date_trunc('month', cast(exposure_month as date)) as month
  from metrics_exposure_by_region
  where 1=1
    and cast(fund_id as varchar) = '${inputs.fund.value}'
    and cast(stage_id as varchar) = '${inputs.stage.value}'
    and region = '${inputs.region.value}'
    and country_code = '${inputs.country.value}'
), ordered as (
  select 
    month, 
    row_number() over (order by month) as month_idx,
    date_diff('day', date '1899-12-30', month) as excel_serial
  from months
)
select
  month,
  month_idx,
  excel_serial,
  max(excel_serial) over () as max_serial,
  min(excel_serial) over () as min_serial
from ordered
order by month


