CREATE STORAGE INTEGRATION my_s3_integration
    TYPE = EXTERNAL_STAGE
    STORAGE_PROVIDER = S3
    ENABLED = TRUE
    STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::881414777122:role/s3-snowflake-connection'
    STORAGE_ALLOWED_LOCATIONS = ('s3://siase-dbt');

    desc integration my_s3_integration;

Use ROLE ACCOUNTADMIN;

-- Create the role and assign it to ACCOUNTADMIN
CREATE ROLE IF NOT EXISTS PATRICKTRANSFORM;
GRANT ROLE PATRICKTRANSFORM TO ROLE ACCOUNTADMIN;

-- Create a default warehouse
CREATE WAREHOUSE IF NOT EXISTS COMPUTE_WH;
GRANT OPERATE ON WAREHOUSE COMPUTE_WH to role PATRICKTRANSFORM;

-- Create the `dbt` user and assign to the transform role
CREATE USER IF NOT EXISTS dbt
  PASSWORD='dbtPassword123'
  LOGIN_NAME='dbt'
  MUST_CHANGE_PASSWORD=FALSE
  DEFAULT_WAREHOUSE='COMPUTE_WH'
  DEFAULT_ROLE=PATRICKTRANSFORM
  DEFAULT_NAMESPACE='MOVIELENS.RAW'
  COMMENT='DBT user used for data transformation';
ALTER USER dbt SET TYPE = LEGACY_SERVICE;  --This user is for automation (like dbt), not a human logging in.
GRANT ROLE PATRICKTRANSFORM TO USER dbt;

-- Create a database and schema for the MovieLens project
CREATE DATABASE IF NOT EXISTS MOVIELENS;
use database MOVIELENS;

CREATE SCHEMA IF NOT EXISTS MOVIELENS.RAW;
use schema RAW;

-- Grant permissions to the `transform` role
GRANT ALL ON WAREHOUSE COMPUTE_WH TO ROLE PATRICKTRANSFORM;
GRANT ALL ON DATABASE MOVIELENS TO ROLE PATRICKTRANSFORM;
GRANT ALL ON ALL SCHEMAS IN DATABASE MOVIELENS TO ROLE PATRICKTRANSFORM;
GRANT ALL ON FUTURE SCHEMAS IN DATABASE MOVIELENS TO ROLE PATRICKTRANSFORM;
GRANT ALL ON ALL TABLES IN SCHEMA MOVIELENS.RAW TO ROLE PATRICKTRANSFORM;
GRANT ALL ON FUTURE TABLES IN SCHEMA MOVIELENS.RAW TO ROLE PATRICKTRANSFORM;

-- CREATE Stage that would connect to you S3 Bucket
CREATE OR REPLACE STAGE siaseDBT
URL = 's3://siase-dbt'
STORAGE_INTEGRATION = my_s3_integration ;

list @siaseDBT;

-- Set defaults
USE WAREHOUSE COMPUTE_WH;
USE DATABASE MOVIELENS;
USE SCHEMA RAW;

-- Load raw movies
CREATE OR REPLACE TABLE raw_movies (
  movieId INTEGER,
  title STRING,
  genres STRING
);

COPY INTO raw_movies
FROM '@siaseDBT/movies.csv'
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- Load raw_ratings
CREATE OR REPLACE TABLE raw_ratings (
  userId INTEGER,
  movieId INTEGER,
  rating FLOAT,
  timestamp BIGINT
);

COPY INTO raw_ratings
FROM '@siaseDBT/ratings.csv'
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- Load raw_tags
CREATE OR REPLACE TABLE raw_tags (
  userId INTEGER,
  movieId INTEGER,
  tag STRING,
  timestamp BIGINT
);

COPY INTO raw_tags
FROM '@siaseDBT/tags.csv'
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"')
ON_ERROR = 'CONTINUE';

-- Load raw_genome_scores
CREATE OR REPLACE TABLE raw_genome_scores (
  movieId INTEGER,
  tagId INTEGER,
  relevance FLOAT
);

COPY INTO raw_genome_scores
FROM '@siaseDBT/genome-scores.csv'
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');

-- Load raw_genome_tags
CREATE OR REPLACE TABLE raw_genome_tags (
  tagId INTEGER,
  tag STRING
);

COPY INTO raw_genome_tags
FROM '@siaseDBT/genome-tags.csv'
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"')
ON_ERROR = 'CONTINUE';

-- Load raw_links
CREATE OR REPLACE TABLE raw_links (
  movieId INTEGER,
  imdbId INTEGER,
  tmdbId INTEGER
);

