---
title: Portfolio
---

<Dropdown data={funds} name=fund value=fund_id label=fund_name defaultValue="ALL" />
<Dropdown data={stages} name=stage value=stage_id label=stage_name defaultValue="ALL" />
<Dropdown data={regions} name=region value=region label=region defaultValue="ALL" />

<AreaChart
  data={exposure_ts}
  title="Current vs Forecast Exposure Over Time"
  type="stacked"
  x=month
  y=total_exposure_usd
  series=period_type
/>

```sql metrics
  select
    *
  from mrt_exposure_by_region
  order by total_exposure_usd desc 
```

```sql funds
  select distinct
    fund_id,
    fund_name
  from mrt_exposure_by_region
  order by fund_name
```

```sql stages
  select distinct
    stage_id,
    stage_name
  from mrt_exposure_by_region
  order by stage_name
```
```sql regions
  select distinct
    region
  from mrt_exposure_by_region
  order by region
```

```sql exposure_ts
  with base as (
    select
      date_trunc('month', cast(exposure_month as timestamp)) as month,
      period_type,
      sum(total_exposure_usd) as value
    from mrt_exposure_by_region
    where 1=1
      and cast(fund_id as varchar) = '${inputs.fund.value}'
      and cast(stage_id as varchar) = '${inputs.stage.value}'
      and region = '${inputs.region.value}'
    group by 1, 2
  ), bounds as (
    select min(month) as min_month, max(month) as max_month from base
  ), months as (
    select d.series as month
    from bounds
    cross join generate_series(min_month, max_month, interval 1 month) as d(series)
  ), forecast_points as (
    select month, value from base where period_type = 'Forecast'
  ), forecast_series as (
    select m.month, coalesce(f.value, 0) as value
    from months m
    left join forecast_points f on f.month = m.month
  ), forecast_cum as (
    select month, 'Forecast' as period_type,
           sum(value) over (order by month rows between unbounded preceding and current row) as total_exposure_usd
    from forecast_series
  ), current_points as (
    select month, value from base where period_type = 'Current' and value is not null
  ), current_ffill as (
    select
      m.month,
      'Current' as period_type,
      coalesce((
        select cp.value
        from current_points cp
        where cp.month <= m.month
        order by cp.month desc
        limit 1
      ), 0) as total_exposure_usd
    from months m
  )
  select month, period_type, coalesce(total_exposure_usd, 0) as total_exposure_usd
  from (
    select * from current_ffill
    union all
    select * from forecast_cum
  )
  order by month asc
```