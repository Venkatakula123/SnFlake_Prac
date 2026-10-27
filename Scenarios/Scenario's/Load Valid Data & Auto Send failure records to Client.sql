use database MDB;
use warehouse COMPUTE_WH;
use role accountadmin;
create or replace schema e_stg;
use schema e_stg;
create or replace stage er url = 's3://snowflakebucket-copyoption/returnfailed/';
List @er;

Select * from table(INFER_SCHEMA(Location => '@er/Orders.csv', File_format => 'MDB.F_FMT.csvfp'));
Select object_construct(*) from table(INFER_SCHEMA(Location => '@er/Orders.csv', File_format => 'MDB.F_FMT.csvfp'));
Select ARRAY_AGG(object_construct(*)) from table(INFER_SCHEMA(Location => '@MDB.e_stg.er/Orders.csv', File_format => 'MDB.F_FMT.csvfp'));
Create or replace table public.Orders_isc using template(
    Select ARRAY_AGG(object_construct(*)) from table(INFER_SCHEMA(Location => '@MDB.e_stg.er/Orders.csv', File_format => 'MDB.F_FMT.csvfp'))
);

describe table public.Orders_isc;

COPY INTO public.Orders_isc from @er 
file_format = (format_name = mdb.f_fmt.csvf)
pattern = '.*Order.*'
validation_mode = RETURN_ALL_ERRORS;

Create or replace table mdb.public.Err_Rec as
Select * from table(result_scan(last_query_id())); 

Select * from mdb.public.Err_Rec;
--drop table mdb.public.Err_Rec;

-- When we use this COPY Option validation_mode = RETURN_ALL_ERRORS this time only result_scan(last_query_id()) only works, But when you use ON_ERROR = CONTINUE that time 
--table(validate(EMPS, job_id = '_last')) works

--Loading the Error Records to the stage
COPY INTO @MDB.I_STG.CSV/Error from mdb.public.Err_Rec 
file_format = (type = CSV skip_header = 1 field_delimiter = ',' compression = None)
SINGLE = TRUE;

