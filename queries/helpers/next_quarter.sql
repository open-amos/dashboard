-- Next quarter label for forward-looking sections
select 
  'Q' || extract(quarter from (current_date + interval '3 months')) || ' ' || 
  extract(year from (current_date + interval '3 months')) as next_quarter_label
