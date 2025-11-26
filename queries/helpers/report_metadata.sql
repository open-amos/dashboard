-- Report metadata with current date and quarter information
select 
  strftime(current_date, '%b %d, %Y') as report_date,
  strftime(date_trunc('quarter', current_date), '%b %d, %Y') as quarter_start,
  strftime(date_trunc('quarter', current_date) + interval '3 months' - interval '1 day', '%b %d, %Y') as quarter_end,
  'Q' || extract(quarter from current_date) || ' ' || extract(year from current_date) as quarter_label
