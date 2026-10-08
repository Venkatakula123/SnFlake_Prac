USE DATABASE MDB;
USE SCHEMA PUBLIC;

SHOW TABLES;

-- 1) Source table: contains the latest data coming from upstream systems
CREATE OR REPLACE TABLE SRC_CUSTOMER (
    CUSTOMER_ID NUMBER,
    CUSTOMER_NAME VARCHAR,
    CITY VARCHAR,
    EMAIL VARCHAR,
    UPDATED_AT TIMESTAMP
);

Select * from SRC_CUSTOMER;
--truncate table SRC_CUSTOMER;

-- 2) Target table: final warehouse table for reporting / downstream use
CREATE OR REPLACE TABLE TGT_CUSTOMER (
    CUSTOMER_ID NUMBER,
    CUSTOMER_NAME VARCHAR,
    CITY VARCHAR,
    EMAIL VARCHAR,
    UPDATED_AT TIMESTAMP,
    DML_OP VARCHAR  -- I = INSERT, U = UPDATE
);

--truncate table TGT_CUSTOMER;

-- 3) Watermark table: stores last successful incremental load time
CREATE OR REPLACE TABLE LOAD_WATERMARK (
    TABLE_NAME VARCHAR,
    LAST_LOADED_AT TIMESTAMP
);
--truncate table LOAD_WATERMARK;

-- Initialize watermark for first run
INSERT INTO LOAD_WATERMARK (TABLE_NAME, LAST_LOADED_AT)
VALUES ('SRC_CUSTOMER', '1900-01-01 00:00:00');

INSERT INTO SRC_CUSTOMER (CUSTOMER_ID, CUSTOMER_NAME, CITY, EMAIL, UPDATED_AT)
VALUES
    (101, 'Ravi', 'Hyderabad', 'ravi@gmail.com', '2026-10-01 10:00:00'),
    (102, 'Kumar', 'Chennai', 'kumar@gmail.com', '2026-10-01 10:05:00'),
    (103, 'Ramesh', 'Bangalore', 'ramesh@gmail.com', '2026-10-01 10:10:00');

-- Incremental load: only fetch rows newer than watermark
MERGE INTO TGT_CUSTOMER t
USING (
    SELECT
        CUSTOMER_ID,
        CUSTOMER_NAME,
        CITY,
        EMAIL,
        UPDATED_AT
    FROM SRC_CUSTOMER
    WHERE UPDATED_AT > (
        SELECT LAST_LOADED_AT
        FROM LOAD_WATERMARK
        WHERE TABLE_NAME = 'SRC_CUSTOMER'
    )
) s
ON t.CUSTOMER_ID = s.CUSTOMER_ID
WHEN MATCHED AND s.updated_at > t.updated_at THEN
    UPDATE SET
        t.CUSTOMER_NAME = s.CUSTOMER_NAME,
        t.CITY = s.CITY,
        t.EMAIL = s.EMAIL,
        t.UPDATED_AT = s.UPDATED_AT,
        t.DML_OP = 'U'
WHEN NOT MATCHED THEN
    INSERT (
        CUSTOMER_ID,
        CUSTOMER_NAME,
        CITY,
        EMAIL,
        UPDATED_AT,
        DML_OP
    )
    VALUES (
        s.CUSTOMER_ID,
        s.CUSTOMER_NAME,
        s.CITY,
        s.EMAIL,
        s.UPDATED_AT,
        'I'
    );

-- Move watermark forward after successful load
UPDATE LOAD_WATERMARK
SET LAST_LOADED_AT = (
    SELECT MAX(UPDATED_AT)
    FROM TGT_CUSTOMER
    WHERE UPDATED_AT > '1900-01-01 00:00:00'
)
WHERE TABLE_NAME = 'SRC_CUSTOMER';

SELECT * FROM TGT_CUSTOMER;
SELECT * FROM LOAD_WATERMARK;

-- ------------------------------------------------------------
-- New incremental batch: insert and update rows after first load
-- ------------------------------------------------------------

UPDATE SRC_CUSTOMER
SET CITY = 'VIJAYAWADA', UPDATED_AT = '2026-10-06 12:00:00'
WHERE CUSTOMER_ID = 105;



-- Final watermark update
/*UPDATE LOAD_WATERMARK
SET LAST_LOADED_AT = (
    SELECT MAX(UPDATED_AT)
    FROM SRC_CUSTOMER
)
WHERE TABLE_NAME = 'SRC_CUSTOMER';*/

/*UPDATE LOAD_WATERMARK
SET LAST_LOADED_AT = TO_DATE('2026-09-30 10:10:00.000')
WHERE TABLE_NAME = 'SRC_CUSTOMER'; */


SELECT * FROM TGT_CUSTOMER ORDER BY CUSTOMER_ID;
SELECT * FROM LOAD_WATERMARK; --2026-10-06 10:15:00.000

INSERT INTO SRC_CUSTOMER (CUSTOMER_ID, CUSTOMER_NAME, CITY, EMAIL, UPDATED_AT)
VALUES
    (104, 'Sita', 'Pune', 'sita@gmail.com', '2026-10-05 09:30:00'),
    (105, 'Prakash', 'Delhi', 'prakash@gmail.com', '2026-10-06 10:10:00'),
    (106, 'Anil', 'Kolkata', 'anil@gmail.com', '2026-10-06 10:15:00');

UPDATE SRC_CUSTOMER
SET CITY = 'VIJAYAWADA', UPDATED_AT = '2026-10-06 12:00:00'
WHERE CUSTOMER_ID = 105;

INSERT INTO SRC_CUSTOMER (CUSTOMER_ID, CUSTOMER_NAME, CITY, EMAIL, UPDATED_AT)
VALUES
    (102, 'Kumar', 'Chennai', 'kumar_new@gmail.com', '2026-10-01 09:00:00');