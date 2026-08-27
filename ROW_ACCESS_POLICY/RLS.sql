use database PUBLIC_DB;
use schema public;

-- Entitlement table
CREATE OR REPLACE TABLE PUBLIC.ROLE_REGION_ACCESS (
    ROLE_NAME   STRING,
    REGION_NAME STRING
);

INSERT INTO PUBLIC.ROLE_REGION_ACCESS VALUES
    ('ANALYST_NA', 'NORTH_AMERICA'),
    ('ANALYST_EU', 'EUROPE');

show schemas;
use schema MYPOLICIES;

create or replace row access policy REGION_RAP as (val string) returns boolean -> 
    CURRENT_ROLE() IN  ('ACCOUNTADMIN', 'SELECT ROLE_NAME from PUBLIC.ROLE_REGION_ACCESS')
    OR EXISTS (
        SELECT 1
        FROM PUBLIC.ROLE_REGION_ACCESS A
        WHERE A.ROLE_NAME = CURRENT_ROLE()
          AND A.REGION_NAME = REGION_NAME
    );

--Alter table PUBLIC.ROLE_REGION_ACCESS ADD row access policy REGION_RAP on (REGION_NAME);

--============================================================================================
CREATE OR REPLACE TABLE PUBLIC.SALES
(
    SALE_ID       NUMBER,
    SALE_DATE     DATE,
    CUSTOMER_NAME VARCHAR,
    REGION        VARCHAR,
    PRODUCT       VARCHAR,
    SALES_AMOUNT  NUMBER(12,2)
);
INSERT INTO PUBLIC.SALES
VALUES
(1, '2026-01-10', 'Customer A', 'EAST',  'Laptop',    5000),
(2, '2026-01-11', 'Customer B', 'EAST',  'Monitor',   2000),
(3, '2026-01-12', 'Customer C', 'WEST',  'Laptop',    7000),
(4, '2026-01-13', 'Customer D', 'WEST',  'Keyboard',  1500),
(5, '2026-01-14', 'Customer E', 'NORTH', 'Laptop',    8000),
(6, '2026-01-15', 'Customer F', 'NORTH', 'Monitor',   2500),
(7, '2026-01-16', 'Customer G', 'SOUTH', 'Laptop',    6000),
(8, '2026-01-17', 'Customer H', 'SOUTH', 'Keyboard',  1200),
(9, '2026-01-18', 'Customer I', 'EAST',  'Mouse',      500),
(10,'2026-01-19', 'Customer J', 'WEST',  'Mouse',       700);

INSERT INTO PUBLIC.SALES
(
    SALE_ID,
    SALE_DATE,
    CUSTOMER_NAME,
    REGION,
    PRODUCT,
    SALES_AMOUNT
)
VALUES
(11, '2026-02-01', 'Customer K', 'EAST',  'Laptop',       5500),
(12, '2026-02-02', 'Customer L', 'WEST',  'Monitor',      2200),
(13, '2026-02-03', 'Customer M', 'NORTH', 'Keyboard',      900),
(14, '2026-02-04', 'Customer N', 'SOUTH', 'Laptop',       6500),
(15, '2026-02-05', 'Customer O', 'EAST',  'Monitor',      2800),
(16, '2026-02-06', 'Customer P', 'WEST',  'Laptop',       7200),
(17, '2026-02-07', 'Customer Q', 'NORTH', 'Mouse',         600),
(18, '2026-02-08', 'Customer R', 'SOUTH', 'Monitor',      2400),
(19, '2026-02-09', 'Customer S', 'EAST',  'Keyboard',     1100),
(20, '2026-02-10', 'Customer T', 'WEST',  'Mouse',         750),

(21, '2026-02-11', 'Customer U', 'NORTH', 'Laptop',       8500),
(22, '2026-02-12', 'Customer V', 'SOUTH', 'Keyboard',     1300),
(23, '2026-02-13', 'Customer W', 'EAST',  'Mouse',         450),
(24, '2026-02-14', 'Customer X', 'WEST',  'Monitor',      2600),
(25, '2026-02-15', 'Customer Y', 'NORTH', 'Monitor',      3000),
(26, '2026-02-16', 'Customer Z', 'SOUTH', 'Laptop',       6800),
(27, '2026-02-17', 'Customer AA', 'EAST', 'Laptop',       5900),
(28, '2026-02-18', 'Customer AB', 'WEST', 'Keyboard',     1250),
(29, '2026-02-19', 'Customer AC', 'NORTH', 'Mouse',        550),
(30, '2026-02-20', 'Customer AD', 'SOUTH', 'Monitor',      2700),

