--https://www.snowflake.com/en/developers/guides/get-started-snowflake-managed-iceberg-tables/

--For all ICEBERG Tables
CREATE WAREHOUSE iceberg_tutorial_wh
  WAREHOUSE_TYPE = STANDARD
  WAREHOUSE_SIZE = XSMALL;

USE WAREHOUSE iceberg_tutorial_wh;

CREATE OR REPLACE DATABASE iceberg_tutorial_db;
USE DATABASE iceberg_tutorial_db;

CREATE OR REPLACE EXTERNAL VOLUME iceberg_external_volume_1
   STORAGE_LOCATIONS =
      (
         (
            NAME = 'my-s3-us-west-2'
            STORAGE_PROVIDER = 'S3'
            STORAGE_BASE_URL = 's3://icedb/'
            STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::719146259862:role/icedbr'
            STORAGE_AWS_EXTERNAL_ID = 'iceberg_table_external_id'
         )
      )
      ALLOW_WRITES = TRUE;

Show external volumes;
describe external volume iceberg_external_volume_1;

/*
{"NAME":"my-s3-us-west-2","STORAGE_PROVIDER":"S3","STORAGE_BASE_URL":"s3://icedb/","STORAGE_ALLOWED_LOCATIONS":["s3://icedb/*"],"STORAGE_AWS_ROLE_ARN":"arn:aws:iam::719146259862:role/icedbr","STORAGE_AWS_IAM_USER_ARN":"arn:aws:iam::738540809744:user/i2652000-s","STORAGE_AWS_EXTERNAL_ID":"iceberg_table_external_id","ENCRYPTION_TYPE":"NONE","ENCRYPTION_KMS_KEY_ID":""}
 */
--Setting the table level Catalog and External Volume at table Level
 CREATE OR REPLACE ICEBERG TABLE customer_iceberg (
    c_custkey INTEGER,
    c_name STRING,
    c_address STRING,
    c_nationkey INTEGER,
    c_phone STRING,
    c_acctbal INTEGER,
    c_mktsegment STRING,
    c_comment STRING
)
    CATALOG = 'SNOWFLAKE'
    EXTERNAL_VOLUME = 'iceberg_external_volume_1'
    BASE_LOCATION = 'customer_iceberg';

describe table customer_iceberg;

--Setting up the Catalog and External Volume at Database level
ALTER DATABASE iceberg_tutorial_db SET CATALOG = 'SNOWFLAKE';
ALTER DATABASE iceberg_tutorial_db SET EXTERNAL_VOLUME = 'iceberg_external_volume_1';


SHOW PARAMETERS IN DATABASE ;

CREATE OR REPLACE ICEBERG TABLE nation_iceberg (
  n_nationkey INTEGER,
  n_name STRING
)
  BASE_LOCATION = 'nation_iceberg'
  AS SELECT
    N_NATIONKEY,
    N_NAME
  FROM snowflake_sample_data.tpch_sf1.nation;


  INSERT INTO customer_iceberg
  SELECT * FROM snowflake_sample_data.tpch_sf1.customer;

  SELECT
    c.c_name AS customer_name,
    c.c_mktsegment AS market_segment,
    n.n_name AS nation
  FROM customer_iceberg c
  INNER JOIN nation_iceberg n
    ON c.c_nationkey = n.n_nationkey
  LIMIT 15;

  --Deletion of Rows from ICEBERG Tables
  DELETE FROM customer_iceberg WHERE c_mktsegment = 'AUTOMOBILE';

  SELECT SYSTEM$GET_ICEBERG_TABLE_INFORMATION('ICEBERG_TUTORIAL_DB.PUBLIC.CUSTOMER_ICEBERG');



  create or replace schema PUBLIC;

create or replace ICEBERG TABLE CUSTOMER_ICEBERG (
	C_CUSTKEY INT,
	C_NAME STRING,
	C_ADDRESS STRING,
	C_NATIONKEY INT,
	C_PHONE STRING,
	C_ACCTBAL INT,
	C_MKTSEGMENT STRING,
	C_COMMENT STRING
)
 EXTERNAL_VOLUME = 'ICEBERG_EXTERNAL_VOLUME_1'
 ICEBERG_VERSION = 2
 CATALOG = 'SNOWFLAKE'
 BASE_LOCATION = 'customer_iceberg/';
create or replace ICEBERG TABLE NATION_ICEBERG (
	N_NATIONKEY INT,
	N_NAME STRING
)
 EXTERNAL_VOLUME = 'ICEBERG_EXTERNAL_VOLUME_1'
 ICEBERG_VERSION = 2
 CATALOG = 'SNOWFLAKE'
 BASE_LOCATION = 'nation_iceberg/';



 --https://docs.snowflake.com/en/user-guide/tables-iceberg-internal-storage

 CREATE ICEBERG TABLE my_iceberg_table_defaults (col1 int)
  CATALOG = SNOWFLAKE
  EXTERNAL_VOLUME = SNOWFLAKE_MANAGED;

  show tables;