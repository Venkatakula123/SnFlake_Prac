use database MDB;
use schema public;

use role SYSADMIN;

create database PUBLIC_DB;
create schema MYPOLICIES;
use schema MYPOLICIES;
CREATE TABLE PUBLIC.CUSTOMER AS SELECT * FROM  SNOWFLAKE_SAMPLE_DATA.TPCH_SF1.CUSTOMER;

Select * from CUSTOMER;

use role accountadmin;
use role SECURITYADMIN;

CREATE ROLE sales_admin;
CREATE ROLE sales_users;

grant role sales_users to role sales_admin;
grant role sales_admin to role SYSADMIN;

create user Avr password = 'BJAAK9ceJQmQTY7' default_role = 'sales_users' ;
create user su password = 'BJAAK9ceJQmQTY7' default_role = 'sales_users' ;
create user sa password = 'BJAAK9ceJQmQTY7' default_role = 'sales_admin' ;

--drop user sa;

grant role sales_users to user su;
grant role sales_admin to user sa;

GRANT USAGE ON DATABASE PUBLIC_DB TO ROLE sales_users;
GRANT USAGE ON SCHEMA PUBLIC_DB.public TO ROLE sales_users;
GRANT SELECT ON TABLE PUBLIC_DB.public.CUSTOMER TO ROLE sales_users;

GRANT USAGE ON DATABASE PUBLIC_DB TO ROLE sales_admin;
GRANT USAGE ON SCHEMA PUBLIC_DB.public TO ROLE sales_admin;
GRANT SELECT ON TABLE PUBLIC_DB.public.CUSTOMER TO ROLE sales_admin;

show schemas;
use database PUBLIC_DB;
use schema MYPOLICIES; --Creating the schema Level Dynamic Data Masking Object within the schema 
--Want to Hide Phone and Account Balance
describe table PUBLIC.CUSTOMER;
Select * from PUBLIC.CUSTOMER;

use role accountadmin;

CREATE OR REPLACE Masking POLICY customer_phone AS (val STRING) RETURNS STRING -> 
        case    WHEN CURRENT_ROLE() in ('sales_admin') THEN val    
                ELSE  '##-###-###-####' END;

create or replace masking policy cust_phone as (val string) returns string ->
        CASE    WHEN CURRENT_ROLE() in ('sales_admin') THEN val
                ELSE '##-###-'||SUBSTR(val,12,4) END;

create or replace masking policy cust_ph as (val string) returns string ->
        CASE    when CURRENT_ROLE() in ('sales_admin') then val
                ELSE '***********' END;

create or replace masking policy cu_ph as (val string ) returns string ->
        case    when CURRENT_ROLE() in ('sales_admin') then val   
                ELSE 'FASAK' END;

--Applying the Masking Policy on Customer table C_PHONE Column
Alter table PUBLIC.CUSTOMER modify column C_PHONE set masking policy MYPOLICIES.cust_phone;

describe table PUBLIC.CUSTOMER; -- TO know which masking Policies are applied

--Creating a Masking Policy to hide C_ACCBAL column
Select current_schema();

create or replace masking policy cust_accbal as (val number) returns number ->
                CASE    WHEN CURRENT_ROLE() IN ('SALES_ADMIN') THEN val
                        ELSE 0.0 END;

create or replace table public.roles_tab(r_name varchar(50));

show roles;

INSERT INTO public.roles_tab values('SALES_ADMIN'),('SALES_USERS');

create or replace masking policy cust_accbal_1 as (val number) returns number ->
                CASE    WHEN CURRENT_ROLE() IN (SELECT r_name from public.roles_tab where r_name = 'sales_admin') THEN val
                        ELSE 0.0 END;

create or replace masking policy cust_accbal_2 as (val number) returns number ->
                CASE    WHEN CURRENT_ROLE() IN (SELECT r_name from public.roles_tab ) THEN val
                        ELSE 0.0 END;

use role sales_admin;
Select * from PUBLIC.CUSTOMER;

create table public.a(sno INTEGER);
create table public.b(sno INTEGER);

insert into b values(1),(2),(2),(4),(null);
insert into A values(1),(2),(1),(3),(null);

SELECT *
FROM A AS A1
RIGHT OUTER JOIN B AS B1
  ON A1.sno = B1.sno;

--Conditional Data Masking
create or replace table public.global_customer (
 customer_id varchar(),
 first_name varchar(),
 last_name varchar(),
 gender varchar(6),
 govt_id varchar(),
 date_of_birth date,
 annual_income number(38,2),
 credit_card_number varchar(20),
 card_provider varchar(20),
 mobile number(20),
 region text,
 address varchar(),
 created_on timestamp_ntz(9)
);