(31, '2026-02-21', 'Customer AE', 'EAST',  'Monitor',      3100),
(32, '2026-02-22', 'Customer AF', 'WEST',  'Laptop',       7600),
(33, '2026-02-23', 'Customer AG', 'NORTH', 'Keyboard',     1400),
(34, '2026-02-24', 'Customer AH', 'SOUTH', 'Mouse',         650),
(35, '2026-02-25', 'Customer AI', 'EAST',  'Laptop',       6100),
(36, '2026-02-26', 'Customer AJ', 'WEST',  'Monitor',      2900),
(37, '2026-02-27', 'Customer AK', 'NORTH', 'Laptop',       9000),
(38, '2026-02-28', 'Customer AL', 'SOUTH', 'Keyboard',     1500),
(39, '2026-03-01', 'Customer AM', 'EAST',  'Mouse',         800),
(40, '2026-03-02', 'Customer AN', 'WEST',  'Laptop',       8100);
INSERT INTO PUBLIC.SALES
(
    SALE_ID,
    SALE_DATE,
    CUSTOMER_NAME,
    REGION,
    PRODUCT,
    SALES_AMOUNT
)
VALUES
-- EAST
(41, '2026-03-03', 'Customer AO', 'EAST',  'Desktop',        4800),
(42, '2026-03-04', 'Customer AP', 'EAST',  'Printer',        3200),
(43, '2026-03-05', 'Customer AQ', 'EAST',  'Tablet',         4100),
(44, '2026-03-06', 'Customer AR', 'EAST',  'Headset',         850),
(45, '2026-03-07', 'Customer AS', 'EAST',  'Webcam',          700),
(46, '2026-03-08', 'Customer AT', 'EAST',  'Docking Station', 1800),
(47, '2026-03-09', 'Customer AU', 'EAST',  'Smartphone',      6200),
(48, '2026-03-10', 'Customer AV', 'EAST',  'External SSD',    1600),

-- WEST
(49, '2026-03-03', 'Customer AW', 'WEST',  'Desktop',        5200),
(50, '2026-03-04', 'Customer AX', 'WEST',  'Printer',        3500),
(51, '2026-03-05', 'Customer AY', 'WEST',  'Tablet',         3900),
(52, '2026-03-06', 'Customer AZ', 'WEST',  'Headset',         950),
(53, '2026-03-07', 'Customer BA', 'WEST',  'Webcam',          800),
(54, '2026-03-08', 'Customer BB', 'WEST',  'Docking Station', 2100),
(55, '2026-03-09', 'Customer BC', 'WEST',  'Smartphone',      6800),
(56, '2026-03-10', 'Customer BD', 'WEST',  'External SSD',    1750),

-- NORTH
(57, '2026-03-03', 'Customer BE', 'NORTH', 'Desktop',        5100),
(58, '2026-03-04', 'Customer BF', 'NORTH', 'Printer',        3000),
(59, '2026-03-05', 'Customer BG', 'NORTH', 'Tablet',         4300),
(60, '2026-03-06', 'Customer BH', 'NORTH', 'Headset',        1050),
(61, '2026-03-07', 'Customer BI', 'NORTH', 'Webcam',          750),
(62, '2026-03-08', 'Customer BJ', 'NORTH', 'Docking Station', 1950),
(63, '2026-03-09', 'Customer BK', 'NORTH', 'Smartphone',      6400),
(64, '2026-03-10', 'Customer BL', 'NORTH', 'External SSD',    1550),

-- SOUTH
(65, '2026-03-03', 'Customer BM', 'SOUTH', 'Desktop',        4900),
(66, '2026-03-04', 'Customer BN', 'SOUTH', 'Printer',        3300),
(67, '2026-03-05', 'Customer BO', 'SOUTH', 'Tablet',         4500),
(68, '2026-03-06', 'Customer BP', 'SOUTH', 'Headset',         900),
(69, '2026-03-07', 'Customer BQ', 'SOUTH', 'Webcam',          720),
(70, '2026-03-08', 'Customer BR', 'SOUTH', 'Docking Station', 2050);

