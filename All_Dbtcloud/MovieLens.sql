use database MOVIELENS;

use schema RAW;
show tables in schema RAW;

select * from dept;

describe table emp;

show schemas;

use schema ST;

show stages;

create or replace stage order_stg;

LIST @order_stg;

Select  $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14 from @order_stg/orders_data.csv;

Select * from table(INFER_SCHEMA(location => order_stg , File_format =>  ));

Select * from Sales2sql;
Select * from Sales1;
Select * from Sales5;

Select * from RAW.sales;
INSERT INTO RAW.sales (sale_amount, sale_status, amount, customer_id, product_id, sale_timestamp)
VALUES 
    (150.00, 'completed', 150.00, 1, 101, CURRENT_TIMESTAMP()),
    (200.50, 'pending', 200.50, 2, 102, CURRENT_TIMESTAMP()),
    (75.25, 'completed', 75.25, 3, 103, CURRENT_TIMESTAMP()),
    (325.00, 'cancelled', 325.00, 4, 104, CURRENT_TIMESTAMP());

Update RAW.sales set amount = 5000.00 where sale_ID = 110;