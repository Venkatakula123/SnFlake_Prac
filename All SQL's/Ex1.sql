WITH c_date AS (SELECT MAX(DATE(business_date)) as business_date ,
MAX(DATE(audit_created_date)) as audit_created_date
FROM public.TBLE
)
SELECT
business_date,
audit_created_date from c_date
WHERE business_date <= audit_created_date;


Table: Job log

	date_value  state
 
	2019-01-01  success
 
	2019-01-02  success
 
	2019-01-03  success
 
	2019-01-04  fail
 
	2019-01-05  fail
 
	2019-01-06  success

 
 
	start_date  end_date         state
 
	2019-01-01    2019-01-03     success
 
	2019-01-04    2019-01-05       fail
 
	2019-01-06    2019-01-06      success
 
 
 WITH GroupedJobs AS(
    select date_value,state, dateadd('day', -rownumber() over(partition by state orderby date_value), date_value) as groupid from 
    job_log 
 )

 Select min(date_value) as start_date, max(date_value) as end_date, state from GroupedJobs groupby state,groupid 




 | emp_id | sale_date | sale_amount |
| ------- | ---------- | ------------ |
| 101     | 2025-01-01 | 1000         |
| 101     | 2025-01-05 | 1200         |
| 102     | 2025-01-05 | 2000         |
| 103     | 2025-01-03 | 1500         |
 
Running Total of Sales Per Employee




Select emp_id, sale_date, sale_amount, sum(sale_amount) over(partition by empid order by sales_date ) as running_total from Sales ; 
