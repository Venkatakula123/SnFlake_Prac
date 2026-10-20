show databases;

use database MDB;
use schema public;

create or replace schema scd;
use schema scd;
--drop schema scd;
create or replace table nation (
   n_nationkey number,
   n_name varchar(25),
   n_regionkey number,
   n_comment varchar(20000),
   country_code varchar(2),
   update_timestamp timestamp_ntz );
--drop table nation;

create or replace table nation_history (
   n_nationkey number,
   n_name varchar(25),
   n_regionkey number,
   n_comment varchar(152),
   country_code varchar(2),
   start_time timestamp_ntz,
   end_time timestamp_ntz,
   current_flag int);

create or replace stream nation_table_changes on table nation;
show streams;
Select * from nation_table_changes;

create or replace view nation_change_data as
-- This subquery figures out what to do when data is inserted into the NATION table
-- An insert to the NATION table results in an INSERT to the NATION_HISTORY table
select n_nationkey, n_name, n_regionkey, n_comment,
country_code, start_time, end_time, current_flag, 'I' as dml_type
from (
        select n_nationkey, n_name, n_regionkey, n_comment, country_code,
            update_timestamp as start_time,
            lag(update_timestamp) over (partition by n_nationkey order by update_timestamp desc) as end_time_raw,
            case when end_time_raw is null then '9999-12-31'::timestamp_ntz else end_time_raw end as end_time,
            case when end_time_raw is null then 1 else 0 end as current_flag
     from (
            select n_nationkey, n_name, n_regionkey, n_comment, country_code, update_timestamp
           from nation_table_changes
           where metadata$action = 'INSERT'
           and metadata$isupdate = 'FALSE'))
union
-- This subquery figures out what to do when data is updated in the NATION table
-- An update to the NATION table results in an update AND an insert to the NATION_HISTORY table
-- The subquery below generates two records, each with a different dml_type
        select n_nationkey, n_name, n_regionkey, n_comment, country_code, start_time, end_time, current_flag, dml_type
        from (
                select n_nationkey, n_name, n_regionkey, n_comment, country_code,
                        update_timestamp as start_time,
                        lag(update_timestamp) over (partition by n_nationkey order by update_timestamp desc) as end_time_raw,
                        case when end_time_raw is null then '9999-12-31'::timestamp_ntz else end_time_raw end as end_time,
                        case when end_time_raw is null then 1 else 0 end as current_flag, dml_type
     from (-- Identify data to insert into nation_history table
                select n_nationkey, n_name, n_regionkey, n_comment, country_code, update_timestamp, 'I' as dml_type
                        from nation_table_changes
                        where metadata$action = 'INSERT'
                        and metadata$isupdate = 'TRUE'
                union
                        -- Identify data in NATION_HISTORY table that needs to be updated
                        select n_nationkey, null, null, null, null, start_time, 'U' as dml_type
                        from nation_history
                        where n_nationkey in (
                                                select distinct n_nationkey
                                                from nation_table_changes
                                                where metadata$action = 'INSERT'
                                                and metadata$isupdate = 'TRUE')
                                                and current_flag = 1))
                union
                -- This subquery figures out what to do when data is deleted from the NATION table
                -- A deletion from the NATION table results in an update to the NATION_HISTORY table
                select nms.n_nationkey, null, null, null, null, nh.start_time, current_timestamp()::timestamp_ntz, null, 'D'
                from nation_history nh
                inner join nation_table_changes nms
                on nh.n_nationkey = nms.n_nationkey
                where nms.metadata$action = 'DELETE'
                and   nms.metadata$isupdate = 'FALSE'
                and   nh.current_flag = 1;


ALTER SESSION SET MULTI_STATEMENT_COUNT = 0;
set update_timestamp = current_timestamp()::timestamp_ntz;
Select $update_timestamp;


