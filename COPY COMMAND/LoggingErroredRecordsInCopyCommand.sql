Use database MDB;

create or replace schema i_stg;

show stages;

List @CSV;

create or replace schema f_fmt;

Create or replace file format csvf
type = csv 
field_delimiter = ','
skip_header = 1;

describe file format csvf;

Create or replace file format mdb.f_fmt.csvfp -- For the INFER_SCHEMA
type = csv
skip_header = 0
parse_header = true
field_delimiter = ',';

Select * from table(INFER_SCHEMA(Location => '@MDB.i_stg.CSV/emp/emp.csv', File_FORMAT => 'MDB.f_fmt.csvfp'));
Select OBJECT_CONSTRUCT(*) from table(INFER_SCHEMA(Location => '@MDB.i_stg.CSV/emp/emp.csv', File_FORMAT => 'MDB.f_fmt.csvfp'));
Select ARRAY_AGG(OBJECT_CONSTRUCT(*)) from table(INFER_SCHEMA(Location => '@MDB.i_stg.CSV/emp/emp.csv', File_FORMAT => 'MDB.f_fmt.csvfp'));

Create or replace table MDB.PUBLIC.EMPS using template(
Select ARRAY_AGG(OBJECT_CONSTRUCT(*)) from table(INFER_SCHEMA(Location => '@MDB.i_stg.CSV/emp/emp.csv', File_FORMAT => 'MDB.f_fmt.csvfp')));

describe table MDB.PUBLIC.EMPS;

COPY INTO MDB.PUBLIC.EMPS from @MDB.i_stg.CSV/emp/emp.csv 
file_format = (format_name = 'MDB.f_fmt.csvf');

COPY INTO MDB.PUBLIC.EMPS from @MDB.i_stg.CSV/emp/emp_1.csv 
file_format = (format_name = 'MDB.f_fmt.csvf')
ON_ERROR = 'CONTINUE';

COPY INTO MDB.PUBLIC.EMPS from @MDB.i_stg.CSV/emp/emp_2.csv 
file_format = (format_name = 'MDB.f_fmt.csvf')
ON_ERROR = 'CONTINUE';

COPY INTO MDB.PUBLIC.EMPS from @MDB.i_stg.CSV/emp/emp_3.csv 
file_format = (format_name = 'MDB.f_fmt.csvf')
ON_ERROR = 'CONTINUE';

CREATE OR REPLACE TABLE MDB.PUBLIC.ERR_TABLE1 as 
    Select * from table(validate(MDB.PUBLIC.EMPS , JOB_ID => '_last'));

SELECT REJECTED_RECORD from MDB.PUBLIC.ERR_TABLE1;

Select 
        SPLIT_PART(REJECTED_RECORD,',',1) as EMPID,
        SPLIT_PART(REJECTED_RECORD,',',2) as FirstName,
        SPLIT_PART(REJECTED_RECORD,',',3) as LastName,
        SPLIT_PART(REJECTED_RECORD,',',4) as Gender,
        SPLIT_PART(REJECTED_RECORD,',',5) as Department,
        SPLIT_PART(REJECTED_RECORD,',',6) as JobTitle,
        SPLIT_PART(REJECTED_RECORD,',',7) as Salary,
        SPLIT_PART(REJECTED_RECORD,',',8) as HireDate,
        SPLIT_PART(REJECTED_RECORD,',',9) as City,
        SPLIT_PART(REJECTED_RECORD,',',10) as Email
    From MDB.PUBLIC.ERR_TABLE1; 


        
        


--Log the Errored Records Before loading the data into the Target tables by using the Validation_mode
COPY INTO MDB.PUBLIC.EMPS from @MDB.i_stg.CSV/emp/emp_3.csv 
file_format = (format_name = 'MDB.f_fmt.csvf')
VALIDATION_MODE = 'RETURN_ERRORS';

CREATE OR REPLACE TABLE MDB.PUBLIC.ERR_TABLERS as 
    Select * from table(result_scan(last_query_id())); -- Not work for the ON_ERROR = CONTINUE

Select * from MDB.PUBLIC.ERR_TABLERS;