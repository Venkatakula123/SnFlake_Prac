Use Database MDB;

create or replace schema Alerting;

use schema alerting;

--Create a Notification Object first
CREATE OR REPLACE NOTIFICATION  alerting.TASK_ERROR_EMAIL
  TYPE = EMAIL
  ENABLED = TRUE;