COPY INTO raw_links
FROM '@siaseDBT/links.csv'
FILE_FORMAT = (TYPE = 'CSV' SKIP_HEADER = 1 FIELD_OPTIONALLY_ENCLOSED_BY = '"');


Show tables in schema RAW;

INSERT INTO raw_movies (movieId, title, genres) VALUES
(1, 'Toy Story (1995)', 'Adventure|Animation|Children|Comedy|Fantasy'),
(2, 'Jumanji (1995)', 'Adventure|Children|Fantasy'),
(3, 'Grumpier Old Men (1995)', 'Comedy|Romance'),
(4, 'Waiting to Exhale (1995)', 'Comedy|Drama|Romance'),
(5, 'Father of the Bride Part II (1995)', 'Comedy'),
(6, 'Heat (1995)', 'Action|Crime|Thriller'),
(7, 'Sabrina (1995)', 'Comedy|Romance'),
(8, 'Tom and Huck (1995)', 'Adventure|Children'),
(9, 'Sudden Death (1995)', 'Action'),
(10, 'GoldenEye (1995)', 'Action|Adventure|Thriller'),
(11, 'American President, The (1995)', 'Comedy|Drama|Romance'),
(12, 'Dracula: Dead and Loving It (1995)', 'Comedy|Horror'),
(13, 'Balto (1995)', 'Adventure|Animation|Children'),
(14, 'Nixon (1995)', 'Drama'),
(15, 'Cutthroat Island (1995)', 'Action|Adventure|Romance'),
(16, 'Casino (1995)', 'Crime|Drama'),
(17, 'Sense and Sensibility (1995)', 'Drama|Romance'),
(18, 'Four Rooms (1995)', 'Comedy'),
(19, 'Ace Ventura: When Nature Calls (1995)', 'Comedy'),
(20, 'Money Train (1995)', 'Action|Comedy|Crime|Drama|Thriller');

INSERT INTO raw_ratings (userId, movieId, rating, timestamp) VALUES
(101, 1, 4.5, 1704067200),
(102, 1, 5.0, 1704070800),
(103, 2, 3.5, 1704074400),
(104, 2, 4.0, 1704078000),
(105, 3, 3.0, 1704081600),
(106, 4, 4.5, 1704085200),
(107, 5, 3.5, 1704088800),
(108, 6, 5.0, 1704092400),
(109, 7, 4.0, 1704096000),
(110, 8, 2.5, 1704099600),
(101, 9, 3.0, 1704103200),
(102, 10, 4.5, 1704106800),
(103, 11, 4.0, 1704110400),
(104, 12, 2.0, 1704114000),
(105, 13, 3.5, 1704117600),
(106, 14, 4.0, 1704121200),
(107, 15, 2.5, 1704124800),
(108, 16, 4.5, 1704128400),
(109, 17, 5.0, 1704132000),
(110, 18, 3.0, 1704135600);

INSERT INTO raw_tags (userId, movieId, tag, timestamp) VALUES
(101, 1, 'funny', 1704067200),
(102, 1, 'animation', 1704070800),
(103, 2, 'adventure', 1704074400),
(104, 2, 'fantasy', 1704078000),
(105, 3, 'romantic', 1704081600),
(106, 4, 'drama', 1704085200),
(107, 5, 'family', 1704088800),
(108, 6, 'crime', 1704092400),
(109, 7, 'romance', 1704096000),
(110, 8, 'adventure', 1704099600),
(101, 9, 'action', 1704103200),
(102, 10, 'james bond', 1704106800),
(103, 11, 'political', 1704110400),
(104, 12, 'horror comedy', 1704114000),
(105, 13, 'animation', 1704117600),
(106, 14, 'historical', 1704121200),
(107, 15, 'pirates', 1704124800),
(108, 16, 'mafia', 1704128400),
(109, 17, 'classic romance', 1704132000),
(110, 18, 'dark comedy', 1704135600);

INSERT INTO raw_genome_tags (tagId, tag) VALUES
(1, 'funny'),
(2, 'action'),
(3, 'adventure'),
(4, 'romance'),
(5, 'drama'),
(6, 'comedy'),
(7, 'fantasy'),
(8, 'animation'),
(9, 'crime'),
(10, 'thriller'),
(11, 'family'),
(12, 'horror'),
(13, 'classic'),
(14, 'historical'),
(15, 'political'),
(16, 'mafia'),
(17, 'pirates'),
(18, 'children'),
(19, 'friendship'),
(20, 'love');