INSERT INTO public.global_customer  VALUES
('d1f6f86c-029a-4245-bb91-433a6aa79987','Mandy','Evans','Female','378-25-4428','1992-08-30',106352.09,'4516-4829-8251-8697','American Express','7282841760','Europe','13550 Etienne Pass Adamburgh, WI 76537','2024-02-04 17:36:43'),
('6a1eccda-a70c-41b5-9978-cec0495cfa4f','Daniel','Maldonado','Male','187-95-6145','1964-12-13',122214.74,'4031-7382-4968-2022','American Express','9177901828','Asia-Pacific','358, Brar Path, North Dumdum 007162','2024-01-03 06:34:07'),
('372139f3-5e25-43dd-b65b-9045c5bc647a','Erika','Juarez','Female','493-80-1009','1935-03-04',104182.97,'4596-8351-8217-2537','American Express','8163516356','North America','2818 Dwayne Shoals Blackwellville, KS 66714','2024-03-19 20:44:27'),
('f46d4e1d-c05f-49af-8a5b-257910ed0260','Steven','White','Female','189-04-6110','1978-04-08',125087.00,'4622-9836-8651-1731','Mastercard','8876132656','Asia-Pacific','35/94, Luthra Street Bhilwara-058891','2024-01-14 04:41:18'),
('b56471c8-e15e-46c1-9f08-199927fafa5d','Cynthia','Hill','Female','455-88-6041','1987-12-23',111953.71,'4794-4770-4703-5201','American Express','7210201009','Asia-Pacific','H.No. 936, Chand Chowk Karnal 456194','2024-03-12 12:53:39'),
('6b547c70-0a5b-4380-9d6f-3010c8bec05c','Jake','Miller','Female','838-40-3806','1978-08-04',131063.06,'4302-1805-6503-1728','Visa','7216299221','Europe','852 Baudoux Well Apt. 183 Wattieztown, WI 68657','2024-01-30 10:30:57'),
('968c80b9-534a-4d58-8818-361096a4087e','Kathryn','Yoder','Male','469-54-7203','1936-08-20',25581.51,'4065-8905-7705-5641','Discover','8860902790','Asia-Pacific','90/91 Bhargava Chowk Srikakulam-004381','2024-03-30 09:50:03'),
('6c610ed7-0f13-4e3f-b816-be637fcf8723','Jeffrey','Walker','Female','764-21-6279','1966-03-09',104724.96,'4238-9832-7031-1817','American Express','8190831079','Asia-Pacific','33/43 Goyal Chowk Sambhal 781808','2024-04-14 21:31:14'),
('3d242bf4-5e33-484f-ae4e-9557e9072678','Ricardo','Cohen','Female','432-60-1820','1977-11-24',48232.64,'4746-9123-9649-2081','American Express','7220962689','Asia-Pacific','53, Atwal Road, Ambarnath 843134','2024-01-02 03:15:39'),
('95004140-903f-43f6-a6bd-e4db043c8620','Kristina','Glover','Female','337-28-2104','1975-01-03',88868.44,'4036-6967-9848-4817','American Express','6218628778','North America','260 Jessica Village Apt. 456 Woodsfurt, UT 84700','2024-01-24 12:41:58');


Select * from public.global_customer;

create or replace masking policy credit_masking as (val string) returns string ->
        CASE WHEN val = 'Female' and CURRENT_ROLE() in ('ACCOUNTADMIN') then '****'
                ELSE val END; 

Alter table public.global_customer  modify credit_card_number set masking policy credit_masking;
Alter table public.global_customer   modify column  credit_card_number  unset masking policy ;
use role accountadmin;
use role sysadmin;

--Drop table public.global_customer;
CREATE OR REPLACE TABLE public.global_customer_1 (
    customer_id       STRING,
    first_name        STRING,
    last_name         STRING,
    gender            STRING,
    govt_id           STRING,
    date_of_birth     DATE,
    salary            NUMBER(10, 2),
    credit_card_no    STRING,
    card_type         STRING,
    phone_number      STRING,
    region            STRING,
    address           STRING,
    created_timestamp  TIMESTAMP_NTZ
);
INSERT INTO public.global_customer_1 VALUES
(
    '3d242bf4-5e33-484f-ae4e-9557e9072678',
    'Ricardo',
    'Cohen',
    'Female',
    '432-60-1820',
    '1977-11-24',
    48232.64,
    '4746-9123-9649-2081',
    'American Express',
    '7220962689',
    'Asia-Pacific',
    '53, Atwal Road, Ambarnath 843134',
    '2024-01-02 03:15:39'
),
(
    '95004140-903f-43f6-a6bd-e4db043c8620',
    'Kristina',
    'Glover',
    'Female',
    '337-28-2104',
    '1975-01-03',
    88868.44,
    '4036-6967-9848-4817',
    'American Express',
    '6218628778',
    'North America',
    '260 Jessica Village Apt. 456 Woodsfurt, UT 84700',
    '2024-01-24 12:41:58'
),
(
    '10000000-0000-0000-0000-000000000001',
    'John',
    'Smith',
    'Male',
    '111-22-3333',
    '1985-06-15',
    75000.00,
    '4111-1111-1111-1111',
    'Visa',
    '9876543210',
    'Europe',
    '10 London Street',
    '2024-02-01 10:00:00'
),
(
    '10000000-0000-0000-0000-000000000002',
    'Anita',
    'Sharma',
    'Female',
    '222-33-4444',
    '1990-09-20',
    65000.00,
    '5555-5555-5555-4444',
    'MasterCard',
    '9988776655',
    'Europe',
    'Banjara Hills, Hyderabad',
    '2024-02-02 11:30:00'
);

Select * from public.global_customer_1;
Select current_schema();

--drop masking policy pii_conditional_masking_policy;
CREATE OR REPLACE MASKING POLICY pii_conditional_masking_policy
AS (
    pii_text_string STRING,
    region STRING
)
RETURNS STRING
 ->
    CASE
        WHEN region = 'Europe'
            THEN '***MASKED***'
        ELSE pii_text_string
    END;

ALTER TABLE public.global_customer_1 MODIFY COLUMN govt_id SET MASKING POLICY pii_conditional_masking_policy USING (govt_id, region);

show tables;

describe table public.global_customer;