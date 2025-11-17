---
title: Companies
queries:
  - companies_list: dimensions/companies_list.sql
  - companies_breakdown: metrics/companies_breakdown.sql
  - company_performance_overview: metrics/company_performance_overview.sql
---

## Portfolio Companies Overview

### Companies

<DataTable 
  data={companies_list}
  link=company_link
  rows=20
>
  <Column id=company_name title="Company Name" />
  <Column id=primary_country title="Primary Country" />
  <Column id=primary_industry title="Primary Industry" />
  <Column id=funds title="Funds" fmt="num0" />
  <Column id=number_of_instruments title="Number of Instruments" fmt="num0" />
</DataTable>

### Company Composition

<Grid cols=2>

<ECharts config={{
  title: { text: 'Companies by Country' },
  tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
  series: [{
    type: 'pie',
    radius: '70%',
    data: (companies_breakdown || [])
      .filter(d => d.dimension_type === 'country')
      .map(d => ({ name: d.dimension, value: d.company_count }))
  }]
}} />

<ECharts config={{
  title: { text: 'Companies by Industry' },
  tooltip: { trigger: 'item', formatter: '{b}: {c} ({d}%)' },
  series: [{
    type: 'pie',
    radius: '70%',
    data: (companies_breakdown || [])
      .filter(d => d.dimension_type === 'industry')
      .map(d => ({ name: d.dimension, value: d.company_count }))
  }]
}} />

</Grid>

### Revenue by Company

<BarChart 
  data={company_performance_overview}
  x=company_name
  y=revenue
  yFmt="usd0"
  title="Revenue by Company"
  swapXY=true
/>