INSERT INTO PUBLIC.SALES
(
    SALE_ID,
    SALE_DATE,
    CUSTOMER_NAME,
    REGION,
    PRODUCT,
    SALES_AMOUNT
)
VALUES
-- EAST
(71, '2026-03-11', 'Customer BS', 'EAST', 'Smart TV',          7200),
(72, '2026-03-12', 'Customer BT', 'EAST', 'Gaming Console',   5500),
(73, '2026-03-13', 'Customer BU', 'EAST', 'Projector',         4300),
(74, '2026-03-14', 'Customer BV', 'EAST', 'Router',             950),
(75, '2026-03-15', 'Customer BW', 'EAST', 'WiFi Extender',      650),
(76, '2026-03-16', 'Customer BX', 'EAST', 'Power Bank',         450),
(77, '2026-03-17', 'Customer BY', 'EAST', 'Bluetooth Speaker',  850),
(78, '2026-03-18', 'Customer BZ', 'EAST', 'Smart Watch',       2800),

-- WEST
(79, '2026-03-11', 'Customer CA', 'WEST', 'Smart TV',          7800),
(80, '2026-03-12', 'Customer CB', 'WEST', 'Gaming Console',   6200),
(81, '2026-03-13', 'Customer CC', 'WEST', 'Projector',         4700),
(82, '2026-03-14', 'Customer CD', 'WEST', 'Router',            1100),
(83, '2026-03-15', 'Customer CE', 'WEST', 'WiFi Extender',      750),
(84, '2026-03-16', 'Customer CF', 'WEST', 'Power Bank',         500),
(85, '2026-03-17', 'Customer CG', 'WEST', 'Bluetooth Speaker',  950),
(86, '2026-03-18', 'Customer CH', 'WEST', 'Smart Watch',       3100),

-- NORTH
(87, '2026-03-11', 'Customer CI', 'NORTH', 'Smart TV',          6900),
(88, '2026-03-12', 'Customer CJ', 'NORTH', 'Gaming Console',   5800),
(89, '2026-03-13', 'Customer CK', 'NORTH', 'Projector',         4500),
(90, '2026-03-14', 'Customer CL', 'NORTH', 'Router',             900),
(91, '2026-03-15', 'Customer CM', 'NORTH', 'WiFi Extender',      700),
(92, '2026-03-16', 'Customer CN', 'NORTH', 'Power Bank',         400),
(93, '2026-03-17', 'Customer CO', 'NORTH', 'Bluetooth Speaker',  880),
(94, '2026-03-18', 'Customer CP', 'NORTH', 'Smart Watch',       2950),

-- SOUTH
(95, '2026-03-11', 'Customer CQ', 'SOUTH', 'Smart TV',          7500),
(96, '2026-03-12', 'Customer CR', 'SOUTH', 'Gaming Console',   6000),
(97, '2026-03-13', 'Customer CS', 'SOUTH', 'Projector',         4900),
(98, '2026-03-14', 'Customer CT', 'SOUTH', 'Router',            1050),
(99, '2026-03-15', 'Customer CU', 'SOUTH', 'WiFi Extender',      720),
(100,'2026-03-16', 'Customer CV', 'SOUTH', 'Power Bank',         480);

Select * from PUBLIC.SALES;

CREATE OR REPLACE ROLE EAST_MANAGER;

CREATE OR REPLACE ROLE WEST_MANAGER;

CREATE OR REPLACE ROLE NORTH_MANAGER;

CREATE OR REPLACE ROLE SOUTH_MANAGER;

CREATE OR REPLACE ROLE EXECUTIVE;

GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE  EAST_MANAGER;
GRANT USAGE ON DATABASE PUBLIC_DB TO ROLE EAST_MANAGER;
GRANT USAGE ON SCHEMA PUBLIC_DB.PUBLIC TO ROLE EAST_MANAGER;
GRANT SELECT ON TABLE PUBLIC_DB.PUBLIC.SALES TO ROLE EAST_MANAGER;

