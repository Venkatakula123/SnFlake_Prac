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

Select * from table(INFER_SCHEMA(location => order_stg , File_format =>  ))