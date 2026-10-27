--Import Excel Files Without CSV Hassles  ----          https://www.youtube.com/watch?v=s2AGcGvhTKA&t=648s
use database MDB;
use schema public;
use warehouse compute_wh;
use role accountadmin;
show tables in schema  public;
Select * from EMPS;

CREATE OR REPLACE PROCEDURE EXCEL_LOAD(FILE_PATH VARCHAR, SHEET_NAME VARCHAR, TABLE_NAME VARCHAR)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.9'
PACKAGES = ('snowflake-snowpark-python')
HANDLER = 'main'
AS
$$
from snowflake.snowpark import Session
from snowflake.snowpark.files import SnowflakeFile

def main(session, file_path,sheet_name,table_name):
    parts = table_name.split(".")
    if len(parts) != 3:
        return 'Table Name should be fully qualified name with dbname and schemaname'

    db,schema,table = parts

    table_name = session.sql(f"show tables like '{table}' in schema  {db}.{schema}").collect()

    if(len(table_name) < 1):
        return f"Table {table_name} does not exists"

$$;