insert into nation values(0,'ALGERIA',0,' haggle. carefully final deposits detect slyly agai','DZ',$update_timestamp);
insert into nation values(1,'ARGENTINA',1,'al foxes promise slyly according to the regular accounts. bold requests alon','AR',$update_timestamp);
insert into nation values(2,'BRAZIL',1,'y alongside of the pending deposits. carefully special packages are about the ironic forges. slyly special ','BR',$update_timestamp);
insert into nation values(3,'CANADA',1,'eas hang ironic silent packages. slyly regular packages are furiously over the tithes. fluffily bold','CA',$update_timestamp);
insert into nation values(4,'EGYPT',4,'y above the carefully unusual theodolites. final dugouts are quickly across the furiously regular d','EG',$update_timestamp);
insert into nation values(5,'ETHIOPIA',0,'ven packages wake quickly. regu','ET',$update_timestamp);
insert into nation values(6,'FRANCE',3,'refully final requests. regular ironi','FR',$update_timestamp);
insert into nation values(7,'GERMANY',3,'l platelets. regular accounts x-ray: unusual regular acco','DE',$update_timestamp);
insert into nation values(8,'INDIA',2,'ss excuses cajole slyly across the packages. deposits print aroun','IN',$update_timestamp);
insert into nation values(9,'INDONESIA',2,' slyly express asymptotes. regular deposits haggle slyly. carefully ironic hockey players sleep blithely. carefull','ID',$update_timestamp);
insert into nation values(10,'IRAN',4,'efully alongside of the slyly final dependencies. ','IR',$update_timestamp);
insert into nation values(11,'IRAQ',4,'nic deposits boost atop the quickly final requests? quickly regula','IQ',$update_timestamp);
insert into nation values(12,'JAPAN',2,'ously. final express gifts cajole a','JP',$update_timestamp);
insert into nation values(13,'JORDAN',4,'ic deposits are blithely about the carefully regular pa','JO',$update_timestamp);
insert into nation values(14,'KENYA',0,' pending excuses haggle furiously deposits. pending express pinto beans wake fluffily past t','KE',$update_timestamp);
insert into nation values(15,'MOROCCO',0,'rns. blithely bold courts among the closely regular packages use furiously bold platelets?','MA',$update_timestamp);
insert into nation values(16,'MOZAMBIQUE',0,'s. ironic unusual asymptotes wake blithely r','MZ',$update_timestamp);
insert into nation values(17,'PERU',1,'platelets. blithely pending dependencies use fluffily across the even pinto beans. carefully silent accoun','PE',$update_timestamp);
insert into nation values(18,'CHINA',2,'c dependencies. furiously express notornis sleep slyly regular accounts. ideas sleep. depos','CN',$update_timestamp);
insert into nation values(19,'ROMANIA',3,'ular asymptotes are about the furious multipliers. express dependencies nag above the ironically ironic account','RO',$update_timestamp);
insert into nation values(20,'SAUDI ARABIA',4,'ts. silent requests haggle. closely express packages sleep across the blithely','SA',$update_timestamp);
insert into nation values(21,'VIETNAM',2,'hely enticingly express accounts. even final ','VN',$update_timestamp);
insert into nation values(22,'RUSSIA',3,' requests against the platelets use never according to the quickly regular pint','RU',$update_timestamp);
insert into nation values(23,'UNITED KINGDOM',3,'eans boost carefully special requests. accounts are. carefull','GB',$update_timestamp);
insert into nation values(24,'UNITED STATES',1,'y final packages. slow foxes cajole quickly. quickly silent platelets breach ironic accounts. unusual pinto be','US',$update_timestamp);


Select * from nation; --Source Table

select * from nation_table_changes; --stream

Select * from nation_history; --Target Table

Select * from nation_change_data; --View 


