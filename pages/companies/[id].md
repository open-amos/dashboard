---
queries:
  - company_info: dimensions/company_info.sql
  - company_financials: metrics/company_financials_timeseries.sql
  - company_instruments: metrics/company_instruments.sql
---

# {company_info[0].company_name}

Website: <Link url={company_info[0].website} label={company_info[0].website} />   
Primary sector: {company_info[0].primary_industry}  
Primary country: {company_info[0].primary_country}  

{company_info[0].description} 

<hr class="my-4" />

## Instruments

{#if company_instruments.length}

<DataTable data={company_instruments}>
  <Column id=instrument_name title="Instrument" />
  <Column id=instrument_type title="Type" />
  <Column id=fund_name title="Fund" />
  <Column id=initial_investment_date title="Investment Date" />
  <Column id=exit_date title="Exit Date" />
  <Column id=cumulative_invested title="Invested" fmt=usd0 />
  <Column id=current_fair_value title="Fair Value" fmt=usd0 />
  <Column id=total_value title="Total Value" fmt=usd0 />
  <Column id=gross_moic title="MOIC" fmt=num1 />
  <Column id=gross_irr title="IRR" fmt=pct1 />
  <Column id=ownership_pct_current title="Ownership %" fmt=pct1 />
</DataTable>

{:else}

No instruments.

{/if}

<hr class="my-4" />

## Financial Performance

<Grid cols=2>

<LineChart
  data={company_financials}
  title="Revenue Over Time"
  x=period_end_date
  y=revenue
  yFmt=usd0
/>

<LineChart
  data={company_financials}
  title="EBITDA Over Time"
  x=period_end_date
  y=ebitda
  yFmt=usd0
/>

</Grid>

<LineChart
  data={company_financials}
  title="EBITDA Margin"
  x=period_end_date
  y=ebitda_margin
  yFmt=pct1
/>