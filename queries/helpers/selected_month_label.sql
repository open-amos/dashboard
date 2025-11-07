select strftime(date '1899-12-30' + (${inputs.month} * interval 1 day), '%b %Y') as label