grant role EAST_MANAGER to role SYSADMIN;
grant role WEST_MANAGER to role SYSADMIN;
grant role SOUTH_MANAGER to role SYSADMIN;
grant role NORTH_MANAGER to role SYSADMIN;
grant role EXECUTIVE to role SYSADMIN;

GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE  WEST_MANAGER;
GRANT USAGE ON DATABASE PUBLIC_DB TO ROLE WEST_MANAGER;
GRANT USAGE ON SCHEMA PUBLIC_DB.PUBLIC TO ROLE WEST_MANAGER;
GRANT SELECT ON TABLE PUBLIC_DB.PUBLIC.SALES TO ROLE WEST_MANAGER;

GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE  SOUTH_MANAGER;
GRANT USAGE ON DATABASE PUBLIC_DB TO ROLE SOUTH_MANAGER;
GRANT USAGE ON SCHEMA PUBLIC_DB.PUBLIC TO ROLE SOUTH_MANAGER;
GRANT SELECT ON TABLE PUBLIC_DB.PUBLIC.SALES TO ROLE SOUTH_MANAGER;

GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE  NORTH_MANAGER;
GRANT USAGE ON DATABASE PUBLIC_DB TO ROLE NORTH_MANAGER;
GRANT USAGE ON SCHEMA PUBLIC_DB.PUBLIC TO ROLE NORTH_MANAGER;
GRANT SELECT ON TABLE PUBLIC_DB.PUBLIC.SALES TO ROLE NORTH_MANAGER;

GRANT USAGE ON WAREHOUSE COMPUTE_WH TO ROLE  EXECUTIVE;
GRANT USAGE ON DATABASE PUBLIC_DB TO ROLE EXECUTIVE;
GRANT USAGE ON SCHEMA PUBLIC_DB.PUBLIC TO ROLE EXECUTIVE;
GRANT SELECT ON TABLE PUBLIC_DB.PUBLIC.SALES TO ROLE EXECUTIVE;

SELECT CURRENT_SCHEMA();
--CREATING ROW ACCESS POLICY and APPLYING THE POLICY ON DATA FOR INDIVIDUAL 
CREATE OR REPLACE ROW ACCESS POLICY SEC_RPOLICY AS(REGION STRING) RETURNS BOOLEAN -> 
    CASE    WHEN IS_ROLE_IN_SESSION('EXECUTIVE') THEN TRUE
            WHEN IS_ROLE_IN_SESSION('EAST_MANAGER') THEN REGION = 'EAST'
            WHEN IS_ROLE_IN_SESSION('WEST_MANAGER') THEN REGION = 'WEST'
            WHEN IS_ROLE_IN_SESSION('SOUTH_MANAGER') THEN REGION = 'SOUTH'
            WHEN IS_ROLE_IN_SESSION('NORTH_MANAGER') THEN REGION = 'NORTH' 
        ELSE FALSE
        END;

ALTER TABLE PUBLIC.SALES ADD ROW ACCESS POLICY SEC_RPOLICY ON(REGION);

--CREATING THE MULTIPLE USERS AND ASSIGING THE REOLES TO THEM 
CREATE USER ESALES PASSWORD = 'BJAAK9ceJQmQTY7' default_role = 'EAST_MANAGER';
CREATE USER WSALES PASSWORD = 'BJAAK9ceJQmQTY7' default_role = 'WEST_MANAGER';
CREATE USER NSALES PASSWORD = 'BJAAK9ceJQmQTY7' default_role = 'NORTH_MANAGER';
CREATE USER SSALES PASSWORD = 'BJAAK9ceJQmQTY7' default_role = 'SOUTH_MANAGER';
CREATE USER EXSALES PASSWORD = 'BJAAK9ceJQmQTY7' default_role = 'EXECUTIVE'; 

GRANT ROLE EAST_MANAGER TO USER ESALES;
GRANT ROLE WEST_MANAGER TO USER WSALES;
GRANT ROLE NORTH_MANAGER TO USER NSALES;
GRANT ROLE SOUTH_MANAGER TO USER SSALES;
GRANT ROLE EXECUTIVE TO USER EXSALES;

