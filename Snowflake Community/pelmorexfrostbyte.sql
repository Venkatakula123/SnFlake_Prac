--https://www.snowflake.com/en/developers/guides/snowflake-northstar-data-engineering/ 

--Git Repo --https://github.com/Snowflake-Labs/sfguide-snowflake-northstar-data-engineering/blob/main/00_ingestion/load_tasty_bytes.sql


CREATE OR REPLACE DATABASE tasty_bytes;
CREATE OR REPLACE SCHEMA raw_pos;

Select current_database();
Select current_schema();

-- Create a CSV file format here:

-- Specify the file format below:
CREATE OR REPLACE STAGE tasty_bytes.public.s3load
url = 's3://sfquickstarts/tasty-bytes-builder-education/';

List @tasty_bytes.public.s3load;

-- country table build
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.country
(
   country_id NUMBER(18,0),
   country VARCHAR(16777216),
   iso_currency VARCHAR(3),
   iso_country VARCHAR(2),
   city_id NUMBER(19,0),
   city VARCHAR(16777216),
   city_population VARCHAR(16777216)
);

-- Use the COPY INTO command to load data into the country table:
CREATE OR REPLACE FILE FORMAT tasty_bytes.public.csv_ff
type = 'csv';

COPY INTO tasty_bytes.raw_pos.country
FROM @tasty_bytes.public.s3load/raw_pos/country/;

Select * from tasty_bytes.raw_pos.country;

USE ROLE accountadmin;
USE DATABASE tasty_bytes;

/*--
database, schema and warehouse creation
--*/

-- create raw_customer schema
CREATE OR REPLACE SCHEMA tasty_bytes.raw_customer;


-- create harmonized schema
CREATE OR REPLACE SCHEMA tasty_bytes.harmonized;


-- create analytics schema
CREATE OR REPLACE SCHEMA tasty_bytes.analytics;


-- create warehouse for ingestion
CREATE OR REPLACE WAREHOUSE demo_build_wh
   WAREHOUSE_SIZE = 'xlarge'
   WAREHOUSE_TYPE = 'standard'
   AUTO_SUSPEND = 60
   AUTO_RESUME = TRUE
   INITIALLY_SUSPENDED = TRUE;

   Select Current_warehouse();

/*--
file format and stage creation
--*/


CREATE OR REPLACE FILE FORMAT tasty_bytes.public.csv_ff
type = 'csv';


CREATE OR REPLACE STAGE tasty_bytes.public.s3load
url = 's3://sfquickstarts/tasty-bytes-builder-education/'
file_format = tasty_bytes.public.csv_ff;

List @tasty_bytes.public.s3load;

/*--
raw zone table build
--*/


-- franchise table build
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.franchise
(
   franchise_id NUMBER(38,0),
   first_name VARCHAR(16777216),
   last_name VARCHAR(16777216),
   city VARCHAR(16777216),
   country VARCHAR(16777216),
   e_mail VARCHAR(16777216),
   phone_number VARCHAR(16777216)
);


-- location table build
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.location
(
   location_id NUMBER(19,0),
   placekey VARCHAR(16777216),
   location VARCHAR(16777216),
   city VARCHAR(16777216),
   region VARCHAR(16777216),
   iso_country_code VARCHAR(16777216),
   country VARCHAR(16777216)
);


-- menu table build
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.menu
(
   menu_id NUMBER(19,0),
   menu_type_id NUMBER(38,0),
   menu_type VARCHAR(16777216),
   truck_brand_name VARCHAR(16777216),
   menu_item_id NUMBER(38,0),
   menu_item_name VARCHAR(16777216),
   item_category VARCHAR(16777216),
   item_subcategory VARCHAR(16777216),
   cost_of_goods_usd NUMBER(38,4),
   sale_price_usd NUMBER(38,4),
   menu_item_health_metrics_obj VARIANT
);


-- truck table build
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.truck
(
   truck_id NUMBER(38,0),
   menu_type_id NUMBER(38,0),
   primary_city VARCHAR(16777216),
   region VARCHAR(16777216),
   iso_region VARCHAR(16777216),
   country VARCHAR(16777216),
   iso_country_code VARCHAR(16777216),
   franchise_flag NUMBER(38,0),
   year NUMBER(38,0),
   make VARCHAR(16777216),
   model VARCHAR(16777216),
   ev_flag NUMBER(38,0),
   franchise_id NUMBER(38,0),
   truck_opening_date DATE
);


