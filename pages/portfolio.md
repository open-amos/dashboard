---
title: Portfolio
---

<Dropdown data={funds} name=fund value=fund_id label=fund_name defaultValue="ALL" />
<Dropdown data={stages} name=stage value=stage_id label=stage_name defaultValue="ALL" />

<LineChart
  data={exposure_ts}
  title="Total Exposure by Region Over Time"
  x=month
  y=total_exposure_usd
  series=region
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

```sql exposure_ts
  select
    cast(exposure_month as timestamp) as month,
    region, 
    total_exposure_usd
  from mrt_exposure_by_region
  where 1=1
  and cast(fund_id as varchar) = '${inputs.fund.value}'
  and cast(stage_id as varchar) = '${inputs.stage.value}'
  order by month asc, region
```