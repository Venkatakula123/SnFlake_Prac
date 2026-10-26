use database MYDB;

show tables;
show schemas;
CREATE OR REPLACE DATABASE MDB;
USE DATABASE MDB;
Select  current_database();

CREATE OR REPLACE TABLE MDB.PUBLIC.LOAN_PAYMENT (
  "Loan_ID" STRING,
  "loan_status" STRING,
  "Principal" STRING,
  "terms" STRING,
  "effective_date" STRING,
  "due_date" STRING,
  "paid_off_time" STRING,
  "past_due_days" STRING,
  "age" STRING,
  "education" STRING,
  "Gender" STRING
 );


 COPY INTO MDB.PUBLIC.LOAN_PAYMENT from s3://bucketsnowflakes3/Loan_payments_data.csv
 file_format = (type = csv skip_header = 1 field_delimiter = ','); --01c5f2b3-0002-87e1-001b-fc470078f7f2

 Select * from MDB.PUBLIC.LOAN_PAYMENT;

 Select * from table(RESULT_SCAN('01c5f2b3-0002-87e1-001b-fc470078f7f2'));

 Select * from table(result_scan(last_query_id()));

 --creating the schema 
 CREATE OR REPLACE SCHEMA MDB.e_stg;

--Publicly access stage creating 
use schema e_stg;
create or replace stage mdb.e_stg.ps3
url = 's3://bucketsnowflakes3';

--validating the stage to see the files in the Stage
list @mdb.e_stg.ps3;

--viewing the data from the file 
Select $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14 from @mdb.e_stg.ps3/Loan_payments_data.csv;

--Giving Aliases to the columns
Select $1 as LOAN_ID,$2 AS LOAN_STATUS,$3,$4,$5,$6,$7,$8,$9,$10,$11 AS SEX from @mdb.e_stg.ps3/Loan_payments_data.csv;

/*Select $1 as LOAN_ID,$2 AS LOAN_STATUS,$3,$4,$5,$6,$7,$8,$9,$10,$11 AS SEX from @mdb.e_stg.ps3(
file_format => (type = csv skip_header = 1 field_delimiter = ',')
files => ('Loan_payments_data.csv')); */

/* SELECT 
    $1  AS LOAN_ID,
    $2  AS LOAN_STATUS,
    $3  AS PRINCIPAL,
    $4  AS TERMS,
    $5  AS EFFECTIVE_DATE,
    $6  AS DUE_DATE,
    $7  AS PAID_OFF_TIME,
    $8  AS PAST_DUE_DAYS,
    $9  AS AGE,
    $10 AS EDUCATION,
    $11 AS SEX
FROM @mdb.e_stg.ps3
(
    FILE_FORMAT = (TYPE = CSV SKIP_HEADER = 1 FIELD_DELIMITER = ','),
    FILES       = ('Loan_payments_data.csv')
) */

// Transforming Data while loading. and  Case 2: load only required fields
CREATE OR REPLACE TABLE MDB.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT
    );

list @mdb.e_stg.ps3;

Select  $1,$2,$3,$4,$5,$6 from @mdb.e_stg.ps3/OrderDetails.csv;
/* COPY into MDB.PUBLIC.ORDERS_EX(ORDER_ID,AMOUNT) from (Select $1 as "ORDER ID", $2 as AMOUNT @mdb.e_stg.ps3)
file_format = (type = csv field_delimiter = ',' skip_header = 1)
files = ('OrderDetails.csv'); */

COPY INTO MDB.PUBLIC.ORDERS_EX from (Select $1,$2 from @mdb.e_stg.ps3)
file_format = (type = csv field_delimiter = ',' skip_header = 1)
files = ('OrderDetails.csv'); 

Select * from MDB.PUBLIC.ORDERS_EX;

CREATE OR REPLACE TABLE MDB.PUBLIC.ORDERS_EX_1 (
    ORDER_ID VARCHAR(30),
    PROFIT INT,
	AMOUNT INT,    
    CAT_SUBSTR VARCHAR(5),
    CAT_CONCAT VARCHAR(60),
	PFT_OR_LOSS VARCHAR(10)
  );