-- order_header table build
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.order_header
(
   order_id NUMBER(38,0),
   truck_id NUMBER(38,0),
   location_id FLOAT,
   customer_id NUMBER(38,0),
   discount_id VARCHAR(16777216),
   shift_id NUMBER(38,0),
   shift_start_time TIME(9),
   shift_end_time TIME(9),
   order_channel VARCHAR(16777216),
   order_ts TIMESTAMP_NTZ(9),
   served_ts VARCHAR(16777216),
   order_currency VARCHAR(3),
   order_amount NUMBER(38,4),
   order_tax_amount VARCHAR(16777216),
   order_discount_amount VARCHAR(16777216),
   order_total NUMBER(38,4)
);


-- order_detail table build
CREATE OR REPLACE TABLE tasty_bytes.raw_pos.order_detail
(
   order_detail_id NUMBER(38,0),
   order_id NUMBER(38,0),
   menu_item_id NUMBER(38,0),
   discount_id VARCHAR(16777216),
   line_number NUMBER(38,0),
   quantity NUMBER(5,0),
   unit_price NUMBER(38,4),
   price NUMBER(38,4),
   order_item_discount_amount VARCHAR(16777216)
);


-- customer loyalty table build
CREATE OR REPLACE TABLE tasty_bytes.raw_customer.customer_loyalty
(
   customer_id NUMBER(38,0),
   first_name VARCHAR(16777216),
   last_name VARCHAR(16777216),
   city VARCHAR(16777216),
   country VARCHAR(16777216),
   postal_code VARCHAR(16777216),
   preferred_language VARCHAR(16777216),
   gender VARCHAR(16777216),
   favourite_brand VARCHAR(16777216),
   marital_status VARCHAR(16777216),
   children_count VARCHAR(16777216),
   sign_up_date DATE,
   birthday_date DATE,
   e_mail VARCHAR(16777216),
   phone_number VARCHAR(16777216)
);


/*--
harmonized view creation
--*/


-- orders_v view
CREATE OR REPLACE VIEW tasty_bytes.harmonized.orders_v
   AS
SELECT
   oh.order_id,
   oh.truck_id,
   oh.order_ts,
   od.order_detail_id,
   od.line_number,
   m.truck_brand_name,
   m.menu_type,
   t.primary_city,
   t.region,
   t.country,
   t.franchise_flag,
   t.franchise_id,
   f.first_name AS franchisee_first_name,
   f.last_name AS franchisee_last_name,
   l.location_id,
   cl.customer_id,
   cl.first_name,
   cl.last_name,
   cl.e_mail,
   cl.phone_number,
   cl.children_count,
   cl.gender,
   cl.marital_status,
   od.menu_item_id,
   m.menu_item_name,
   od.quantity,
   od.unit_price,
   od.price,
   oh.order_amount,
   oh.order_tax_amount,
   oh.order_discount_amount,
   oh.order_total
FROM tasty_bytes.raw_pos.order_detail od
JOIN tasty_bytes.raw_pos.order_header oh
   ON od.order_id = oh.order_id
JOIN tasty_bytes.raw_pos.truck t
   ON oh.truck_id = t.truck_id
JOIN tasty_bytes.raw_pos.menu m
   ON od.menu_item_id = m.menu_item_id
JOIN tasty_bytes.raw_pos.franchise f
   ON t.franchise_id = f.franchise_id
JOIN tasty_bytes.raw_pos.location l
   ON oh.location_id = l.location_id
LEFT JOIN tasty_bytes.raw_customer.customer_loyalty cl
   ON oh.customer_id = cl.customer_id;


-- loyalty_metrics_v view
CREATE OR REPLACE VIEW tasty_bytes.harmonized.customer_loyalty_metrics_v
   AS
SELECT
   cl.customer_id,
   cl.city,
   cl.country,
   cl.first_name,
   cl.last_name,
   cl.phone_number,
   cl.e_mail,
   SUM(oh.order_total) AS total_sales,
   ARRAY_AGG(DISTINCT oh.location_id) AS visited_location_ids_array
