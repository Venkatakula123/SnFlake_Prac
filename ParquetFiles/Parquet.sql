--Handling the Parquet files Data in Snowflake
select current_schema();
use database MDB;
use schema e_stg;

create or replace file format MDB.FFMT.Parquet_FF type = Parquet;
describe file format MDB.FFMT.Parquet_FF;

create or replace stage MDB.E_STG.paruet_stg 
storage_integration = es3
url = 's3://allff/parquet/';
describe stage paruet_stg;
list @paruet_stg;

Select $1 from @paruet_stg/sales_items_data.parquet (FILE_FORMAT => MDB.FFMT.Parquet_FF);

Select  $1:"__index_level_0__"::NUMBER AS INDEX,
        $1:"cat_id"::varchar,
        $1:"d"::varchar,
        $1:"date",
        $1:"dept_id",
        $1:"id",
        $1:"item_id", 
        $1:"state_id",
        $1:"store_id",
        $1:"value"  from @paruet_stg/sales_items_data.parquet (FILE_FORMAT => MDB.FFMT.Parquet_FF);

Select  $1:"__index_level_0__"::NUMBER AS INDEX,
        $1:"cat_id"::varchar,
        $1:"d"::varchar,
        DATE($1:"date"::int) as DOB,
        $1:"dept_id"::varchar as deptid,
        $1:"id"::varchar as id,
        $1:"item_id"::varchar as ITEMID, 
        $1:"state_id"::varchar as stateid,
        $1:"store_id"::varchar as storeid,
        $1:"value"::varchar as val,
        METADATA$FILENAME as F_Name,
        METADATA$FILE_ROW_NUMBER as ROWNUMBER,
        to_timestamp_ntz(current_timestamp)  from @paruet_stg/sales_items_data.parquet (FILE_FORMAT => MDB.FFMT.Parquet_FF);