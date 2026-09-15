Use Database MDB;

use schema public;

create or replace table raw_applicant_staging 
(   id number autoincrement start = 111111 increment = 111111, 
    first_name varchar, 
    last_name varchar, 
    sex varchar, 
    ethinicity varchar, 
    ssn varchar, 
    street_address varchar, 
    education_level varchar, 
    years_of_experience number, 
    job_id number
);

Select * from public.raw_applicant_staging;

create or replace schema Tasks;

use schema Tasks;

create or replace task tsk_add_applicant --Not scheduled as well
    warehouse = compute_wh -- optional, we are creating a task which uses the user defined compute power. Hence gave the warehouse 
    as  insert into public.raw_applicant_staging ( first_name, last_name, sex, ethinicity, ssn, street_address, education_level, years_of_experience, job_id) 
        values ( 'James ' , ' Schwartz ' , 'M' , 'American ' , '342-76-9087' , ' 5676 Washington Street ' , 'High School ', 5, 10) ;

show tasks;

-- Manually trigger the task
execute task tsk_add_applicant;

select current_schema();

create or replace task t2NS --In Suspended state
schedule = '1 minute'
as insert into public.raw_applicant_staging ( first_name, last_name, sex, ethinicity, ssn, street_address, education_level, years_of_experience, job_id) 
        values ( 'James ' , ' Schwartz ' , 'M' , 'American ' , '342-76-9087' , ' 5676 Washington Street ' , 'High School ', 5, 10) ;

--Resume Task
alter task t2ns resume;

create or replace task t2WH
schedule = '2 minutes'
warehouse = compute_wh
as insert into public.raw_applicant_staging ( first_name, last_name, sex, ethinicity, ssn, street_address, education_level, years_of_experience, job_id) 
        values ( 'James ' , ' Schwartz ' , 'M' , 'American ' , '342-76-9087' , ' 5676 Washington Street ' , 'High School ', 5, 10) ;

alter task t2wh resume;

--alter task t2wh suspend;
--alter task t2ns suspend;

create or replace table public.raw_applicant_staging_1
(   id number autoincrement start = 111111 increment = 111111, 
    first_name varchar, 
    last_name varchar, 
    sex varchar, 
    ethinicity varchar, 
    ssn varchar, 
    street_address varchar, 
    education_level varchar, 
    years_of_experience number, 
    job_id number
);

Select * from table(INFORMATION_SCHEMA.TASK_HISTORY( ));
--Manual Task
--WAREHOUSE TASK
--Schedule Task

show schemas;
use schema SPROC;

create or replace procedure prc_1()
returns string
language sql
as
    $$
    Begin
    insert into public.raw_applicant_staging_1 ( first_name, last_name, sex, ethinicity, ssn, street_address, education_level, years_of_experience, job_id) 
        values ( 'James ' , ' Schwartz ' , 'M' , 'American ' , '342-76-9087' , ' 5676 Washington Street ' , 'High School ', 5, 10) ;
        return "Records inserted Successfully";
    END;
    $$;

Use schema tasks;

create or replace task t3sp 
warehouse = compute_wh
schedule = '1 minute'
as
    call prc_1();

show tasks;

alter task t3sp resume;

Select * from public.raw_applicant_staging_1;

show tables;

Select Current_timestamp();

--Schedulling tasks using CRON
Show parameters like '%timezone%';

Select current_schema();

create or replace task t4CS
warehouse = compute_wh
schedule = 'USING CRON 50 4 * * * America/Los_Angeles'  --4:50AM Everyday
as 
    insert into public.raw_applicant_staging_1 ( first_name, last_name, sex, ethinicity, ssn, street_address, education_level, years_of_experience, job_id) 
        values ( 'Cron ' , ' Schwartz ' , 'M' , 'American ' , '342-76-9087' , ' 5676 Washington Street ' , 'High School ', 5, 10) ;
       

