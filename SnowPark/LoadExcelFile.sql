create database SPARK;
use database SPARK;

List @excel_stg; --named stage --Internal stage

--creating the log table
CREATE OR REPLACE TABLE EXCEL_LOAD_LOGS (
ID INT IDENTITY (1,1) ORDER,
FILE_NAME STRING,
TARGET_TABLE STRING,
STATUS STRING,
ERROR_MESSAGE STRING,
ROW_COUNT NUMBER,
ETL_LOAD_TIME TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

Select * from EXCEL_LOAD_LOGS;
Select * from EXCEL_LOADS;

--Procedure to Load Excel file to Table

CREATE OR REPLACE PROCEDURE LOAD_EXCEL_FILE_TO_TABLE(file_name STRING,target_table STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-snowpark-python','pandas','openpyxl')
HANDLER = 'main'
AS
$$
import pandas as pd
from  snowflake.snowpark import Session
import traceback

def main(session: Session, file_name : str, target_table: str) -> str:
    try:

        file_path = f"@excel_stg/{file_name}"
        session.file.get(file_path,'/tmp')

        local_path = f"/tmp/{file_name}"

        panda_df = pd.read_excel(local_path)
        snow_df = session.create_dataframe(panda_df)

        try:
            snow_df.write.save_as_table(target_table,mode = "overwrite")
        
            row_count = len(panda_df)
            log_status(session,file_name,target_table,"SUCCESS",None,row_count)
            return f"{row_count} into table '{target_table}' loaded successfully."

        except Exception as e:
           log_status(session,file_name,target_table,"Failed",str(e),0) 
           return f"Failed to write table: {e}"

    except Exception as e:
        log_status(session,file_name,target_table,"Failed",traceback.format_exc()[:500],0)
        return f"Procedure could not Executed and Error: {str(e)}"

def log_status(session,file_name,target_table,status,error_message = None,row_count = 0):
        try:
            insert_stmt = f"""INSERT INTO EXCEL_LOAD_LOGS (FILE_NAME,TARGET_TABLE,STATUS, ERROR_MESSAGE,ROW_COUNT,ETL_LOAD_TIME)
                            VALUES ('{file_name.replace("'", "''")}','{target_table.replace("'", "''")}','{status.replace("'", "''")}',
                            {'NULL' if error_message is None else "'" + error_message.replace("'", "''") + "'"},{row_count},CURRENT_TIMESTAMP())"""

            session.sql(insert_stmt).collect()
        except Exception as log_err:
            print('log_insert Failed:',log_err)
$$;

CALL LOAD_EXCEL_FILE_TO_TABLE('employee data.xlsx','SPARK.PUBLIC.EXCEL_LOADS');

--==================================================================================================================
CREATE OR REPLACE PROCEDURE LOAD_EXCEL_FILES(file_name STRING, target_table STRING) 
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.10'
PACKAGES = ('snowflake-snowpark-python', 'pandas', 'openpyxl')
HANDLER = 'main'   
AS
$$
import pandas as pd
from snowflake.snowpark import Session
import traceback 

def main(session: Session, file_name: str, target_table: str) -> str:
    try:
        # Step 2: Get file from stage
        file_path = f"@excel_stg/{file_name}"  
        session.file.get(file_path, '/tmp')  # download file from stage to local temp folder
        local_path = f"/tmp/{file_name}" 

        # Step 3: Read Excel into pandas dataframe
        panda_df = pd.read_excel(local_path)

        # Step 4: Convert pandas dataframe to Snowpark dataframe
        snow_df = session.create_dataframe(panda_df)

        try:
            # Step 5: Write dataframe to Snowflake table
            snow_df.write.save_as_table(target_table, mode="overwrite")

            # Step 6: Log success with row count
            row_count = len(panda_df)
            log_status(session, file_name, target_table, "SUCCESS", None, row_count)
            return f"{row_count} rows into table '{target_table}' Loaded Successfully"

        except Exception as e:
            # Step 7: Log failure if table write fails
            log_status(session, file_name, target_table, "FAILED", str(e), 0)
            return f"Failed to write table: {e}"

    except Exception as e:
        # Step 8: Log top-level failure
        log_status(session, file_name, target_table, "FAILED", traceback.format_exc()[:1500], 0)
        return f"Procedure could not execute. Error: {str(e)}"


def log_status(session, file_name, target_table, status, error_message=None, row_count=0):
    try:
        insert_stmt = f"""
            INSERT INTO EXCEL_LOAD_LOGS (
                FILE_NAME, TARGET_TABLE, STATUS, ERROR_MESSAGE, ROW_COUNT, ETL_LOAD_TIME
            )
            VALUES (
                '{file_name}',
                '{target_table}',
                '{status}',
                {'NULL' if error_message is None else "'" + error_message.replace("'", "''") + "'"},
                {row_count},
                CURRENT_TIMESTAMP()
            )
        """
        session.sql(insert_stmt).collect()
    except Exception as log_err:
        print("Log insert failed:", log_err)
$$;

CALL LOAD_EXCEL_FILES('employee data.xlsx','SPARK.PUBLIC.EXCEL_LOADS');