FROM tasty_bytes.raw_customer.customer_loyalty cl
JOIN tasty_bytes.raw_pos.order_header oh
ON cl.customer_id = oh.customer_id
GROUP BY cl.customer_id, cl.city, cl.country, cl.first_name,
cl.last_name, cl.phone_number, cl.e_mail;


/*--
analytics view creation
--*/


-- orders_v view
CREATE OR REPLACE VIEW tasty_bytes.analytics.orders_v
COMMENT = 'Tasty Bytes Order Detail View'
   AS
SELECT DATE(o.order_ts) AS date, * FROM tasty_bytes.harmonized.orders_v o;


-- customer_loyalty_metrics_v view
CREATE OR REPLACE VIEW tasty_bytes.analytics.customer_loyalty_metrics_v
COMMENT = 'Tasty Bytes Customer Loyalty Member Metrics View'
   AS
SELECT * FROM tasty_bytes.harmonized.customer_loyalty_metrics_v;


/*--
raw zone table load
--*/


USE WAREHOUSE demo_build_wh;


-- franchise table load
COPY INTO tasty_bytes.raw_pos.franchise
FROM @tasty_bytes.public.s3load/raw_pos/franchise/;


-- location table load
COPY INTO tasty_bytes.raw_pos.location
FROM @tasty_bytes.public.s3load/raw_pos/location/;


-- menu table load
COPY INTO tasty_bytes.raw_pos.menu
FROM @tasty_bytes.public.s3load/raw_pos/menu/;


-- truck table load
COPY INTO tasty_bytes.raw_pos.truck
FROM @tasty_bytes.public.s3load/raw_pos/truck/;


-- customer_loyalty table load
COPY INTO tasty_bytes.raw_customer.customer_loyalty
FROM @tasty_bytes.public.s3load/raw_customer/customer_loyalty/;


-- order_header table load
COPY INTO tasty_bytes.raw_pos.order_header
FROM @tasty_bytes.public.s3load/raw_pos/order_header/;


-- order_detail table load
COPY INTO tasty_bytes.raw_pos.order_detail
FROM @tasty_bytes.public.s3load/raw_pos/order_detail/;


--DROP WAREHOUSE demo_build_wh;
Use warehouse COMPUTE_WH;

--SELECT DATEADD(DAY, SEQ4(), '2022-02-01') AS date  FROM TABLE(GENERATOR(ROWCOUNT => 28));
-- Query to explore sales in the city of Hamburg, Germany
WITH _feb_date_dim AS (
    SELECT DATEADD(DAY, SEQ4(), '2022-02-01') AS date 
    FROM TABLE(GENERATOR(ROWCOUNT => 28))
)
SELECT
    fdd.date,
    ZEROIFNULL(SUM(o.price)) AS daily_sales
FROM _feb_date_dim fdd
LEFT JOIN analytics.orders_v o
    ON fdd.date = DATE(o.order_ts)
    AND o.country = 'Germany' -- Add country
    AND o.primary_city = 'Hamburg' -- Add city
WHERE fdd.date BETWEEN '2022-02-01' AND '2022-02-28'
GROUP BY fdd.date
ORDER BY fdd.date ASC;

-- Create view that adds weather data for cities where Tasty Bytes operates
CREATE OR REPLACE VIEW tasty_bytes.harmonized.daily_weather_v
COMMENT = 'Weather Source Daily History filtered to Tasty Bytes supported Cities'
    AS
SELECT
    hd.*,
    TO_VARCHAR(hd.date_valid_std, 'YYYY-MM') AS yyyy_mm,
    pc.city_name AS city,
    c.country AS country_desc
FROM Pelmorex_Weather_Source_frostbyte.onpoint_id.history_day hd
JOIN Pelmorex_Weather_Source_frostbyte.onpoint_id.postal_codes pc
    ON pc.postal_code = hd.postal_code
    AND pc.country = hd.country
JOIN TASTY_BYTES.raw_pos.country c
    ON c.iso_country = hd.country
    AND c.city = hd.city_name;

