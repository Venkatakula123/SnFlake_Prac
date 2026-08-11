use database MDB;

--create or replace schema SPipe;
use schema spipe;

CREATE OR REPLACE TABLE mdb.public.emp_data 
(
  id INT,
  first_name STRING,
  last_name STRING,
  email STRING,
  location STRING,
  department STRING
);
Select * from mdb.public.emp_data;
--TRUNCATE TABLE mdb.public.emp_data;

Select count(*) from mdb.public.emp_data;

Select * from mdb.public.emp_data where id between 800 and 880;

Show tables like '%emp_data%';

Alter table mdb.public.emp_data set enable_schema_evolution = true;

list @MDB.E_STG.estg3;
Select  $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14 from @MDB.E_STG.estg3/AllEmps/sp_employee_1.csv;

select current_schema();

--Testing the COPY COMMAND
COPY INTO mdb.public.emp_data from @MDB.E_STG.estg3
file_format = (format_name = MDB.FFMT.csvf)
files = ('sp_employee_10.csv')
MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE;

create or replace pipe emp_spipe
auto_ingest = true
as
COPY INTO mdb.public.emp_data from @MDB.E_STG.estg3
file_format = (format_name = MDB.FFMT.csvf)
pattern = '.*employee.*';


describe pipe emp_spipe;

--Alter pipe mdb.spipe.emp_spipe set PIPE_EXECUTION_PAUSED = TRUE;
--Alter pipe mdb.spipe.emp_spipe set PIPE_EXECUTION_PAUSED = FALSE;
--Check Snowpipe status
Select System$pipe_status('MDB.SPIPE.emp_spipe');
/* 
{
  "executionState": "RUNNING",
  "pendingFileCount": 0,
  "notificationChannelName": "arn:aws:sqs:eu-north-1:494952235343:sf-snowpipe-AIDAXGPLTYFHYIBIBMQYE-qvLqq0WA3vt_KmjJzZY62w",
  "numOutstandingMessagesOnChannel": 0,
  "lastReceivedMessageTimestamp": "2026-08-11T05:07:56.538Z",
  "lastForwardedMessageTimestamp": "2026-08-11T05:07:57.345Z",
  "lastPulledFromChannelTimestamp": "2026-08-11T05:08:16.421Z",
  "lastForwardedFilePath": "allff/csv/AllEmps/sp_employee_1.csv",
  "pendingHistoryRefreshJobsCount": 0
}
--=========================================================================================================================================
{
  "executionState": "RUNNING",
  "pendingFileCount": 0,
  "lastIngestedTimestamp": "2026-08-11T05:07:56.979Z",
  "lastIngestedFilePath": "AllEmps/sp_employee_1.csv",
  "notificationChannelName": "arn:aws:sqs:eu-north-1:494952235343:sf-snowpipe-AIDAXGPLTYFHYIBIBMQYE-qvLqq0WA3vt_KmjJzZY62w",
  "numOutstandingMessagesOnChannel": 1,
  "lastReceivedMessageTimestamp": "2026-08-11T05:10:26.534Z",
  "lastForwardedMessageTimestamp": "2026-08-11T05:10:26.595Z",
  "lastPulledFromChannelTimestamp": "2026-08-11T05:10:31.418Z",
  "lastForwardedFilePath": "allff/csv/AllEmps/sp_employee_2.csv",
  "pendingHistoryRefreshJobsCount": 0
}

--==============================================================
uploaded 2 files at a time 
{
  "executionState": "RUNNING",
  "pendingFileCount": 0,
  "lastIngestedTimestamp": "2026-08-11T05:10:26.588Z",
  "lastIngestedFilePath": "AllEmps/sp_employee_2.csv",
  "notificationChannelName": "arn:aws:sqs:eu-north-1:494952235343:sf-snowpipe-AIDAXGPLTYFHYIBIBMQYE-qvLqq0WA3vt_KmjJzZY62w",
  "numOutstandingMessagesOnChannel": 2,
  "lastReceivedMessageTimestamp": "2026-08-11T05:10:26.534Z",
  "lastForwardedMessageTimestamp": "2026-08-11T05:10:26.595Z",
  "lastPulledFromChannelTimestamp": "2026-08-11T05:11:41.42Z",
  "lastForwardedFilePath": "allff/csv/AllEmps/sp_employee_2.csv",
  "pendingHistoryRefreshJobsCount": 0
}
{
  "executionState": "RUNNING",
  "pendingFileCount": 0,
  "lastIngestedTimestamp": "2026-08-11T05:11:41.709Z",
  "lastIngestedFilePath": "AllEmps/sp_employee_3.csv",
  "notificationChannelName": "arn:aws:sqs:eu-north-1:494952235343:sf-snowpipe-AIDAXGPLTYFHYIBIBMQYE-qvLqq0WA3vt_KmjJzZY62w",
  "numOutstandingMessagesOnChannel": 0,
  "lastReceivedMessageTimestamp": "2026-08-11T05:11:41.65Z",
  "lastForwardedMessageTimestamp": "2026-08-11T05:11:41.723Z",
  "lastPulledFromChannelTimestamp": "2026-08-11T05:12:11.419Z",
  "lastForwardedFilePath": "allff/csv/AllEmps/sp_employee_3.csv",
  "pendingHistoryRefreshJobsCount": 0
}

*/

