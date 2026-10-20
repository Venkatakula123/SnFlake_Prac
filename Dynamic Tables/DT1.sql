show warehouses;

use warehouse compute_wh;

show databases;

create or replace database MDB;
create schema DT;
use schema DT;

Select current_database();
Select current_schema();

--drop table raw_orders;
CREATE OR REPLACE TABLE public.raw_orders (
    order_id       NUMBER(38,0)      NOT NULL,
    customer_id    NUMBER(38,0)      NOT NULL,
    order_date     DATE              NOT NULL,
    product_name   VARCHAR(500),
    quantity       NUMBER(18,0),
    unit_price     NUMBER(18,4),
    order_status   VARCHAR(100)
);


# SCD Type 2 in Snowflake Using MERGE

In Snowflake, you can implement SCD Type 2 using a single `MERGE` statement by making changed source rows match the target once to expire the old record, then appear as unmatched rows to insert the new version.

Important: A standard `MERGE` cannot update an existing row and insert a second row for the same source row in one matched branch. The common solution is to use a staging subquery that duplicates changed source rows, with one copy to expire the old version and another to insert the new version.

## 1. Example scenario

Staging table: `STG_EMPLOYEE`

| EMP\_ID | EMP\_NAME | DEPARTMENT | SALARY |
| --- | --- | --- | --- |
| 101 | Ravi | IT | 50000 |
| 102 | Priya | HR | 60000 |
| 103 | Arun | IT | 55000 |

Target table: `DIM_EMPLOYEE`

| EMP\_ID | EMP\_NAME | DEPARTMENT | SALARY | IS\_CURRENT |
| --- | --- | --- | --- | --- |
| 101 | Ravi | IT | 45000 | TRUE |
| 102 | Priya | HR | 60000 | TRUE |

Expected behavior:

- Employee 101: expire the old salary record and insert the new salary.
- Employee 102: no change.
- Employee 103: insert a new employee record.

## 2. Snowflake MERGE query for SCD Type 2

sql
```
MERGE INTO DIM_EMPLOYEE AS TGT
USING (
    -- Row 1: Expire the old version of changed employees
    SELECT
        SRC.EMP_ID,S
        SRC.EMP_NAME,
        SRC.DEPARTMENT,
        SRC.SALARY,
        SRC.EMP_ID AS MERGE_KEY,
        'EXPIRE' AS ACTION
    FROM STG_EMPLOYEE SRC
    JOIN DIM_EMPLOYEE T
        ON SRC.EMP_ID = T.EMP_ID
       AND T.IS_CURRENT = TRUE
    WHERE SRC.EMP_NAME IS DISTINCT FROM T.EMP_NAME
       OR SRC.DEPARTMENT IS DISTINCT FROM T.DEPARTMENT
       OR SRC.SALARY IS DISTINCT FROM T.SALARY

    UNION ALL

    -- Row 2: Insert a new version for changed or new employees
    SELECT
        SRC.EMP_ID,
        SRC.EMP_NAME,
        SRC.DEPARTMENT,
        SRC.SALARY,
        NULL::NUMBER AS MERGE_KEY,
        'INSERT' AS ACTION
    FROM STG_EMPLOYEE SRC
    LEFT JOIN DIM_EMPLOYEE T
        ON SRC.EMP_ID = T.EMP_ID
       AND T.IS_CURRENT = TRUE
    WHERE T.EMP_ID IS NULL
       OR SRC.EMP_NAME IS DISTINCT FROM T.EMP_NAME
       OR SRC.DEPARTMENT IS DISTINCT FROM T.DEPARTMENT
       OR SRC.SALARY IS DISTINCT FROM T.SALARY
) AS SRC

ON TGT.EMP_ID = SRC.MERGE_KEY
AND TGT.IS_CURRENT = TRUE

WHEN MATCHED AND SRC.ACTION = 'EXPIRE' THEN
    UPDATE SET
        TGT.END_DATE = DATEADD(DAY, -1, CURRENT_DATE()),
        TGT.IS_CURRENT = FALSE

WHEN NOT MATCHED AND SRC.ACTION = 'INSERT' THEN
    INSERT (
        EMP_ID,
        EMP_NAME,
        DEPARTMENT,
        SALARY,
        START_DATE,
        END_DATE,
        IS_CURRENT
    )
    VALUES (
        SRC.EMP_ID,
        SRC.EMP_NAME,
        SRC.DEPARTMENT,
        SRC.SALARY,
        CURRENT_DATE(),
        '9999-12-31'::DATE,
        TRUE
    );
```

## 3. How the MERGE works

## 1

Source identifies changed employees

The first query creates an `EXPIRE` row. The second creates an `INSERT` row for changed employees and new employees.

## 2

MERGE expires the old version

`MERGE_KEY = EMP_ID` matches the current target row, so `IS_CURRENT` becomes `FALSE`.

## 3

MERGE inserts the new version

`MERGE_KEY = NULL` does not match the target employee ID, so the `INSERT` action creates a new current record.

## 4. Expected output

For employee 101, whose salary changes from 45,000 to 50,000:

| EMP\_ID | SALARY | IS\_CURRENT |
| --- | --- | --- |
| 101 | 45000 | FALSE |
| 101 | 50000 | TRUE |

Employee 102 remains unchanged, and employee 103 is inserted as a new current record.

Important: This pattern assumes one source row per employee and one current target row per employee. The `MERGE` source intentionally has two rows for changed employees, but only one row matches the current target. For production loads, also account for effective timestamps, repeated same-day loads, and transaction or orchestration safeguards.
