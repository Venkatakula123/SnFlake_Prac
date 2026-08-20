--https://www.youtube.com/watch?v=C3BuKL6-kFA&list=PL__gObEGy1Y5jmkhnNIY4uk4Na0Mjd_bK
-- We will have files in s3 bucket like in the below 
-- s3://snflakesce/2026/08/13/Customer.csv Today's File
-- s3://snflakesce/2026/08/14/Customer.csv Tomorrow's File. Files will be landing in the Particular Date Directory on day basis. We need to automate this.

use database MDB;
use schema E_STG;

show storage integrations;

describe integration ES3;

ALTER STORAGE INTEGRATION ES3 SET STORAGE_ALLOWED_LOCATIONS = ('s3://allff/','s3://snowflakeff/','s3://snflakesce/');

create or replace stage snflakesce1  
storage_integration = ES3 url = 's3://snflakesce/';

describe stage snflakesce1;

List @snflakesce1;

--create a table
CREATE OR REPLACE TABLE MDB.PUBLIC.EMPSCE(ID NUMBER(6),NAME VARCHAR(100));
--DROP TABLE MDB.PUBLIC.EMPSCE;
Select * from MDB.PUBLIC.EMPSCE;
describe table MDB.PUBLIC.EMPSCE;

describe file format MDB.FFMT.CSVF;

COPY INTO MDB.PUBLIC.EMPSCE from @MDB.E_STG.snflakesce1/2026/08/13/ 
FILE_FORMAT = (FORMAT_NAME = MDB.FFMT.CSVF);

SELECT TO_CHAR(CURRENT_DATE(),'yyyy');
SELECT TO_CHAR(CURRENT_DATE(),'YYYY');
SELECT TO_CHAR(CURRENT_DATE(),'MM');
SELECT TO_CHAR(CURRENT_DATE(),'MON');
SELECT TO_CHAR(CURRENT_DATE(),'dd');
SELECT TO_CHAR(CURRENT_DATE(),'dd');
SELECT TO_CHAR(CURRENT_DATE(),'DDD');

CREATE OR REPLACE SCHEMA SPROC;

USE SCHEMA SPROC;

CREATE OR REPLACE PROCEDURE  L_FILES() 
RETURNS STRING
LANGUAGE SQL 
AS 
$$
BEGIN
--GET YEAR,MONTH AND DATE
LET VAR_YEAR := TO_CHAR(CURRENT_DATE(),'YYYY');
LET VAR_MONTH := TO_CHAR(CURRENT_DATE(),'MM');
LET VAR_DAY := TO_CHAR(CURRENT_DATE(),'DD');

--BUILDING FULL S3 PATH
LET VAR_S3_PATH := '/' || VAR_YEAR || '/' || VAR_MONTH || '/' || VAR_DAY || '/';
LET F_FMT := 'FILE_FORMAT = (FORMAT_NAME = MDB.FFMT.CSVF)';

--BUILDING FULL DYNAMIC SQL
LET VAR_SQL := 'COPY INTO MDB.PUBLIC.EMPSCE '||'FROM @MDB.E_STG.snflakesce1' || VAR_S3_PATH || ' ' || F_FMT || ' ; ';

EXECUTE IMMEDIATE:VAR_SQL;

RETURN 'STATEMENT EXECUTED SUCCESSFULLY'|| '' || VAR_SQL;
END;
$$;

call L_FILES();