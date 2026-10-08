/*
    1. We have the tables Customer_transaction  and we inserted Some data after creation of Stream object
    2. Created stream object on the Above source table
    3. Again we used create or replace table  Customer_transaction 
    4. What is the stream Object behaviour Here 
 */

 use database MDB;
 show schemas;
use schema public;

CREATE OR REPLACE TABLE customer_transactions (
    transaction_id INT,
    customer_id INT,
    customer_name STRING,
    amount DECIMAL(10, 2),
    transaction_date DATE
);

INSERT INTO customer_transactions VALUES
-- Customer 101: Rahul (Qualifies: 3 transactions, total > ₹50,000 in Aug 2026)
(1, 101, 'Rahul Sharma', 22000.00, '2026-08-05'),
(2, 101, 'Rahul Sharma', 18000.00, '2026-08-12'),
(3, 101, 'Rahul Sharma', 15000.00, '2026-08-25'),

-- Customer 102: Priya (Does not qualify: only 2 transactions, even though total > ₹50,000)
(4, 102, 'Priya Patel', 30000.00, '2026-08-02'),
(5, 102, 'Priya Patel', 25000.00, '2026-08-15'),

-- Customer 103: Amit (Does not qualify: 4 transactions, but total is under ₹50,000)
(6, 103, 'Amit Kumar', 5000.00, '2026-08-01'),
(7, 103, 'Amit Kumar', 8000.00, '2026-08-10'),
(8, 103, 'Amit Kumar', 10000.00, '2026-08-18'),
(9, 103, 'Amit Kumar', 6000.00, '2026-08-28'),

-- Customer 104: Sneha (Qualifies: 4 transactions, total well over ₹50,000 in Aug 2026)
(10, 104, 'Sneha Reddy', 15000.00, '2026-08-03'),
(11, 104, 'Sneha Reddy', 20000.00, '2026-08-11'),
(12, 104, 'Sneha Reddy', 12000.00, '2026-08-20'),
(13, 104, 'Sneha Reddy', 10000.00, '2026-08-30'),

-- Out of scope: July 2026 transaction (should be ignored by the filter)
(14, 101, 'Rahul Sharma', 50000.00, '2026-07-15');

Select * from customer_transactions;

--Creating stream object 
Create or replace stream mdb.strm.custstrm on table customer_transactions;
Select * from mdb.strm.custstrm;

INSERT INTO customer_transactions VALUES
-- Customer 105: Vikram (Does not qualify: Exactly ₹50,000 total across 3 transactions—fails the "more than ₹50,000" condition)
(15, 105, 'Vikram Malhotra', 15000.00, '2026-08-04'),
(16, 105, 'Vikram Malhotra', 15000.00, '2026-08-14'),
(17, 105, 'Vikram Malhotra', 20000.00, '2026-08-24');

-- Customer 106: Ananya (Qualifies: Exactly 3 transactions totaling ₹51,000 in August 2026)
(18, 106, 'Ananya Das', 17000.00, '2026-08-06'),
(19, 106, 'Ananya Das', 17000.00, '2026-08-16'),
(20, 106, 'Ananya Das', 17000.00, '2026-08-26'),

-- Customer 107: Rohit (Does not qualify: Has 5 transactions total, but 2 are in September. Only 3 fall in August, and their August sum is only ₹40,000)
(21, 107, 'Rohit Verma', 15000.00, '2026-08-10'),
(22, 107, 'Rohit Verma', 15000.00, '2026-08-20'),
(23, 107, 'Rohit Verma', 10000.00, '2026-08-31'),
(24, 107, 'Rohit Verma', 25000.00, '2026-09-02'),
(25, 107, 'Rohit Verma', 25000.00, '2026-09-05');

--Show tables in schema public
Show tables in schema public;

SELECT 
    TABLE_CATALOG,
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_ID,
    TABLE_SCHEMA_ID,
    TABLE_CATALOG_ID,
    CREATED,
    DELETED
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLES  where TABLE_NAME like '%customer_transactions%';

create or replace table customer_transactions_cln clone customer_transactions;

Select * from customer_transactions_cln;

SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE TABLE_NAME like '%customer_transactions%';
  AND TABLE_DROPPED IS NULL;


--Again I am executing the below command to find the stream object behaviour
CREATE OR REPLACE TABLE customer_transactions (
    transaction_id INT,
    customer_id INT,
    customer_name STRING,
    amount DECIMAL(10, 2),
    transaction_date DATE
);

--Query the stream Object has already changed data we have in stream 
Select * from mdb.strm.custstrm;  //Here we didn't insert the data on the source table before checking the stream object 

--Now we are inserting the data on Source table
INSERT INTO customer_transactions VALUES
-- Customer 101: Rahul (Qualifies: 3 transactions, total > ₹50,000 in Aug 2026)
(1, 101, 'Rahul Sharma', 22000.00, '2026-08-05'),
(2, 101, 'Rahul Sharma', 18000.00, '2026-08-12'),
(3, 101, 'Rahul Sharma', 15000.00, '2026-08-25');

//After inserting the data on Source table again we are querying the Stream object 

Select * from mdb.strm.custstrm; 

Show tables;
-- Step 0: Initial Setup
CREATE OR REPLACE TABLE emp_1 (
    emp_id       INT,
    emp_name     STRING,
    department   STRING,
    salary       NUMBER(10, 2),
    hire_date    DATE
);

-- Target table for consuming CDC records
CREATE OR REPLACE TABLE emp_target LIKE emp_1;

--"If I run SELECT * FROM my_stream; 10 times, will the stream become empty? When exactly does the stream advance its offset?"
-- 1. Create a standard stream
CREATE OR REPLACE STREAM strm.emp_strm ON TABLE emp_1;

-- 2. Insert a record into the base table
INSERT INTO emp_1 VALUES (101, 'Alice Smith', 'Engineering', 95000.00, '2024-01-15');

-- 3. Query the stream multiple times (Offset DOES NOT advance)
SELECT * FROM strm.emp_strm;
SELECT * FROM strm.emp_strm; -- Alice is STILL here!

-- 4. Consume the stream in a DML operation (Offset ADVANCES upon COMMIT)
INSERT INTO emp_target (emp_id, emp_name, department, salary, hire_date)
SELECT emp_id, emp_name, department, salary, hire_date 
FROM strm.emp_strm;

-- 5. Query the stream again (Now it is EMPTY)
SELECT * FROM strm.emp_strm; -- Returns 0 rows

describe stream strm.emp_strm;
--=========================================================================================
--scenario:2 "Suppose row ID = 10 is inserted at 10:00 AM. At 10:05 AM, it is updated. At 10:10 AM, it is deleted. The stream has not been consumed yet. What will SELECT * FROM my_stream; return?"
INSERT INTO emp_1 VALUES (102, 'Bob Jones', 'HR', 60000.00, '2024-02-01');
UPDATE emp_1 SET salary = 65000.00 WHERE emp_id = 102;
DELETE FROM emp_1 WHERE emp_id = 102;

Select * from emp_1;
SELECT * FROM strm.emp_strm;