/*  <1> - (0-59) minute  you can give at which minute you want to execute your task
    <2> - (0-23) hour  you can give at which hour you want to execute your task
    <3> - (1-31, L) day of month  you can give at which day of month you want to execute your task, if it is a last day of month you can give directly ‘L’ without mentioning last day
    <4> - (1-12, JAN, FEB, MAR...DEC) month  you can give at which month you want to execute your task
    <5> - (0-6, SUN, MON, TUE...SAT, L) day of week you can give at which day of week you want to execute your task
    <6> - (America/Los_Angeles, America/New_York, 'America/Chicago') timezone  you can give your time zone
    EmptyValue is *  this implies if I want to leave any, I simply give a star at that place  */

Create or replace task t5CS 
warehouse = compute_wh
schedule = 'USING cron 50 4 2 * * America/Los_Angeles' --2nd everymonth at 4:50 AM
as
     insert into public.raw_applicant_staging_1 ( first_name, last_name, sex, ethinicity, ssn, street_address, education_level, years_of_experience, job_id) 
        values ( 'Cron' , ' Schwartz ' , 'M' , 'American ' , '342-76-9087' , ' 5676 Washington Street ' , 'High School ', 5, 10) ;

Create or replace task t6cs 
warehouse = compute_wh 
schedule = 'USING CRON 50 4 2 OCT * America/Los_Angeles'
as
     insert into public.raw_applicant_staging_1 ( first_name, last_name, sex, ethinicity, ssn, street_address, education_level, years_of_experience, job_id) 
        values ( 'Cron ' , ' Schwartz ' , 'M' , 'American ' , '342-76-9087' , ' 5676 Washington Street ' , 'High School ', 5, 10) ;

create or replace task t7CS
warehouse = compute_wh
schedule = 'USING CRON 50 4 * OCT 1 America/Los_Angeles '
as
     insert into public.raw_applicant_staging_1 ( first_name, last_name, sex, ethinicity, ssn, street_address, education_level, years_of_experience, job_id) 
        values ( 'Cron ' , ' Schwartz ' , 'M' , 'American ' , '342-76-9087' , ' 5676 Washington Street ' , 'High School ', 5, 10) ;

create or replace task t8CS
warehouse = compute_wh
schedule = 'USING CRON 0 4-20 L * * America/Los_Angeles '
as
     insert into public.raw_applicant_staging_1 ( first_name, last_name, sex, ethinicity, ssn, street_address, education_level, years_of_experience, job_id) 
        values ( 'Cron ' , ' Schwartz ' , 'M' , 'American ' , '342-76-9087' , ' 5676 Washington Street ' , 'High School ', 5, 10) ;

create or replace task t9CS
warehouse = compute_wh
schedule = 'USING CRON 0 4-20 * * 6 America/Los_Angeles '
as
     insert into public.raw_applicant_staging_1 ( first_name, last_name, sex, ethinicity, ssn, street_address, education_level, years_of_experience, job_id) 
        values ( 'Cron ' , ' Schwartz ' , 'M' , 'American ' , '342-76-9087' , ' 5676 Washington Street ' , 'High School ', 5, 10) ;

create or replace table public.job_details ( job_id number, name varchar, city varchar, state varchar, education_level varchar );
insert into public.job_details values  (10, 'Painter ', 'Raleigh', 'NC' , 'High School' ), 
                                (20, 'Software Engineer ', 'Raleigh', 'NC' , 'Masters' ),
                                (30, 'Data Architect ' , 'Raleigh', 'NC' , 'Undergrad' ), 
                                (40, 'Vice President', 'Raleigh', 'NC' , 'Masters' ) ,
                                (50, 'Associate' , 'Raleigh' , 'NC' , 'Masters' ) ;

create or replace table public.candidates ( id number, 
                                            first_name varchar, 
                                            last_name varchar, 
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
                                            comments varchar, 
                                            interview_month varchar  ) ;
Select * from public.candidates;
Select * from public.candidates;
Select * from public.raw_applicant_staging;