Select * from tasty_bytes.harmonized.daily_weather_v limit 10000; 

Select count(*) from tasty_bytes.harmonized.daily_weather_v ; 

Show views;

-- Query the view to explore daily temperatures in Hamburg, Germany for anomalies
SELECT
    dw.country_desc,
    dw.city_name,
    dw.date_valid_std,
    AVG(dw.avg_temperature_air_2m_f) AS avg_temperature_air_2m_f
FROM harmonized.daily_weather_v dw
WHERE 1=1
    AND dw.country_desc = 'Germany'
    AND dw.city_name = 'Hamburg'
    AND YEAR(date_valid_std) = '2022'
    AND MONTH(date_valid_std) = '2' -- February
GROUP BY dw.country_desc, dw.city_name, dw.date_valid_std
ORDER BY dw.date_valid_std DESC;

-- Query the view to explore wind speeds in Hamburg, Germany for anomalies
SELECT
    dw.country_desc,
    dw.city_name,
    dw.date_valid_std,
    MAX(dw.max_wind_speed_100m_mph) AS max_wind_speed_100m_mph
FROM tasty_bytes.harmonized.daily_weather_v dw
WHERE 1=1
    AND dw.country_desc IN ('Germany')
    AND dw.city_name = 'Hamburg'
    AND YEAR(date_valid_std) = '2022'
    AND MONTH(date_valid_std) = '2' -- February
GROUP BY dw.country_desc, dw.city_name, dw.date_valid_std
ORDER BY dw.date_valid_std DESC;

-- Create a view that tracks windspeed for Hamburg, Germany
CREATE OR REPLACE VIEW tasty_bytes.harmonized.windspeed_hamburg --add name of view
    AS
SELECT
    dw.country_desc,
    dw.city_name,
    dw.date_valid_std,
    MAX(dw.max_wind_speed_100m_mph) AS max_wind_speed_100m_mph
FROM harmonized.daily_weather_v dw
WHERE 1=1
    AND dw.country_desc IN ('Germany')
    AND dw.city_name = 'Hamburg'
GROUP BY dw.country_desc, dw.city_name, dw.date_valid_std
ORDER BY dw.date_valid_std DESC;

CREATE OR REPLACE function tasty_bytes.analytics.fahrenheit_to_celsius(temp_f NUMBER(35,4))
  RETURNS NUMBER(35,4)
  AS
  $$
    (temp_f - 32) * (5/9)
  $$
;

CREATE OR REPLACE function tasty_bytes.analytics.inch_to_millimeter(inch NUMBER(35,4))
  RETURNS NUMBER(35,4)
  AS
  $$
    inch * 25.4
  $$
;

USE ROLE accountadmin;
USE WAREHOUSE compute_wh;
USE DATABASE tasty_bytes;

-- Apply UDFs and confirm successful execution
CREATE OR REPLACE VIEW harmonized.weather_hamburg -- add name of view
AS
SELECT
    fd.date_valid_std AS date,
    fd.city_name,
    fd.country_desc,
    ZEROIFNULL(SUM(odv.price)) AS daily_sales,
    ROUND(AVG(fd.avg_temperature_air_2m_f),2) AS avg_temperature_fahrenheit,
    ROUND(AVG(analytics.fahrenheit_to_celsius(fd.avg_temperature_air_2m_f)),2) AS avg_temperature_celsius,
    ROUND(AVG(fd.tot_precipitation_in),2) AS avg_precipitation_inches,
    ROUND(AVG(analytics.inch_to_millimeter(fd.tot_precipitation_in)),2) AS avg_precipitation_millimeters,
    MAX(fd.max_wind_speed_100m_mph) AS max_wind_speed_100m_mph
FROM harmonized.daily_weather_v fd
LEFT JOIN harmonized.orders_v odv
    ON fd.date_valid_std = DATE(odv.order_ts)
    AND fd.city_name = odv.primary_city
    AND fd.country_desc = odv.country
WHERE 1=1
    AND fd.country_desc = 'Germany'
    AND fd.city = 'Hamburg'
    AND fd.yyyy_mm = '2022-02'
GROUP BY fd.date_valid_std, fd.city_name, fd.country_desc
ORDER BY fd.date_valid_std ASC;