--https://www.youtube.com/watch?v=6Y-x1Dt-xWs&list=PL__gObEGy1Y5jmkhnNIY4uk4Na0Mjd_bK&index=3

use database MDB;
use schema public; 

show tables in schema PUBLIC;

CREATE OR REPLACE TABLE MDB.PUBLIC.CUSTOMER
(C_CUSTKEY	int
,C_NAME	varchar
,C_ADDRESS	varchar
,C_NATIONKEY	int
,C_PHONE	varchar
,C_ACCTBAL	varchar
,C_MKTSEGMENT	varchar
,C_COMMENT	varchar
,N_NAME	varchar
,Load_date	Date
);

Create or Replace file format MDB.FFMT.CSVT
TYPE='CSV'
SKIP_HEADER=1
FIELD_DELIMITER=','
RECORD_DELIMITER='\n'
FIELD_OPTIONALLY_ENCLOSED_BY ='"'
DATE_FORMAT='DD-MM-YYYY'
COMPRESSION = NONE;

describe file format MDB.FFMT.CSVT;

show parameters;
Alter session set DATE_OUTPUT_FORMAT = 'DD-MM-YYYY';
select current_date;
Alter session set TIMEZONE = 'Asia/Calcutta';
Select current_time();

use schema e_stg;
describe storage integration es3;

create or replace stage source_STAGE
storage_integration = es3
url = 's3://snowflakeff/sourcefolder/';
LIST @source_STAGE;

create or replace stage TARGET_STAGE
storage_integration = es3
url = 's3://snowflakeff/rejectedFolder/';
List @MDB.E_STG.TARGET_STAGE;

COPY into MDB.PUBLIC.CUSTOMER from @source_STAGE
file_format = (format_name = MDB.FFMT.CSVT )
pattern = '.*Customer.*'
ON_ERROR =  CONTINUE;

COPY into MDB.PUBLIC.CUSTOMER from @source_STAGE
file_format = (format_name = MDB.FFMT.CSVT )
pattern = ".*Customer.*"
VALIDATION_MODE = RETURN_ERRORS;

COPY into MDB.PUBLIC.CUSTOMER from @source_STAGE
file_format = (format_name = MDB.FFMT.CSVT )
pattern = '.*Customer.*'
RETURN_FAILED_ONLY = true;

--CREATE OR REPLACE TABLE MDB.PUBLIC.FAULTY_RECORDS AS  
--Select * from table(validate(CUSTOMER, job_id => '01c66904-0302-bbe3-001b-fc4700bf049e'));

CREATE OR REPLACE TABLE MDB.PUBLIC.FAULTY_RECORDS AS  
Select * from table(validate(CUSTOMER, job_id => '_last'));
--drop table MDB.PUBLIC.FAULTY_RECORDS;

Select * from MDB.PUBLIC.FAULTY_RECORDS;

COPY INTO @TARGET_STAGE/FAULTY_RECORDS.csv
from MDB.PUBLIC.FAULTY_RECORDS
SINGLE = TRUE;

use schema SPROC;

create or replace procedure FAULTY_RECORDS_EXPORT(t_name string,s_stg string,t_stg string)
returns string
language SQL
AS
$$
BEGIN 
 LET VALIDATE_DATA := 'COPY into ' || t_name || ' ' || 'from @'|| s_stg || ' ' ||'
                        file_format = (format_name = MDB.FFMT.CSVT ) ' || ' ' ||
                        'pattern =' || ' ".*Customer.*" ' || 
                        'VALIDATION_MODE =  RETURN_ERRORS;';

 LET COPY_SQL := 'COPY into ' || t_name || ' ' || 'from @'|| s_stg || ' ' || '
                    file_format = (format_name = MDB.FFMT.CSVT ) ' || ' ' ||
                    'pattern =' || ' ".*Customer.*" ' || 
                    'ON_ERROR =  CONTINUE;';

 EXECUTE IMMEDIATE :COPY_SQL;

 LET VALIDATE_SQL := 'CREATE OR REPLACE TABLE MDB.PUBLIC.FAULTY_RECORDS AS' || ' ' ||
                        'SELECT   FILE,CATEGORY,ERROR,REJECTED_RECORD FROM TABLE( VALIDATE(' || t_name || ', JOB_ID => "_last");';

 EXECUTE IMMEDIATE :VALIDATE_SQL;
 
 LET LOAD_FAIL_DATA := 'COPY INTO @' || t_stg || '/faultyrecords.csv
                            FROM MDB.PUBLIC.FAULTY_RECORDS
                            SINGLE = TRUE
                            OVERWRITE = TRUE;';   
                            
 EXECUTE IMMEDIATE :LOAD_FAIL_DATA; 

return VALIDATE_DATA || ' ' || COPY_SQL || ' ' ||  VALIDATE_SQL || ' ' || LOAD_FAIL_DATA ;
END;
$$;

CALL FAULTY_RECORDS_EXPORT('MDB.PUBLIC.CUSTOMER','MDB.E_STG.source_STAGE','MDB.E_STG.TARGET_STAGE');


CREATE OR REPLACE PROCEDURE FAULTY_RECORDS_EXPORT(t_name STRING, s_stg STRING, t_stg STRING)
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  LET VALIDATE_DATA := 'COPY INTO ' || t_name || ' FROM @' || s_stg ||
    ' file_format = (format_name = MDB.FFMT.CSVT) pattern = ".*Customer.*" VALIDATION_MODE = RETURN_ERRORS;';

  LET COPY_SQL := 'COPY INTO ' || t_name || ' FROM @' || s_stg ||
    ' file_format = (format_name = MDB.FFMT.CSVT) pattern = ".*Customer.*" ON_ERROR = CONTINUE;';

  EXECUTE IMMEDIATE :COPY_SQL;

  LET VALIDATE_SQL := 'CREATE OR REPLACE TABLE MDB.PUBLIC.FAULTY_RECORDS AS ' ||
    'SELECT FILE, CATEGORY, ERROR, REJECTED_RECORD FROM TABLE(VALIDATE(' || t_name || ', JOB_ID => ''_last''));';

  EXECUTE IMMEDIATE :VALIDATE_SQL;

  LET LOAD_FAIL_DATA := 'COPY INTO @' || t_stg ||
    '/faultyrecords.csv FROM MDB.PUBLIC.FAULTY_RECORDS SINGLE = TRUE OVERWRITE = TRUE;';

  EXECUTE IMMEDIATE :LOAD_FAIL_DATA;

  RETURN VALIDATE_DATA || ' ' || COPY_SQL || ' ' || VALIDATE_SQL || ' ' || LOAD_FAIL_DATA;
END;
$$;

CALL FAULTY_RECORDS_EXPORT('MDB.PUBLIC.CUSTOMER', 'MDB.E_STG.source_STAGE', 'MDB.E_STG.TARGET_STAGE');

Select * from MDB.PUBLIC.CUSTOMER;