COPY INTO MDB.PUBLIC.ORDERS_EX_1 FROM (Select   $1,
                                                $3,
                                                $2,
                                                SUBSTR($5,1,5),
                                                CONCAT($5,$6),
                                                CASE    WHEN $3 > 0 THEN 'PROFIT'
                                                        Else 'LOSS' END from @mdb.e_stg.ps3)
file_format = (type = csv skip_header = 1 field_delimiter = ',')
files = ('OrderDetails.csv');

Select * from MDB.PUBLIC.ORDERS_EX_1;

create sequence sq1;
select sq1.nextVal;

CREATE OR REPLACE TABLE MDB.PUBLIC.LOAN_PAYMENT (
  "SEQ_ID" number default sq1.nextval,
  "Loan_ID" STRING,
  "loan_status" STRING,
  "Principal" STRING,
  "terms" STRING,
  "effective_date" STRING,
  "due_date" STRING,
  "paid_off_time" STRING,
  "past_due_days" STRING,
  "age" STRING,
  "education" STRING,
  "Gender" STRING
 );

 LIST @mdb.e_stg.ps3;

 Select  $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11 from @mdb.e_stg.ps3/Loan_payments_data.csv;

 COPY INTO MDB.PUBLIC.LOAN_PAYMENT("Loan_ID",
                                    "loan_status",
                                    "Principal",
                                    "terms",
                                    "effective_date",
                                    "due_date" ,
                                    "paid_off_time" ,
                                    "past_due_days" ,
                                    "age" ,
                                    "education" ,
                                    "Gender" ) 
                                    FROM 
                                    (SELECT  $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11 from @mdb.e_stg.ps3)
File_Format = (type = csv field_delimiter = ',' skip_header = 1)
files = ('Loan_payments_data.csv');

Select * from MDB.PUBLIC.LOAN_PAYMENT;

Select max("SEQ_ID") from MDB.PUBLIC.LOAN_PAYMENT;

CREATE OR REPLACE TABLE MDB.PUBLIC.LOAN_PAYMENT_1 (
  "SEQ_ID" number  autoincrement start 1000 increment 1,
  "Loan_ID" STRING,
  "loan_status" STRING,
  "Principal" STRING,
  "terms" STRING,
  "effective_date" STRING,
  "due_date" STRING,
  "paid_off_time" STRING,
  "past_due_days" STRING,
  "age" STRING,
  "education" STRING,
  "Gender" STRING
 );

--drop table MDB.PUBLIC.LOAN_PAYMENT_1;
 COPY INTO MDB.PUBLIC.LOAN_PAYMENT_1("Loan_ID",
                                    "loan_status",
                                    "Principal",
                                    "terms",
                                    "effective_date",
                                    "due_date" ,
                                    "paid_off_time" ,
                                    "past_due_days" ,
                                    "age" ,
                                    "education" ,
                                    "Gender" ) 
                                    FROM @mdb.e_stg.ps3
file_format = (type = csv skip_header = 1 field_delimiter = ',')
files = ('Loan_payments_data.csv');

Select * from MDB.PUBLIC.LOAN_PAYMENT_1;

describe storage integration S3_INT;

select current_schema();

/*create or replace storgae integration  es3
type = external_stage
storage_provider = 's3'
enabled = true
storage_aws_role_arn = 'arn:aws:iam::719146259862:role/snFlake'
storage_locations = ('s3://allff/','s3://snowflakeff/'); */

CREATE OR REPLACE STORAGE INTEGRATION es3
    TYPE                      = EXTERNAL_STAGE
    STORAGE_PROVIDER          = S3
    ENABLED                   = TRUE
    STORAGE_AWS_ROLE_ARN      = 'arn:aws:iam::719146259862:role/snFlake'
    STORAGE_ALLOWED_LOCATIONS = ('s3://allff/', 's3://snowflakeff/');

describe integration es3;

create or replace stage estg3 storage_integration = es3
url = 's3://allff/csv/';

