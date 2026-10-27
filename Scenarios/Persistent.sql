use database MDB;

use schema public;
show tables in schema public;

CREATE OR REPLACE TABLE Orders (
    OrderID NUMBER,
    CustomerID NUMBER,
    OrderDate DATE,
    OrderAmount NUMBER(10,2)
);

INSERT INTO Orders VALUES
(1,101,'2024-07-15',500),
(2,101,'2024-08-10',650),
(3,101,'2024-09-05',450),
(4,101,'2024-10-11',900),
(5,101,'2024-11-20',350),
(6,101,'2024-12-09',780),
(7,101,'2025-01-18',620),
(8,101,'2025-02-03',430),
(9,101,'2025-03-25',580),
(10,101,'2025-04-14',720),
(11,101,'2025-05-19',660),
(12,101,'2025-06-28',510);
INSERT INTO Orders VALUES
(13,101,'2025-07-15',500),
(14,101,'2025-08-10',650),
(15,101,'2025-09-05',450),
(16,101,'2025-10-11',900),
(17,101,'2025-11-20',350),
(18,101,'2025-12-09',780);

INSERT INTO Orders VALUES
(13,102,'2024-07-10',200),
(14,102,'2024-08-12',250),
(15,102,'2024-09-15',300),
(16,102,'2024-10-18',350),
(17,102,'2024-11-21',400),
(18,102,'2024-12-08',450),
(19,102,'2025-01-14',500),
(20,102,'2025-02-17',550),
(21,102,'2025-03-20',600),
(22,102,'2025-04-23',650),
(23,102,'2025-06-11',700);

INSERT INTO Orders VALUES
(24,103,'2024-07-01',100),
(25,103,'2024-07-20',150),
(26,103,'2024-08-07',120),
(27,103,'2024-08-25',140),
(28,103,'2024-09-09',180),
(29,103,'2024-10-13',210),
(30,103,'2024-11-17',230),
(31,103,'2024-12-05',190),
(32,103,'2025-01-07',260),
(33,103,'2025-02-21',270),
(34,103,'2025-03-11',280),
(35,103,'2025-04-15',290),
(36,103,'2025-05-19',300),
(37,103,'2025-06-04',310);

INSERT INTO Orders VALUES
(24,103,'2024-07-01',100),
(25,103,'2024-07-20',150),
(26,103,'2024-08-07',120),
(27,103,'2024-08-25',140),
(28,103,'2024-09-09',180),
(29,103,'2024-10-13',210),
(30,103,'2024-11-17',230),
(31,103,'2024-12-05',190),
(32,103,'2025-01-07',260),
(33,103,'2025-02-21',270),
(34,103,'2025-03-11',280),
(35,103,'2025-04-15',290),
(36,103,'2025-05-19',300),
(37,103,'2025-06-04',310);
INSERT INTO Orders VALUES
(38,104,'2024-09-10',450),
(39,104,'2024-10-12',470),
(40,104,'2024-11-14',490),
(41,104,'2024-12-16',510),
(42,104,'2025-01-18',530),
(43,104,'2025-02-20',550);

Select count(*) from orders;

--Find people who is placing the orders on everymonth in 2025 year

Select customerid,count(*) from orders where ORDERDATE >=  '2025-01-01' and orderdate < '2026-01-01'
group by customerid
Having count(distinct DATE_TRUNC('MONTH',orderdate)) = 12;


---Global Logic
CREATE OR REPLACE TABLE SALES (
    PID NUMBER,
    PNAME VARCHAR(50),
    QUANTITY NUMBER,
    PRICE NUMBER(10,2),
    SELLINGDATE DATE
);

INSERT INTO SALES VALUES
(101,'Laptop',2,500,'2025-01-01'),
(101,'Laptop',1,500,'2025-01-02'),
(101,'Laptop',3,500,'2025-01-03'),
(101,'Laptop',2,500,'2025-01-04'),
(101,'Laptop',4,500,'2025-01-05'),
(101,'Laptop',1,500,'2025-01-06'),
(101,'Laptop',5,500,'2025-01-07'),
(101,'Laptop',2,500,'2025-01-08'),
(101,'Laptop',3,500,'2025-01-09'),
(101,'Laptop',4,500,'2025-01-10'),

(102,'Mobile',5,200,'2025-01-01'),
(102,'Mobile',4,200,'2025-01-02'),
(102,'Mobile',3,200,'2025-01-03'),
(102,'Mobile',6,200,'2025-01-04'),
(102,'Mobile',2,200,'2025-01-05'),
(102,'Mobile',7,200,'2025-01-06'),
(102,'Mobile',5,200,'2025-01-07'),
(102,'Mobile',4,200,'2025-01-08'),
(102,'Mobile',8,200,'2025-01-09'),
(102,'Mobile',3,200,'2025-01-10');

INSERT INTO SALES VALUES
(103,'Tablet',3,300,'2025-01-01'),
(103,'Tablet',5,300,'2025-01-02'),
(103,'Tablet',2,300,'2025-01-03'),
(103,'Tablet',4,300,'2025-01-04'),
(103,'Tablet',6,300,'2025-01-05'),
(103,'Tablet',3,300,'2025-01-06'),
(103,'Tablet',7,300,'2025-01-07'),
(103,'Tablet',5,300,'2025-01-08'),
(103,'Tablet',4,300,'2025-01-09'),
(103,'Tablet',8,300,'2025-01-10'),

(104,'Monitor',2,250,'2025-01-01'),
(104,'Monitor',3,250,'2025-01-02'),
(104,'Monitor',5,250,'2025-01-03'),
(104,'Monitor',4,250,'2025-01-04'),
(104,'Monitor',6,250,'2025-01-05'),
(104,'Monitor',3,250,'2025-01-06'),
(104,'Monitor',7,250,'2025-01-07'),
(104,'Monitor',5,250,'2025-01-08'),
(104,'Monitor',8,250,'2025-01-09'),
(104,'Monitor',4,250,'2025-01-10');

--find 7days moving average for each product using windows function
Select PID,PNAME,SELLINGDATE, avg(quantity) over(partition by pid order by SELLINGDATE) as movingsales  from SALES;

SELECT
    pid,
    pname,
    sellingdate,
    quantity,
    price,
    quantity * price AS sales_amount,

    AVG(quantity * price) OVER (
        PARTITION BY pid
        ORDER BY sellingdate
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ) AS moving_avg_7_days

FROM sales
ORDER BY pid, sellingdate;

SELECT
    pid,
    pname,
    sellingdate,
    AVG(quantity * price) OVER (
        PARTITION BY pid
        ORDER BY sellingdate
        RANGE BETWEEN INTERVAL '2 DAY' PRECEDING
              AND CURRENT ROW
    ) AS moving_avg_7_days
FROM sales;