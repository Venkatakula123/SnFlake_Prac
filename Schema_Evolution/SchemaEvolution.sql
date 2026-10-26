use role accountadmin;
use warehouse compute_wh;
use database MDB;
use schema public;

use schema i_stg;
List @csv;

show tables in schema mdb.public;
ALTER TABLE EMPS SET ENABLE_SCHEMA_EVOLUTION = TRUE;

use schema F_FMT;

create or replace file format csvffp
type = csv
field_delimiter = ','
parse_header = true
ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE; --works fine

COPY INTO MDB.PUBLIC.EMPS
FROM @MDB.I_STG.CSV/emp/emp_5.csv
FILE_FORMAT = (FORMAT_NAME = MDB.f_fmt.csvffp)
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

Select * from emps;

describe file format MDB.F_FMT.CSVF;
alter file format MDB.F_FMT.CSVF set ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;
alter file format MDB.F_FMT.CSVF set PARSE_HEADER = FALSE;
alter file format MDB.F_FMT.CSVF set SKIP_HEADER = 1;

--Used to see the Files Processed using the COPY Command file wise no.of rows_Parsed, Row_COunt, File_size, Error Records on First record only we can see
Select * from SNOWFLAKE.ACCOUNT_USAGE.COPY_HISTORY where table_name = 'EMPS' limit 100; 

Select * from MDB.INFORMATION_SCHEMA.LOAD_HISTORY limit 100;
Select * from AIRBNB.INFORMATION_SCHEMA.LOAD_HISTORY;
Select * from SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS;