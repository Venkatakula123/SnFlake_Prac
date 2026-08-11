--Semi-Structured Data
CREATE OR REPLACE FILE FORMAT MDB.FFMT.json_format
    TYPE = JSON;

Show storage integrations;

Create or replace stage MDB.E_STG.j_stg storage_integration = es3
url = 's3://allff/json/';

describe stage j_stg;

List @j_stg;

Select $1 from @j_stg/pets_data.json;

Select  $1:Name::VARCHAR as NAME,
        $1:Gender::varchar as GENDER from @j_stg/pets_data.json
        (FILE_FORMAT =>  MDB.FFMT.json_format);

--Trying to get the metadata of a file which was stored in the External stage
SELECT * FROM TABLE(
                    INFER_SCHEMA(LOCATION=>'@j_stg' ,
                  FILE_FORMAT => 'MDB.FFMT.json_format' ,
                  FILES => ('socialmedia.json')
                )
            );

CREATE OR REPLACE TRANSIENT TABLE public.SOCIAL_MEDIA USING TEMPLATE 
(
    SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*)) FROM TABLE(
    INFER_SCHEMA(LOCATION=>'@j_stg'
                 , FILE_FORMAT => 'MDB.FFMT.json_format'
                 , FILES => ('socialmedia.json')
                )
            )
        );
-- The above won't work exactly
describe table public.SOCIAL_MEDIA;

CREATE OR REPLACE TABLE MDB.public.PETS_DATA_JSON_RAW(raw_file variant); --Before loading the json data into the Table

COPY INTO MDB.PUBLIC.PETS_DATA_JSON_RAW from @MDB.E_STG.j_stg
    FILE_FORMAT = (FORMAT_NAME = MDB.FFMT.json_format)
    FILES = ('pets_data.json'); --Moving the data into the table

Select * from MDB.PUBLIC.PETS_DATA_JSON_RAW;

--Querying the JSON Data now from the table stored in the raw_file Varient data type columns in a table. That's why we are giving the raw_file as a source of column
Select  raw_file:Address:City as CITY,
        raw_file:Address:"House Number" as HNO,
        raw_file:Address:State as STATE,
        raw_file:DOB as DOB, 
        raw_file:Gender as GENDER,
        raw_file:Name as NAME,
        raw_file:Pets[0] as PET_1,
        raw_file:Pets[1] as PET_2,
        raw_file:Phone:Mobile as MOBILE,
        raw_file:Phone:Work as WORK  from MDB.PUBLIC.PETS_DATA_JSON_RAW;

Select  raw_file:Address:City as CITY,
        raw_file:Address:"House Number" as HNO,
        raw_file:Address:State as STATE,
        raw_file:DOB as DOB, 
        raw_file:Gender as GENDER,
        raw_file:Name as NAME,
        raw_file:Pets[0] as PETS,
        raw_file:Phone:Mobile::NUMBER as MOBILE,
        raw_file:Phone:Work::NUMBER as WORK  from MDB.PUBLIC.PETS_DATA_JSON_RAW
UNION ALL
Select  raw_file:Address:City as CITY,
        raw_file:Address:"House Number" as HNO,
        raw_file:Address:State as STATE,
        raw_file:DOB as DOB, 
        raw_file:Gender as GENDER,
        raw_file:Name as NAME,
        raw_file:Pets[0] as PETS,
        raw_file:Phone:Mobile::NUMBER as MOBILE,
        raw_file:Phone:Work::NUMBER as WORK  from MDB.PUBLIC.PETS_DATA_JSON_RAW;

--Using Flattern Function 
Select  raw_file:Address:City as CITY,
        raw_file:Address:"House Number" as HNO,
        raw_file:Address:State as STATE,
        raw_file:DOB as DOB, 
        f1.value::string as Pets,
        raw_file:Gender as GENDER,
        raw_file:Name as NAME,
        raw_file:Phone:Mobile as MOBILE,
        raw_file:Phone:Work as WORK  from MDB.PUBLIC.PETS_DATA_JSON_RAW,
        table(flatten(raw_file:Pets)) f1; --Using the flatten Function in the table function

Select  raw_file:Address:City as CITY,
        raw_file:Address:"House Number" as HNO,
        raw_file:Address:State as STATE,
        raw_file:DOB as DOB, 
        f1.value::string as Pets,
        raw_file:Gender as GENDER,
        raw_file:Name as NAME,
        raw_file:Phone:Mobile::NUMBER as MOBILE,
        raw_file:Phone:Work::NUMBER as WORK  from MDB.PUBLIC.PETS_DATA_JSON_RAW,
        lateral flatten( input => raw_file:Pets) f1; --This is the lateral flatten function