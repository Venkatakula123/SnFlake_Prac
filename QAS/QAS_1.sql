--By PRADEEP HC

select parse_json(system$estimate_query_acceleration('01aaeddb-3200-acf4-0003-6fe2000191ae'));

SELECT *
FROM snowflake.account_usage.query_acceleration_eligible
ORDER BY eligible_query_acceleration_time DESC;