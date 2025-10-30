---
title: Portfolio
---

```sql metrics
  select
    *
  from mrt_exposure_by_region
  order by total_exposure_usd desc 
```

```sql exposure_ts
  select
    cast(exposure_month as timestamp) as month,
    region,
    total_exposure_usd
  from mrt_exposure_by_region
  order by month asc, region
```

<LineChart
  data={exposure_ts}
  title="Total Exposure by Region Over Time"
  x=month
  y=total_exposure_usd
  series=region
/>