INSERT INTO raw_genome_scores (movieId, tagId, relevance) VALUES
(1, 1, 0.95),
(1, 8, 0.98),
(1, 18, 0.92),
(2, 3, 0.96),
(2, 7, 0.89),
(3, 6, 0.91),
(3, 4, 0.87),
(4, 5, 0.94),
(4, 4, 0.90),
(5, 6, 0.97),
(6, 2, 0.96),
(6, 9, 0.93),
(6, 10, 0.91),
(7, 4, 0.88),
(8, 3, 0.85),
(9, 2, 0.94),
(10, 2, 0.97),
(10, 3, 0.95),
(16, 9, 0.99),
(17, 4, 0.96);

INSERT INTO raw_links (movieId, imdbId, tmdbId) VALUES
(1, 114709, 862),
(2, 113497, 8844),
(3, 113228, 15602),
(4, 114885, 31357),
(5, 113041, 11862),
(6, 113277, 949),
(7, 114319, 11860),
(8, 112302, 45325),
(9, 114576, 9091),
(10, 113189, 710),
(11, 112346, 9087),
(12, 112896, 12110),
(13, 113442, 21032),
(14, 113987, 10858),
(15, 112286, 1408),
(16, 112641, 524),
(17, 114388, 4584),
(18, 113101, 5),
(19, 112281, 9273),
(20, 113845, 11517);

Show tables in schema RAW;

