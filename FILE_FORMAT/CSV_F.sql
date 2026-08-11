use database MDB;
use schema FFMT;

show file Formats;

create or replace file format CSVF_1 clone CSVF;
describe file format csvf_1;

alter file format mdb.ffmt.csvpf_1 set FIELD_DELIMITER = ',';

alter file format mdb.ffmt.csvf set field_delimiter = '|';

--Again i am changing the field_delimiter to ','
alter file format mdb.ffmt.csvf set field_delimiter = ',';
describe file format csvf; 

Alter file format csvf set Error_on_column_count_mismatch = false;

Alter file format csvf set parse_header = false;