Alter pipe MDB.SPIPE.emp_spipe refresh;
--Validate the pipeLoad
Select * from table(INFORMATION_SCHEMA.VALIDATE_PIPE_LOAD(PIPE_NAME => 'MDB.SPIPE.emp_spipe',START_TIME => DATEADD(MINUTE,-80,CURRENT_TIMESTAMP())));

/* 
--Now changed the delimiter of a file to '|' in file format associated with the snowpipe
{
  "executionState": "RUNNING",
  "pendingFileCount": 0, --Get the count of Passed or failed row count
  "lastIngestedTimestamp": "2026-08-11T05:29:45.615Z",
  "lastIngestedFilePath": "AllEmps/sp_employee_5.csv",
  "notificationChannelName": "arn:aws:sqs:eu-north-1:494952235343:sf-snowpipe-AIDAXGPLTYFHYIBIBMQYE-qvLqq0WA3vt_KmjJzZY62w",
  "numOutstandingMessagesOnChannel": 0,
  "lastReceivedMessageTimestamp": "2026-08-11T05:29:45.024Z",
  "lastForwardedMessageTimestamp": "2026-08-11T05:29:46.065Z",
  "lastPulledFromChannelTimestamp": "2026-08-11T05:33:06.936Z",
  "lastForwardedFilePath": "allff/csv/AllEmps/sp_employee_5.csv",
  "pendingHistoryRefreshJobsCount": 0
}
*/

--Checking the table history in file wise
Select * from table(INFORMATION_SCHEMA.COPY_HISTORY(table_name => 'mdb.public.emp_data' , START_TIME => DATEADD(minutes,-120,CURRENT_TIMESTAMP())));

--IF some one changes the field delimiter in File format object we don't need to pause the Snowpipe. If we change that appropriate it works fine
select CURRENT_TIMESTAMP();


select *
  from table(information_schema.pipe_usage_history(
    date_range_start=>to_timestamp_tz('2017-10-24 12:00:00.000 -0700'),
    date_range_end=>to_timestamp_tz('2017-10-24 12:30:00.000 -0700')));

select *
  from table(information_schema.pipe_usage_history(
    date_range_start=>dateadd(minutes,-120,current_date()),
    date_range_end=>current_date(),
    pipe_name=>'MDB.SPIPE.emp_spipe'));

SELECT * 
FROM SNOWFLAKE.ACCOUNT_USAGE.LOAD_HISTORY
WHERE table_name = 'mdb.public.emp_data'
  AND last_load_time >= DATEADD(minutes,-120, CURRENT_TIMESTAMP())
ORDER BY last_load_time DESC;

SHOW PIPES;
SHOW PIPES like '%employee%';
SHOW PIPES in database mydb;
SHOW PIPES in schema mydb.pipes;
SHOW PIPES like '%employee%' in Database mydb;


SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.LOAD_HISTORY;

SELECT * FROM MDB.INFORMATION_SCHEMA.LOAD_HISTORY;



--Capturing the Errors from the Snowpipe 
Create or replace table MDB.PUBLIC.Error_Pipe as 
Select * from table(INFORMATION_SCHEMA.VALIDATE_PIPE_LOAD(PIPE_NAME => 'MDB.SPIPE.emp_spipe',START_TIME => DATEADD(MINUTE,-200,CURRENT_TIMESTAMP())));

Select * from Error_Pipe;

Select * from Error_Pipe;
--Numeric value '83|Rorie|Darwen|rdarwen2a@shareasale.com|Muan|Marketing' is not recognized

SELECT 
  REGEXP_SUBSTR(ERROR, $$Numeric value '(.*)' is not recognized$$, 1, 1, 'e', 1) AS RAW_DATA
FROM Error_Pipe;

Select * from mdb.public.emp_data;

Create or replace table MDB.PUBLIC.ERROR_DATA as 
SELECT 
  SPLIT_PART(REGEXP_SUBSTR(ERROR, $$Numeric value '(.*)' is not recognized$$, 1, 1, 'e', 1),'|',1) AS ID,
  SPLIT_PART(REGEXP_SUBSTR(ERROR, $$Numeric value '(.*)' is not recognized$$, 1, 1, 'e', 1),'|',2) AS FIRST_NAME,
  SPLIT_PART(REGEXP_SUBSTR(ERROR, $$Numeric value '(.*)' is not recognized$$, 1, 1, 'e', 1),'|',3) AS LAST_NAME,
  SPLIT_PART(REGEXP_SUBSTR(ERROR, $$Numeric value '(.*)' is not recognized$$, 1, 1, 'e', 1),'|',4) AS EMAIL,
  SPLIT_PART(REGEXP_SUBSTR(ERROR, $$Numeric value '(.*)' is not recognized$$, 1, 1, 'e', 1),'|',5) AS LOCATION,
  SPLIT_PART(REGEXP_SUBSTR(ERROR, $$Numeric value '(.*)' is not recognized$$, 1, 1, 'e', 1),'|',6) AS DEPARTMENT,
FROM Error_Pipe;

Select * from MDB.PUBLIC.ERROR_DATA;