use Database MDB;

show storage integrations;

show schemas;

describe integration ES3;

use schema E_STG;

create or replace stage Ext_tab
storage_integration = ES3
url = 's3://allff/csv/empExternalTabs/'
file_format = (format_name = MDB.FFMT.CSVF);

LIST @MDB.E_STG.Ext_tab;

show stages;

use schema FFMT;

show file formats;

describe file format CSVF;

use schema public;

create or replace External table emp_data
with location = @MDB.E_STG.Ext_tab
file_format = (type = csv); --It stored the data into Variant Format correct

describe table emp_data;

--drop table emp_data;

show tables;

Select * from emp_data;

Select  value:c1::string as F_Name,
        value:c2::string as L_Name,
        value:c3::string as EMAIL,
        value:c4::string as Addresses,
        value:c5::string as City,
        DATE(value:c6::string) as DOB, from emp_data;

--Creating the External Tables Now using the cloumns as well as Type casting

Create or replace external table emp_ext_table
(
    F_NAME varchar as (value:c1::string),
    L_NAME varchar as (value:c2::string),
    EMAIL varchar as (value:c3::string),
    Loc varchar as (value:c4::string),
    City varchar as (value:c5::string),
    DOB DATE as (DATE(value:c6::string))
)
with Location = @MDB.E_STG.Ext_tab
file_format = (format_name = MDB.FFMT.CSVF);

select * from emp_ext_table;  

describe table emp_ext_table;

/*************** Lecture: Why external tables.(Get metadata information) *****************/

select * from table(information_schema.external_table_files(TABLE_NAME=>'emp_ext_table'));

select * from table(information_schema.external_table_file_registration_history(TABLE_NAME=>'emp_ext_table'));

--After uploading the Files into S3 I ran the below command
Alter external table emp_ext_table refresh;

--We can able to refresh the External tables automatically by adding the 
auto_refresh=true; --while creating the External tables

create or replace external table emp_ext_table
		(
		file_name_part varchar AS SUBSTR(metadata$filename,5,11),
		first_name string as  (value:c1::string), 
		last_name string(20) as ( value:c2::string), 
		email string as (value:c3::string))
		PARTITION BY (file_name_part)
		WITH LOCATION =  @control_db.external_stages.my_s3_stage
		FILE_FORMAT = (TYPE = CSV)
		auto_refresh=true;