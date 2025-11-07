select distinct
  country_code,
  country_name
from metrics_exposure_by_region
where country_code is not null
  and country_name is not null
  and region = '${inputs.region.value}'
order by country_name