use schema e_stg;
LIST @estg3;

--Using INFER SCHEMA to get the Schema from the file which are already available in s3
create or replace schema FFmt;
use schema FFMT;
create or replace file format mdb.FFMT.csvPf
type = csv
field_delimiter = ','
parse_header = true;
--drop file format mdb.FFMt.csvPf;
--drop file format csvPf;

Alter file format mdb.ffmt.csvpf set skip_header = 1;
Alter file format mdb.ffmt.csvpf set parse_header = true;

Alter file format mdb.ffmt.csvpf set FIELD_OPTIONALLY_ENCLOSED_BY = '"';

Alter file format mdb.ffmt.csvpf set  null_if = ('NULL','null');
Alter file format mdb.ffmt.csvpf set empty_field_as_null = true;

describe file format mdb.ffmt.csvpf;
create or replace file format mdb.ffmt.csvpf_1 type = csv;
describe file format mdb.ffmt.csvpf_1;

use database mdb;
use schema e_stg;
Select  $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14 from @estg3/loan_payments_data.csv;

Select  $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14 from @estg3/streaming_data.csv;
Select * from TABLE(INFER_SCHEMA(LOCATION => '@mdb.e_stg.estg3',
                                FILE_FORMAT => 'MDB.FFMT.CSVPF',
                                FILES => ('streaming_data.csv')));
describe file format MDB.FFMT.CSVPF;

Select * from TABLE(INFER_SCHEMA(LOCATION => '@mdb.e_stg.estg3',
                                FILE_FORMAT => 'MDB.FFMT.CSVPF',
                                FILES => ('loan_payments_data.csv'))); --Coulmn Header contains null values

--creating the table using the INFER_SCHEMA
create or replace table MDB.public.Movies using template(
Select ARRAY_AGG(OBJECT_CONSTRUCT(*))  from TABLE(INFER_SCHEMA(LOCATION => '@mdb.e_stg.estg3',
                                FILE_FORMAT => 'MDB.FFMT.CSVPF',
                                FILES => ('streaming_data.csv'))));

Select * from MDB.public.Movies;
describe table MDB.public.Movies;

create file format MDB.FFMT.csvf clone MDB.FFMT.csvpf;
describe file format MDB.FFMT.csvf;
alter file format  MDB.FFMT.csvf set skip_header = 1;
alter file format  MDB.FFMT.csvf set  parse_header = false;
LIST @mdb.e_stg.estg3;
COPY into MDB.public.Movies from @MDB.E_STG.estg3 
file_format = (format_name = MDB.FFMT.csvf )
files = ('streaming_data.csv');

Show tables;

--COPY Options VALIDATION_MODE 
-- Case 1: Files without errors
-- Create Stage Object
--1.VALIDATION_MODE
------------------
--// Create table
CREATE TABLE  MDB.PUBLIC.TBL_ORDERS (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));

Select * from MDB.PUBLIC.TBL_ORDERS ;

use schema e_stg;

show stages;

create or replace stage stgopt url = 's3://snowflakebucket-copyoption/size/';

List @stgopt;

Select  $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14 from @stgopt/Orders.csv;

Select  $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14 from @stgopt/Orders2.csv;

COPY into MDB.PUBLIC.TBL_ORDERS from @stgopt/Orders.csv
FILE_FORMAT = (FORMAT_NAME = MDB.FFMT.csvf)
--files = 'Orders.csv'
VALIDATION_MODE = RETURN_ERRORS;

COPY into MDB.PUBLIC.TBL_ORDERS from @stgopt/Orders2.csv
FILE_FORMAT = (FORMAT_NAME = MDB.FFMT.csvf)
--files = 'Orders.csv'
VALIDATION_MODE = RETURN_ERRORS;

COPY into MDB.PUBLIC.TBL_ORDERS from @stgopt/Orders.csv
FILE_FORMAT = (FORMAT_NAME = MDB.FFMT.csvf)
--files = 'Orders.csv'
VALIDATION_MODE = RETURN_10_ROWS;

Select current_schema();

