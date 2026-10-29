Order_id , customer_id , date
O1 , C1 , 2024-01-01
O2, C1 , 2024-01-10
O3 , C1 , 2024-01-17
O4, C1 , 2024-01-24
 
Customer with order for continues 4 weeks;

show tables in schema public;
CREATE OR REPLACE TABLE ORDERS (
    ORDER_ID VARCHAR(10),
    CUSTOMER_ID VARCHAR(10),
    ORDER_DATE DATE
);

INSERT INTO ORDERS VALUES
('O1', 'C1', '2024-01-01'),
('O2', 'C1', '2024-01-10'),
('O3', 'C1', '2024-01-17'),
('O4', 'C1', '2024-01-24');

--Find the difference between the consecutive Orders.
WITH CTE AS (Select order_id,
                    CUSTOMER_ID,
                    ORDER_DATE, 
                    LAG(ORDER_DATE) over(PARTITION BY CUSTOMER_ID order by ORDER_DATE) as pre_order_date from Orders),
DATEDIFF(                    
    Select order_id,CUSTOMER_ID,order_date,pre_order_date,DATEDIFF(DAY,pre_order_date,ORDER_DATE) as diff, DATE_TRUNC('WEEK',ORDER_DATE)::DATE as week_start_date from CTE
),
GROUPWEEKS (
    Select Customer_id,week_start_date
);

--=====================================
WITH WEEKLY_ORDERS AS (
    SELECT DISTINCT
        CUSTOMER_ID,
        DATE_TRUNC('WEEK', ORDER_DATE)::DATE AS WEEK_START_DATE
    FROM ORDERS
),
NUMBERED_WEEKS AS (
    SELECT
        CUSTOMER_ID,
        WEEK_START_DATE,
        ROW_NUMBER() OVER (
            PARTITION BY CUSTOMER_ID
            ORDER BY WEEK_START_DATE
        ) AS RN
    FROM WEEKLY_ORDERS
),
GROUPED_WEEKS AS (
    SELECT
        CUSTOMER_ID,
        WEEK_START_DATE,
        DATEADD(WEEK, -RN, WEEK_START_DATE) AS WEEK_GROUP
    FROM NUMBERED_WEEKS
)
SELECT
    CUSTOMER_ID,
    COUNT(*) AS CONSECUTIVE_WEEKS
FROM GROUPED_WEEKS
GROUP BY CUSTOMER_ID, WEEK_GROUP
HAVING COUNT(*) >= 4;

--===========================================================================

Create table a(ID NUMBER);
Create table b(id number);
INSERT INTO A VALUES(1),(2),(3),(4),(5);
INSERT INTO B Values(4),(5),(6),(7),(8),(9);

Select ID from a minus Select ID from b; -- Missing Elements from the First Table a 1,2,3
Select ID from a INTERSECT Select ID from b; --Common Elements from Both the Table 4,5
Select ID from a union Select ID from b; -- Unique Records from the Both Tables 
Select ID from a union all Select ID from b; -- All Elements from the Both Tables

--We need all Elements that are uncommon records from the both Tables;

with cte as(
Select id from a minus select id from b),
cte1 as(
Select id from b minus select id from a)
Select id from cte union Select id from cte1 order by id asc;

Select COALESCE(a.id,b.id) from A a full outer join B b ON a.id = b.id where a.id is null or  b.id is null ORDER BY COALESCE(a.id, b.id);


--================================================================================
/*
date	sales
2023-01-10	1000
2023-02-15	1500
2023-04-20	2000
2023-05-10	1800
2023-08-05	2500
2023-11-12	3000
2024-02-14	1200
2024-07-18	2700
 
 
Write an SQL query to display total sales per quarter for each year, with separate columns for Q1, Q2, Q3, and Q4 — similar to the output shown below.*/
CREATE OR REPLACE TABLE QUARTERLY_SALES (
    SALES_DATE DATE,
    SALES      NUMBER(10, 2)
);
INSERT INTO QUARTERLY_SALES (SALES_DATE, SALES) VALUES
    ('2023-01-10', 1000),
    ('2023-02-15', 1500),
    ('2023-04-20', 2000),
    ('2023-05-10', 1800),
    ('2023-08-05', 2500),
    ('2023-11-12', 3000),
    ('2024-02-14', 1200),
    ('2024-07-18', 2700);


Select SALES_DATE,SALES, YEAR(SALES_DATE) as year, QUARTER(SALES_DATE) as qu from QUARTERLY_SALES;

Select  YEAR(SALES_DATE) as YEAR,
        SUM(IFF(QUARTER(SALES_DATE) = 1,SALES,null)) as Q1,
        SUM(IFF(QUARTER(SALES_DATE) = 2,SALES,null)) as Q2,
        SUM(IFF(QUARTER(SALES_DATE) = 3,SALES,null)) as Q3,
        SUM(IFF(QUARTER(SALES_DATE) = 4,SALES,null)) as q4 from QUARTERLY_SALES group by year ;

Select  YEAR(SALES_DATE),
        DECODE(QUARTER(SALES_DATE),1,SALES,0) as q1,
        DECODE(QUARTER(SALES_DATE),2,SALES,0) as q2,
        DECODE(QUARTER(SALES_DATE),3,SALES,0) as Q3 from QUARTERLY_SALES;

CREATE OR REPLACE TABLE PAYMENTS (
    TRANSACTION_ID NUMBER,
    PAYMENT_CODE   NUMBER,
    AMOUNT         NUMBER(10, 2)
);

INSERT INTO PAYMENTS VALUES
    (101, 1, 25.50),
    (102, 2, 80.00),
    (103, 3, 14.99),
    (104, 2, 42.75),
    (105, 9, 10.00);

Select TRANSACTION_ID,DECODE(PAYMENT_CODE,1,'CASH',2,'Credit Card',3,'Wallet') as Payment,AMOUNT from PAYMENTS;


