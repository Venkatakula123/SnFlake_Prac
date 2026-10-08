--Find employees whose salary is greater than the previous employee's salary.

use database MOVIELENS;
use schema RAW;
show tables;

Select * from RAW_EMP;
--Select * from emp_1;

with prev_emp as (
Select empno,ENAME,SAL,LEAD(SAL) over(order by empno) as Prev_emp from raw_emp )

Select * from prev_emp where sal > Prev_emp;

with prev_emp as (
Select empno,ENAME,SAL,LAG(SAL) over(order by empno) as Prev_emp from raw_emp )

Select * from prev_emp where sal > Prev_emp;