Create or replace stage stgfail url = 's3://snowflakebucket-copyoption/returnfailed/';

List @stgfail;

COPY INTO MDB.PUBLIC.TBL_ORDERS from @stgfail/OrderDetails_error.csv
file_format = (format_name = MDB.FFMT.csvf)
VALIDATION_MODE = RETURN_ERRORS;


COPY INTO MDB.PUBLIC.TBL_ORDERS from @stgfail/OrderDetails_error2 - Copy.csv
file_format = (format_name = MDB.FFMT.csvf)
VALIDATION_MODE = RETURN_ERRORS;

use database MDB;
use schema e_stg;
show stages like '%stg%' in DATABASE MDB;

COPY INTO MDB.PUBLIC.TBL_ORDERS FROM @stgfail
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    VALIDATION_MODE = RETURN_ERRORS;  
--RETURN_ERRORS ==> Gives the all Errors from the one or all files in the stage Area in a Tabular Format.

COPY INTO MDB.PUBLIC.TBL_ORDERS FROM @stgfail
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='OrderDetails_error2 - Copy.csv'
    VALIDATION_MODE = RETURN_10_ROWS;  

COPY INTO MDB.PUBLIC.TBL_ORDERS FROM @stgfail
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='OrderDetails_error.csv'
    VALIDATION_MODE = RETURN_10_ROWS;  

COPY INTO MDB.PUBLIC.TBL_ORDERS FROM @stgfail
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    VALIDATION_MODE = RETURN_10_ROWS; 
    
COPY INTO MDB.PUBLIC.TBL_ORDERS FROM @stgfail
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    VALIDATION_MODE = RETURN_ERRORS;

COPY INTO MDB.PUBLIC.TBL_ORDERS FROM @stgfail
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    RETURN_FAILED_ONLY = TRUE;   

--ON_ERROR
COPY INTO MDB.PUBLIC.TBL_ORDERS FROM @stgfail
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*';

Select * from MDB.PUBLIC.TBL_ORDERS;
--TRUNCATE TABLE MDB.PUBLIC.TBL_ORDERS;

COPY INTO MDB.PUBLIC.TBL_ORDERS FROM @stgfail
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    ON_ERROR = CONTINUE;

COPY INTO MDB.PUBLIC.TBL_ORDERS FROM @stgfail
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    ON_ERROR = SKIP_FILE;

COPY INTO MDB.PUBLIC.TBL_ORDERS FROM @stgfail
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    ON_ERROR = ABORT_STATEMENT;

COPY INTO MDB.PUBLIC.TBL_ORDERS FROM @stgfail
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    ON_ERROR = SKIP_FILE_1;

COPY INTO MDB.PUBLIC.TBL_ORDERS FROM @stgfail
    file_format= (type = csv field_delimiter=',' skip_header=1)
    pattern='.*Order.*'
    ON_ERROR = SKIP_FILE_1%;

--FORCE 

--TRUNCATECOLUMNS

--SIZE_LIMIT 
COPY into MDB.PUBLIC.TBL_ORDERS from @stgopt/Orders.csv
FILE_FORMAT = (FORMAT_NAME = MDB.FFMT.csvf)
--files = 'Orders.csv'
--VALIDATION_MODE = RETURN_10_ROWS;
SIZE_LIMIT = 5;


--PURGE

--LOAD_UNCERTAIN_FILES

use schema E_STG;
show stages;

LIst @STGFAIL;

CREATE OR REPLACE TABLE  MDB.PUBLIC.ORDERS_FAIL (
    ORDER_ID VARCHAR(30),
    AMOUNT VARCHAR(30),
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));

COPY INTO MDB.PUBLIC.ORDERS_FAIL from @STGFAIL
File_Format = (format_name = MDB.FFMT.csvf)
pattern = '.*Order.*'
validation_mode = RETURN_ERRORS;

create or replace table MDB.PUBLIC.COPY_ERROR as 
Select * from table(result_scan('01c650f8-0302-b7fb-001b-fc47009310b6')); 

Select * from MDB.PUBLIC.COPY_ERROR;