CREATE OR REPLACE TABLE raw_movie_release_dates (
    movie_id        NUMBER(38,0),
    movie_title     STRING,
    release_date    DATE,
    language        STRING,
    genre           STRING,
    source_file     STRING,
    ingested_at     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

CREATE OR REPLACE TABLE raw_movie_events (
    event_id        NUMBER(38,0),
    movie_id        NUMBER(38,0),
    event_type      STRING,
    event_value     STRING,
    event_date      DATE,
    updated_at      TIMESTAMP_NTZ,
    source_file     STRING,
    ingested_at     TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP()
);

INSERT INTO raw_movie_release_dates
(movie_id, movie_title, release_date, language, genre, source_file)
VALUES
(1, 'Movie A', '2024-01-10', 'English', 'Drama', 'file_001.csv'),
(2, 'Movie B', '2024-02-15', 'English', 'Action', 'file_001.csv'),
(3, 'Movie C', '2024-03-20', 'Hindi', 'Comedy', 'file_001.csv');

INSERT INTO raw_movie_events
(event_id, movie_id, event_type, event_value, event_date, updated_at, source_file)
VALUES
(101, 1, 'release', 'theatrical', '2024-01-10', '2024-01-10 10:00:00', 'events_001.csv'),
(102, 1, 'rating', '4.5', '2024-01-11', '2024-01-11 09:30:00', 'events_001.csv'),
(103, 2, 'release', 'digital', '2024-02-15', '2024-02-15 11:00:00', 'events_001.csv');

INSERT INTO raw_movie_events
(event_id, movie_id, event_type, event_value, event_date, updated_at, source_file)
VALUES
(104, 2, 'rating', '4.2', '2024-02-16', '2024-02-16 14:15:00', 'events_002.csv'),
(105, 3, 'release', 'theatrical', '2024-03-20', '2024-03-20 08:45:00', 'events_002.csv');

create table raw_dept(
  deptno number(2,0),
  dname  varchar2(14),
  loc    varchar2(13)
);

--drop table raw_dept;
 
create table raw_emp(
  empno    number(4,0),
  ename    varchar2(10),
  job      varchar2(9),
  mgr      number(4,0),
  hiredate date,
  sal      number(7,2),
  comm     number(7,2),
  deptno   number(2,0)
);
 
--drop table raw_emp;

create table raw_bonus(
  ename varchar2(10),
  job   varchar2(9),
  sal   number,
  comm  number
);

--drop table raw_bonus;
 
create table raw_salgrade(
  grade number,
  losal number,
  hisal number
);

--drop table raw_salgrade
insert into raw_dept
values(10, 'ACCOUNTING', 'NEW YORK');
insert into raw_dept
values(20, 'RESEARCH', 'DALLAS');
insert into raw_dept
values(30, 'SALES', 'CHICAGO');
insert into raw_dept
values(40, 'OPERATIONS', 'BOSTON');
 
insert into raw_emp
values(
 7839, 'KING', 'PRESIDENT', null,
 to_date('17-11-1981','dd-mm-yyyy'),
 5000, null, 10
);
insert into raw_emp
values(
 7698, 'BLAKE', 'MANAGER', 7839,
 to_date('1-5-1981','dd-mm-yyyy'),
 2850, null, 30
);
insert into raw_emp
values(
 7782, 'CLARK', 'MANAGER', 7839,
 to_date('9-6-1981','dd-mm-yyyy'),
 2450, null, 10
);
insert into raw_emp
values(
 7566, 'JONES', 'MANAGER', 7839,
 to_date('2-4-1981','dd-mm-yyyy'),
 2975, null, 20
);
insert into raw_emp
values(
 7788, 'SCOTT', 'ANALYST', 7566,
 to_date('13-JUL-87','dd-mm-rr') - 85,
 3000, null, 20
);
insert into raw_emp
values(
 7902, 'FORD', 'ANALYST', 7566,
 to_date('3-12-1981','dd-mm-yyyy'),
 3000, null, 20
);
insert into raw_emp
values(
 7369, 'SMITH', 'CLERK', 7902,
 to_date('17-12-1980','dd-mm-yyyy'),
 800, null, 20
);
insert into raw_emp
values(
 7499, 'ALLEN', 'SALESMAN', 7698,
 to_date('20-2-1981','dd-mm-yyyy'),
 1600, 300, 30
);
insert into raw_emp
values(
 7521, 'WARD', 'SALESMAN', 7698,
 to_date('22-2-1981','dd-mm-yyyy'),
 1250, 500, 30
);
insert into raw_emp
values(
 7654, 'MARTIN', 'SALESMAN', 7698,
 to_date('28-9-1981','dd-mm-yyyy'),
 1250, 1400, 30
);
insert into raw_emp
values(
 7844, 'TURNER', 'SALESMAN', 7698,
 to_date('8-9-1981','dd-mm-yyyy'),
 1500, 0, 30
);
insert into raw_emp
values(
 7876, 'ADAMS', 'CLERK', 7788,
 to_date('13-JUL-87', 'dd-mm-rr') - 51,
 1100, null, 20
);
insert into raw_emp
values(
 7900, 'JAMES', 'CLERK', 7698,
 to_date('3-12-1981','dd-mm-yyyy'),
 950, null, 30
);
insert into raw_emp
values(
 7934, 'MILLER', 'CLERK', 7782,
 to_date('23-1-1982','dd-mm-yyyy'),
 1300, null, 10
);
 

insert into raw_salgrade
values (1, 700, 1200);
insert into raw_salgrade
values (2, 1201, 1400);
insert into raw_salgrade
values (3, 1401, 2000);
insert into raw_salgrade
values (4, 2001, 3000);
insert into raw_salgrade
values (5, 3001, 9999);

 
commit;

alter table raw_bonus add column updated_at timestamp;
alter table raw_emp add column updated_at timestamp;
alter table raw_dept add column updated_at timestamp;
alter table raw_salgrade add column updated_at timestamp;

update raw_bonus set updated_at = CURRENT_TIMESTAMP();
update raw_emp set updated_at = CURRENT_TIMESTAMP();
update raw_dept set updated_at = CURRENT_TIMESTAMP();
update raw_salgrade set updated_at = CURRENT_TIMESTAMP();

Select COUNT(*) from raw_emp;

Show tables in schema INC_LOAD;
--drop table INC_LOAD.EMP_INC1;
use database MOVIELENS;
Use schema RAW;
Select current_schema();
Show tables;
--Create table employees as Select * from MDB.E_STG.EMP_S ;

Select * from employees where DATE_PART('year',JOIN_DATE) = 2026;

show schemas in database MOVIELENS;
use schema INC_LOAD;

Select * from emp_inc7; 

Select * from RAW.raw_emp;

Select * from raw.employees;

Select * from emp_inc8 where DATE_PART('year',JOIN_DATE) = 2025; 

INSERT INTO raw.raw_EMP
(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO, UPDATED_AT)
VALUES
(8001, 'ADAMS', 'CLERK', 7566, '2026-09-09', 2200, NULL, 20, CURRENT_TIMESTAMP());

INSERT INTO raw.raw_EMP
(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO, UPDATED_AT)
VALUES
(8002, 'BROWN', 'ANALYST', 7566, '2026-09-09', 3500, NULL, 20, CURRENT_TIMESTAMP());

INSERT INTO raw.raw_EMP
(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO, UPDATED_AT)
VALUES
(8003, 'DAVIS', 'SALESMAN', 7698, '2026-09-10', 1800, 250, 30, CURRENT_TIMESTAMP());

INSERT INTO raw.raw_EMP
(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO, UPDATED_AT)
VALUES
(8004, 'WILSON', 'CLERK', 7782, '2026-09-10', 2100, NULL, 10, CURRENT_TIMESTAMP());

INSERT INTO raw.raw_EMP
(EMPNO, ENAME, JOB, MGR, HIREDATE, SAL, COMM, DEPTNO, UPDATED_AT)
VALUES
(8005, 'TAYLOR', 'MANAGER', 7839, '2026-09-10', 4200, NULL, 30, CURRENT_TIMESTAMP());

UPDATE raw.raw_EMP
SET SAL = 1900,
    COMM = 500,
    UPDATED_AT = CURRENT_TIMESTAMP()
WHERE EMPNO = 7499;

UPDATE raw.raw_EMP
SET SAL = 3800,
    UPDATED_AT = CURRENT_TIMESTAMP()
WHERE EMPNO = 7902;

UPDATE raw.raw_EMP
SET SAL = 3500,
    UPDATED_AT = CURRENT_TIMESTAMP()
WHERE EMPNO = 7566;

Select * from emp_inc7; 

CREATE OR REPLACE TABLE RAW.RAW_CUSTOMERS
(
    CUSTOMER_ID   INTEGER,
    CUSTOMER_NAME VARCHAR(100),
    COUNTRY       VARCHAR(50),
    CREATED_AT    TIMESTAMP_NTZ
);

INSERT INTO RAW.RAW_CUSTOMERS
    (CUSTOMER_ID, CUSTOMER_NAME, COUNTRY, CREATED_AT)
VALUES
    (101, 'Ravi',  'India', '2026-09-01 09:00:00'),
    (102, 'John',  'USA',   '2026-09-01 10:00:00'),
    (103, 'David', 'UK',    '2026-09-01 11:00:00'),
    (104, 'Mike',  'Canada','2026-09-01 12:00:00');

CREATE OR REPLACE TABLE RAW.RAW_ORDERS
(
    ORDER_ID     INTEGER,
    CUSTOMER_ID  INTEGER,
    ORDER_DATE   DATE,
    AMOUNT       NUMBER(12,2),
    CREATED_AT   TIMESTAMP_NTZ
);

INSERT INTO RAW.RAW_ORDERS
    (ORDER_ID, CUSTOMER_ID, ORDER_DATE, AMOUNT, CREATED_AT)
VALUES
    (5001, 101, '2026-09-01', 100.00, '2026-09-01 09:30:00'),
    (5002, 101, '2026-09-02', 200.00, '2026-09-02 10:00:00'),
    (5003, 102, '2026-09-03', 300.00, '2026-09-03 11:00:00'),
    (5004, 103, '2026-09-04', 150.00, '2026-09-04 12:00:00'),
    (5005, 104, '2026-09-05', 250.00, '2026-09-05 13:00:00');

    show tables in database MOVIELENS;
    select * from DEV_STG.MY_FIRST_DBT_MODEL;

--Create database MFILM clone MOVIELENS;

Select Current_database();
Select current_schema();

--drop table raw.raw_cust;
create  table raw.raw_cust (
    customer_id number,
    customer_name varchar,
    email varchar,
    city varchar,
    updated_at timestamp_ntz,
    ingestion_ts timestamp_ntz
);

insert into raw.raw_cust
    (customer_id, customer_name, email, city, updated_at, ingestion_ts)
values
    (101, 'Ravi Kumar',  'ravi@gmail.com',  'Hyderabad', '2026-09-01 09:00:00', '2026-09-01 09:05:00'),
    (102, 'Anita Sharma','anita@gmail.com', 'Bengaluru', '2026-09-01 10:00:00', '2026-09-01 10:05:00'),
    (103, 'John David',  'john@gmail.com',  'Chennai',   '2026-09-01 11:00:00', '2026-09-01 11:05:00');

insert into raw.raw_cust
    (customer_id, customer_name, email, city, updated_at, ingestion_ts)
values
    -- Duplicate events for customer 102
    (102, 'Anita Sharma', 'anita@gmail.com', 'Mumbai',
     '2026-09-02 09:00:00', '2026-09-02 09:02:00'),

    (102, 'Anita Sharma', 'anita@gmail.com', 'Mumbai',
     '2026-09-02 09:00:00', '2026-09-02 09:10:00'),

    -- New customer
    (104, 'Priya Reddy', 'priya@gmail.com', 'Hyderabad',
     '2026-09-02 10:00:00', '2026-09-02 10:02:00'),

    -- Late-arriving correction: old business updated_at, loaded today
    (101, 'Ravi Kumar', 'ravi.kumar@gmail.com', 'Hyderabad',
     '2026-09-01 09:30:00', '2026-09-02 11:00:00');

     Select * from dbt_vakula.dim_customers_bad;