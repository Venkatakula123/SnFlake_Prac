use database MDB;
use schema SPROC;

CREATE OR REPLACE TABLE MDB.public.employees_SP (
EMP_ID number,
FIRST_NAME STRING,
LAST_NAME STRING,
EMAIL STRING,
PHONE STRING,
DEPARTMENT STRING,
DESIGNATION STRING,
LOCATION STRING,
JOIN_DATE DATE,
SALARY NUMBER);

List @SPARK.PUBLIC.EXCEL_STG;

--Creating the Snowpark SP to ingest the data into Snowflake table
select Current_schema();

Show procedures;

create or replace procedure excel_Park(file_path string,sheet_name string, table_name string)
returns string
language python
runtime_version = '3.10'
PACKAGES = ('snowflake-snowpark-python')
handler = 'main'
as
$$
from snowflake.snowpark.files import SnowflakeFile
from snowflake.snowpark import Session 

def main(session, file_path,sheet_name,table_name): ##tables name should be fully qualified name
    parts = table_name.split(".")
            
    if len(parts) != 3:
        return "Tables name must be Fully qualified name only"
               
    db,schema,table = parts

    chk_table = session.sql(f"SHOW TABLES LIKE '{table}' IN SCHEMA {db}.{schema}").collect()

    if (len(chk_table) > 1 ):
        return "Table name {chk_table} doesnot exists"
                    
    return f"Data from '{file_path}' inserted into '{table_name}' success "
$$;

call excel_Park(build_scoped_file_url(@SPARK.PUBLIC.EXCEL_STG,'Employees_SP.xlsx'),'Sheet1','MDB.public.employees_SP');

create or replace procedure excel_Park(file_path string,sheet_name string, table_name string)
returns string
language python
runtime_version = '3.10'
PACKAGES = ('snowflake-snowpark-python','openpyxl')
handler = 'main'
as
$$
from snowflake.snowpark.files import SnowflakeFile
from snowflake.snowpark import Session 
from snowflake.snowpark.types import StringType,StructType,StructField
from openpyxl import load_workbook

def main(session, file_path,sheet_name,table_name): ##tables name should be fully qualified name
    parts = table_name.split(".")
            
    if len(parts) != 3:
        return "Tables name must be Fully qualified name only"
               
    db,schema,table = parts

    chk_table = session.sql(f"SHOW TABLES LIKE '{table}' IN SCHEMA {db}.{schema}").collect()

    if (len(chk_table) > 1 ):
        return "Table name {chk_table} doesnot exists"
       
    #define the workbook 
    with SnowflakeFile.open(file_path, 'rb' ) as f: 
        wb = load_workbook (f, data_only=True)

        if sheet_name not in wb.sheetname:
            raise ValueError(f"Sheet ''{sheet_name}'' not found in workbook")

        ws = wb[sheet_name]
        rows = list(ws.)

# check the if sheet_name not in wb. sheetnames : raise ValueError (f"Sheet ' ' {sheet_name} '' not found in workbook. ")   

    return f"Data from '{file_path}' inserted into '{table_name}' success "
$$;

call excel_Park(build_scoped_file_url(@SPARK.PUBLIC.EXCEL_STG,'Employees_SP.xlsx'),'Sheet1','MDB.public.employees_SP');