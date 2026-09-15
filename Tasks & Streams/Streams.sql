--create or replace Database MDB;
use Database MDB;
use schema public;

CREATE OR REPLACE TABLE public.SRC_CUSTOMER (
    CUSTOMER_ID NUMBER,
    CUSTOMER_NAME VARCHAR,
    CITY VARCHAR,
    EMAIL VARCHAR,
    UPDATED_AT TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO public.SRC_CUSTOMER
    (CUSTOMER_ID, CUSTOMER_NAME, CITY, EMAIL)
VALUES
    (101, 'Ravi',   'Hyderabad', 'ravi@gmail.com'),
    (102, 'Kumar',  'Chennai',   'kumar@gmail.com'),
    (103, 'Ramesh', 'Bangalore', 'ramesh@gmail.com');

CREATE OR REPLACE TABLE public.TGT_CUSTOMER (
    CUSTOMER_ID NUMBER,
    CUSTOMER_NAME VARCHAR,
    CITY VARCHAR,
    EMAIL VARCHAR,
    UPDATED_AT TIMESTAMP
); --Target Table

create or replace schema strm;
use schema strm;
Select current_schema();

create or replace stream strm_1 on table public.SRC_CUSTOMER;
show streams;

Select * from strm_1;

create or replace table public.raw_applicant_staging (  id number, 
                                                        first_name varchar, 
                                                        last_name varchar, 
                                                        sex varchar, 
                                                        ethinicity varchar, 
                                                        ssn varchar, 
                                                        street_address varchar, 
                                                        education_level varchar, 
                                                        years_of_experience number, 
                                                        job_id number);
                                                
create or replace table public.job_details (    job_id number, 
                                                name varchar , 
                                                city varchar, 
                                                state varchar, 
                                                education_level varchar);

insert into public.job_details values   (10, 'Painter ', 'Raleigh', 'NC', 'High School' ),
                                        (20, 'Software Engineer', 'Raleigh', 'NC' , 'Masters'),
                                        (30, 'Data Architect', 'Raleigh', 'NC', 'Undergrad' ),
                                        (40, 'Vice President', 'Raleigh', 'NC', 'Masters'),
                                        (50, 'Associate', 'Raleigh', 'NC', 'Masters') ;

create or replace table public.candidates ( id number , 
                                            first_name varchar, 
                                            Last_name varchar, 
                                            sex varchar, 
                                            ethinicity varchar, 
                                            ssn varchar, 
                                            street_address varchar, 
                                            candidate_education_level varchar, 
                                            years_of_experience number, 
                                            job_id number , 
                                            job_name varchar, 
                                            job_city varchar, 
                                            job_state varchar, 
                                            required_education_level varchar, 
                                            status varchar, 
                                            comments varchar);

Show parameters like '%extension%' in account; --Maximum number of days to extend data retention beyond the retention period to prevent a stream becoming stale.

insert into public.raw_applicant_staging values	(111111,	'James',	'Schwartz',	'M',	'American' , ' 342-76-9087' , '5676 WashingtonStreet', 'High School', 5,10) ;					
insert into public.raw_applicant_staging values 	(222222,	'Jessica',	'Escobar ',	'F',	'Hispanic' , '456-93-5629' , '3234 WateringCanDrive', 'Undergrad', 4, 10) ;
insert into public.raw_applicant_staging values	(333333,	'Ben',	'Hardy',	'M',	'American' , ' 876-98-3245' , ' 6578 HistoricCircle', 'Masters', 6, 30) ;			
insert into public.raw_applicant_staging values 	(444444,	'Anjali',	'Singh',	'F',	'Indian American' , '435-87-6532' , '8978 Autumn DayDrive' , 'Masters', 8,20) ;
insert into public.raw_applicant_staging values	(555555,	'Dean',	'Tracy',	'M',	'African ' , '767-34-7656' , ' 2343 IndiaStreet ', 'Undergrad', 2,50) ;

--truncate table public.raw_applicant_staging;

show streams;
Select * from strm_1;
Select * from public.raw_applicant_staging;

create or replace stream strm_applicant on table public.raw_applicant_staging;

select * from strm_applicant;

--Updating the data in raw table for the below
update public.raw_applicant_staging set job_id = 10 where id = 555555;

--check the stream object now 
select * from strm_applicant; -- It will Captures the above update and still we have 5 rows in stream Object ACTION = INSERT and ISUPDATE = FALSE for ID 555555

update public.raw_applicant_staging set years_of_experience = 2 where ID = 111111;
/*Still ACTION = INSERT and ISUPDATE = FALSE for ID 111111 Cause Offset still consumed by the target. Once offset is consumed by the Target table only it will 
detects the deletes or updates cause update is an upsert statement first it will deletes the existing one and insert that as a new records with new changes  */
select * from strm_applicant;

/*So stream is immediately reflecting what changes are done in staging, this is called net effect or default stream. It doesn’t show you intermediate states, it shows 
net effect of multiple insert, updates and deletes*/
-- Let’s delete and check
--Delete from public.raw_applicant_staging where job_id = 30;

--now we will have 4 Records in the Stream Object as oer the above this is called net effect by Delta Load
/*So, even if I delete it, it will not show you any history that it has 5 rows/records initially So stream is immediately reflecting what changes are done in stag*/
select * from strm_applicant; -- Stream object maintains the ACTION = DELET and ISUPDATE = false history

--delete from public.raw_applicant_staging; -- No data in stream Object

insert into public.candidates values (100000, 'James', 'Schwartz', 'M', 'American' , ' 342-76-9087' , '5676 Washington Street', 'High School', 5, 10, 'Painter', 'Raleigh', 'NC', 'High School', 'SHORTLISTED', 'The education level of candidate matched with job') ;

--Consuming the Stream Data by using Merge statement
Merge into public.candidates tgt using (
    Select  id,
            first_name, 
            Last_name, 
            sex , 
            ethinicity , 
            ssn , 
            street_address , 
            str.education_level as ed_level, 
            years_of_experience , 
            jdtl.job_id  , 
            name , 
            city , 
            state , 
            jdtl.education_level as jreq_level , 
            case when str.education_level = jdtl.education_level then 'SHORTLISTED' ELSE 'STAGE' END as staus,
            case when str.education_level = jdtl.education_level then 'THE EDUCATION LEVEL IS MATCHED WITH JOB' ELSE 'APPLICATION RECIEVED FROM CANDIDATE' end as comments,
            str.metadata$action,
            str.metadata$isupdate
            from strm_applicant str inner join public.job_details jdtl on (str.job_id = jdtl.job_id) ) src ON tgt.job_id = src.JOB_ID
when not matched and src.metadata$isupdate = 'false' and src.metadata$action = 'INSERT' then insert values(
            id,
            first_name, 
            Last_name, 
            sex , 
            ethinicity , 
            ssn , 
            street_address , 
            ed_level , 
            years_of_experience , 
            job_id  , 
            name , 
            city , 
            state , 
            jreq_level , 
            staus,
            comments
) ;

Select * from public.candidates;
--truncate table public.candidates;

select current_schema();
create or replace stream strm_applicant_1 on table public.raw_applicant_staging append_only = true;

show streams;

INSERT INTO public.raw_applicant_staging VALUES
(666666, 'Michael', 'Johnson', 'M', 'American', '123-45-6789', '4567 Oak Street', 'High School', 7, 20),
(777777, 'Sophia', 'Williams', 'F', 'African American', '234-56-7890', '7890 Maple Avenue', 'Undergrad', 6, 40),
(888888, 'Daniel', 'Brown', 'M', 'American', '345-67-8901', '1234 Pine Road', 'Masters', 8, 25),
(999999, 'Emily', 'Davis', 'F', 'American', '456-78-9012', '5678 Cedar Lane', 'Undergrad', 5, 15),
(111112, 'Robert', 'Miller', 'M', 'Hispanic', '567-89-0123', '9012 Elm Street', 'High School', 4, 30),
(222223, 'Olivia', 'Wilson', 'F', 'Indian American', '678-90-1234', '3456 Lake Drive', 'Masters', 9, 50),
(333334, 'William', 'Moore', 'M', 'American', '789-01-2345', '6789 River Road', 'Undergrad', 7, 35),
(444445, 'Isabella', 'Taylor', 'F', 'Asian American', '890-12-3456', '2345 Washington Street', 'Masters', 8, 45),
(555556, 'Alexander', 'Anderson', 'M', 'African', '901-23-4567', '8765 Lincoln Avenue', 'Undergrad', 6, 20),
(666667, 'Mia', 'Thomas', 'F', 'American', '012-34-5678', '4321 Jefferson Road', 'High School', 5, 10);

Select * from strm_applicant_1; --ID = 888888 will be there in this cause it is a APPEND_ONLY Stream
Select * from strm_applicant; -- ID = 888888 not there 

delete from public.raw_applicant_staging where ID = 888888;

--Alter parameters  set MAX_DATA_EXTENSION_TIME_IN_DAYS = 1 in account;


--CHANGE Clause in Stream Point of view. Like if the offset is consumed we can't able to consume the change data. In this case we can use the Change clause to conusmed offset data
--We can apply this on both tables and views 
--we can able to track both inserts and deletes 
--Here also we will have the Metadata columns like Streams 
--The data is still persisting even after consumption

create or replace table public.raw_app_stg as Select * from public.raw_applicant_staging ;

create view public.vw_raw_app_stg as Select * from public.raw_app_stg where sex = 'M';

insert into public.raw_app_stg values	(111111,	'James',	'Schwartz',	'M',	'American' , ' 342-76-9087' , '5676 WashingtonStreet', 'High School', 5,10) ;					
insert into public.raw_app_stg values 	(222222,	'Jessica',	'Escobar ',	'F',	'Hispanic' , '456-93-5629' , '3234 WateringCanDrive', 'Undergrad', 4, 10) ;
insert into public.raw_app_stg values	(333333,	'Ben',	'Hardy',	'M',	'American' , ' 876-98-3245' , ' 6578 HistoricCircle', 'Masters', 6, 30) ;			
insert into public.raw_app_stg values 	(444444,	'Anjali',	'Singh',	'F',	'Indian American' , '435-87-6532' , '8978 Autumn DayDrive' , 'Masters', 8,20) ;
insert into public.raw_app_stg values	(555555,	'Dean',	'Tracy',	'M',	'African ' , '767-34-7656' , ' 2343 IndiaStreet ', 'Undergrad', 2,50) ;

--truncate table public.raw_app_stg;

alter table public.raw_app_stg set change_tracking = true;
alter view public.vw_raw_app_stg set change_tracking = true;

show tables in schema public;
show views in schema public;

Select CURRENT_TIMESTAMP(); --2026-09-02 01:04:24.944 -0700
Select * from public.raw_app_stg; -- 3ROWS
Select * from public.vw_raw_app_stg; --2Rows

Select CURRENT_TIMESTAMP(); --2026-09-02 01:07:02.289 -0700
Select * from public.raw_app_stg; --5 Rows
Select * from public.vw_raw_app_stg; -- 3 ROWS

--tracking the changes now 
Select * from public.raw_app_stg changes(information => default)
at (TIMESTAMP => '2026-09-02 01:07:02.289 -0700'::TIMESTAMP_tz);
Select * from public.vw_raw_app_stg changes(information => default) at (TIMESTAMP => '2026-09-02 01:07:02.289 -0700'::TIMESTAMP_tz);

Select CURRENT_TIMESTAMP(); --2026-09-02 01:19:48.767 -0700
INSERT INTO public.raw_app_stg VALUES
(666666, 'Michael', 'Johnson', 'M', 'American', '123-45-6789', '4567 Oak Street', 'High School', 7, 20),
(777777, 'Sophia', 'Williams', 'F', 'African American', '234-56-7890', '7890 Maple Avenue', 'Undergrad', 6, 40),
(888888, 'Daniel', 'Brown', 'M', 'American', '345-67-8901', '1234 Pine Road', 'Masters', 8, 25),
(999999, 'Emily', 'Davis', 'F', 'American', '456-78-9012', '5678 Cedar Lane', 'Undergrad', 5, 15),
(111112, 'Robert', 'Miller', 'M', 'Hispanic', '567-89-0123', '9012 Elm Street', 'High School', 4, 30),
(222223, 'Olivia', 'Wilson', 'F', 'Indian American', '678-90-1234', '3456 Lake Drive', 'Masters', 9, 50),
(333334, 'William', 'Moore', 'M', 'American', '789-01-2345', '6789 River Road', 'Undergrad', 7, 35),
(444445, 'Isabella', 'Taylor', 'F', 'Asian American', '890-12-3456', '2345 Washington Street', 'Masters', 8, 45),
(555556, 'Alexander', 'Anderson', 'M', 'African', '901-23-4567', '8765 Lincoln Avenue', 'Undergrad', 6, 20),
(666667, 'Mia', 'Thomas', 'F', 'American', '012-34-5678', '4321 Jefferson Road', 'High School', 5, 10);

Select * from public.raw_app_stg; --5 Rows
Select * from public.vw_raw_app_stg; -- 3 ROWS


create table public.emp(id number,name varchar, gender varchar);
create view public.v_emp as Select * from public.emp where gender = 'M';

alter table public.emp set change_tracking = true;
alter view  public.v_emp set change_tracking = true;
Select CURRENT_TIMESTAMP(); --2026-09-02 01:27:30.339 -0700
insert into public.emp values(1,'A','M'),(2,'B','F'),(3,'C','M');

Select * from public.emp;
Select * from  public.v_emp;

Select CURRENT_TIMESTAMP(); --2026-09-02 01:28:33.659 -0700
insert into public.emp values(4,'D','M'),(5,'E','F'),(6,'F','F'),(7,'G','F');

Select * from public.emp;
Select * from  public.v_emp;

Select * from public.emp changes(information => default) at (TIMESTAMP => '2026-09-02 01:28:33.659 -0700'::TIMESTAMP_tz);
Select * from  public.v_emp;

CREATE OR REPLACE TABLE MOVIELENS.RAW.RAW_FILMS
(
    MOVIE_ID       INTEGER,
    TITLE          VARCHAR(200),
    GENRES         VARCHAR(200),
    RELEASE_YEAR   INTEGER,
    RATING         NUMBER(3,1),
    UPDATED_AT     TIMESTAMP_NTZ
);

INSERT INTO MOVIELENS.RAW.RAW_FILMS
(
    MOVIE_ID,
    TITLE,
    GENRES,
    RELEASE_YEAR,
    RATING,
    UPDATED_AT
)
VALUES
(1,  'Toy Story',              'Animation|Comedy',        1995, 4.0, '2026-09-01 09:00:00'),
(2,  'Jumanji',                'Adventure|Children',      1995, 3.5, '2026-09-01 09:05:00'),
(3,  'Grumpier Old Men',       'Comedy|Romance',          1995, 3.0, '2026-09-01 09:10:00'),
(4,  'Waiting to Exhale',      'Comedy|Drama',            1995, 3.5, '2026-09-01 09:15:00'),
(5,  'Father of the Bride II','Comedy',                   1995, 3.0, '2026-09-01 09:20:00'),
(6,  'Heat',                   'Action|Crime|Thriller',    1995, 4.5, '2026-09-01 09:25:00'),
(7,  'Sabrina',                'Comedy|Romance',           1995, 3.5, '2026-09-01 09:30:00'),
(8,  'Tom and Huck',           'Adventure|Children',       1995, 3.0, '2026-09-01 09:35:00'),
(9,  'Sudden Death',           'Action',                   1995, 3.5, '2026-09-01 09:40:00'),
(10, 'GoldenEye',              'Action|Adventure|Thriller',1995, 4.0, '2026-09-01 09:45:00');