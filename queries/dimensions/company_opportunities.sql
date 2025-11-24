-- Get CRM opportunities for a specific company
select
    o.opportunity_id,
    o.name as opportunity_name,
    s.name as stage_name,
    o.close_date as expected_close_date,
    o.amount as deal_size,
    'USD' as deal_size_currency,
    o.source as lead_source,
    o.responsible as owner_name,
    o.created_at as created_date,
    o.updated_at as last_modified_date,
    f.name as fund_name,
    f.fund_id
from dim_opportunities o
left join dim_funds f on o.fund_id = f.fund_id
left join dim_stages s on o.stage_id = s.stage_id
where o.company_id = '${params.id}'
order by o.updated_at desc
