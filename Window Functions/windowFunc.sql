use Database MDB;
create or replace schema E_STG;

use schema E_STG;

create or replace stage instg;

List @instg;

create or replace schema F_FMT;

use schema F_FMT;

create or replace file format csv_p 
type = csv
parse_header = true
field_delimiter = ',';

use schema E_STG;

Select * from table(INFER_SCHEMA(location => '@instg/Employees_WindowFunctions.csv' , file_format => 'MDB.F_FMT.csv_p'));

Create table public.EMPLOYEES_R using template (Select ARRAY_AGG(OBJECT_CONSTRUCT(*)) from table(INFER_SCHEMA(location => '@instg/Employees_MultiYear.csv' , file_format => 'MDB.F_FMT.csv_p'))) ;
Select * from public.EMPLOYEES;

COPY INTO public.EMPLOYEES_R from @instg/Employees_MultiYear.csv
file_format = (type = csv field_delimiter = ',' skip_header = 1);

Select * from public.EMPLOYEES;

Select EMP_ID, count(*) from public.EMPLOYEES_R group by emp_id having count(*) > 1;

Select * from public.EMPLOYEES_FULL ;

Select * from public.EMPLOYEES_R;

Select e.*,ROW_NUMBER() over(partition by e.emp_id order by e.year desc) as rn from public.EMPLOYEES_R e where status = 'Active' Qualify rn = 1 ; 