-- MERGE statement that uses the CHANGE_DATA view to load data into the NATION_HISTORY table
merge into nation_history nh -- Target table to merge changes from NATION into
using nation_change_data m -- NATION_CHANGE_DATA is a view that holds the logic that determines what to insert/update into the NATION_HISTORY table.
on nh.n_nationkey = m.n_nationkey -- n_nationkey and start_time determine whether there is a unique record in the NATION_HISTORY table
and nh.start_time = m.start_time
when matched and m.dml_type = 'U' then update -- Indicates the record has been updated and is no longer current and the end_time needs to be stamped
set nh.end_time = m.end_time,
nh.current_flag = 0
when matched and m.dml_type = 'D' then update -- Deletes are essentially logical deletes. The record is stamped and no newer version is inserted
set nh.end_time = m.end_time,
nh.current_flag = 0
when not matched and m.dml_type = 'I' then insert -- Inserting a new n_nationkey and updating an existing one both result in an insert
(n_nationkey, n_name, n_regionkey, n_comment, country_code, start_time, end_time, current_flag)
values (m.n_nationkey, m.n_name, m.n_regionkey, m.n_comment,m.country_code, m.start_time, m.end_time, m.current_flag);


select * from nation_history order by n_nationkey desc;
select * from nation_table_changes;
select * from nation_change_data;


update nation
set n_comment = 'New comment for Brazil', update_timestamp = current_timestamp()::timestamp_ntz
where n_nationkey = 2;

update nation
set n_comment = 'New comment for Canada', update_timestamp = current_timestamp()::timestamp_ntz
where n_nationkey = 3;


select * from nation_table_changes;

-- MERGE statement that uses the CHANGE_DATA view to load data into the NATION_HISTORY table
merge into nation_history nh -- Target table to merge changes from NATION into
using nation_change_data m -- CHANGE_DATA is a view that holds the logic that determines what to insert/update into the NATION_HISTORY table.
  on nh.n_nationkey = m.n_nationkey -- n_nationkey and start_time determine whether there is a unique record in the NATION_HISTORY table
  and nh.start_time = m.start_time
when matched and m.dml_type = 'U' then update -- Indicates the record has been updated and is no longer current and the end_time needs to be stamped
   set nh.end_time = m.end_time,
       nh.current_flag = 0
when matched and m.dml_type = 'D' then update -- Deletes are essentially logical deletes. The record is stamped and no newer version is inserted
   set nh.end_time = m.end_time,
       nh.current_flag = 2
when not matched and m.dml_type = 'I' then insert -- Inserting a new n_nationkey and updating an existing one both result in an Insert
          (n_nationkey, n_name, n_regionkey, n_comment, country_code, start_time, end_time, current_flag)
   values (m.n_nationkey, m.n_name, m.n_regionkey, m.n_comment,
m.country_code, m.start_time, m.end_time, m.current_flag);


-- Create a task to schedule the MERGE statement
create or replace task populate_nation_history warehouse = compute_wh schedule = '1 minute' when system$stream_has_data('nation_table_changes')
as  
merge into nation_history nh
using nation_change_data m
  on nh.n_nationkey = m.n_nationkey
  and nh.start_time = m.start_time
when matched and m.dml_type = 'U' then update
   set nh.end_time = m.end_time,
       nh.current_flag = 0
when matched and m.dml_type = 'D' then update
   set nh.end_time = m.end_time,
       nh.current_flag = 2
when not matched and m.dml_type = 'I' then insert
          (n_nationkey, n_name, n_regionkey, n_comment,
country_code, start_time, end_time, current_flag)
   values (m.n_nationkey, m.n_name, m.n_regionkey, m.n_comment,
m.country_code, m.start_time, m.end_time, m.current_flag);

show tasks;
-- Resume the task
alter task populate_nation_history suspend;

select timestampdiff(second, current_timestamp, scheduled_time) as next_run, scheduled_time, current_timestamp, name, state
from table(information_schema.task_history()) where state = 'SCHEDULED' order by completed_time desc;

-- Delete data
delete from nation
where n_nationkey in (3,7);

-- Insert, update, delete in one pass

insert into nation values(26, 'COLOMBIA', 1, 'New country', 'CO', current_timestamp()::timestamp_ntz);

update nation
set n_comment = 'New comment for Indonesia', update_timestamp =
current_timestamp()::timestamp_ntz
where n_nationkey = 9;

delete from nation
where n_nationkey in (20);

select * from nation_history where n_nationkey in (26,9,20);