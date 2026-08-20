# Import python packages
import streamlit as st
from snowflake.snowpark.context import get_active_session

session = get_active_session()
# Write directly to the app
st.title(f"This is my First Streamlit APPLICATION")
st.caption("I am trying with Streamlit to build my first application")
st.write(
"""Replace this example with your own code!
** And if you're new to Streamlit, ** check
out our easy-to-follow guides at
[docs.streamlit.io](https://docs.streamlit.io).""")

# Helper function
def run_query(sql):
    return session.sql(sql).to_pandas() #It Helps to convert Sql to Pandas,
#If we don't know how to write panadas we can use the above Helper FUnction to COnvert the entire sql logic to Pandas

#show scorecards

df_wh_count = run_query("""SELECT COUNT (DISTINCT WAREHOUSE_NAME)
AS TOTAL_WAREHOUSES FROM SNOWFLAKE. ACCOUNT_USAGE. WAREHOUSE_METERING_HISTORY; """)

df_db_count = run_query("""SELECT COUNT(DISTINCT DATABASE_NAME)
AS TOTAL_DATABASES FROM SNOWFLAKE. ACCOUNT_USAGE. DATABASES; """)

df_avg_query = run_query("""
SELECT AVG(TOTAL_ELAPSED_TIME/1000) AS AVG_EXEC_TIME_SEC
FROM SNOWFLAKE.ACCOUNT_USAGE. QUERY_HISTORY
WHERE START_TIME >= DATEADD('day', -7, CURRENT_TIMESTAMP()); """)

st.metric(" TOTAL WAREHOUSES",int(df_wh_count["TOTAL_WAREHOUSES"][0]) )
st.metric(" TOTAL DATABASES", int(df_db_count[ "TOTAL_DATABASES"][0]) )
st.metric(" AVG QUERY TIME",int(df_avg_query["AVG_EXEC_TIME_SEC"][0]) )

col1, col2, col3 = st.columns(3)

#st.metric("Total Warehouses", int(df_wh_count["TOTAL_WAREHOUSES"])
col1.metric("Total Warehouses", int(df_wh_count["TOTAL_WAREHOUSES"][0]))
col2.metric("Total Databases", int(df_db_count["TOTAL_DATABASES"][0]))
col3.metric("Avg_Query_Execution(sec)", round(float (df_avg_query["AVG_EXEC_TIME_SEC"][0]) ))


#show warehouses wise spend in last 30 days

df_wh_spend = run_query(""" SELECT WAREHOUSE_NAME, SUM (CREDITS_USED) AS TOTALCREDIT
FROM SNOWFLAKE.ACCOUNT_USAGE. WAREHOUSE_METERING_HISTORY
WHERE START_TIME >=DATEADD('day',-30, CURRENT_DATE () )
GROUP BY ALL
ORDER BY TOTALCREDIT DESC; """)


st.bar_chart(df_wh_spend, x="WAREHOUSE_NAME", y="TOTALCREDIT")


#last 7 days credit consumption

df_daily = run_query(f"""
SELECT
USAGE_DATE,
SUM(CREDITS_USED) AS CREDITS_USED
FROM SNOWFLAKE.ACCOUNT_USAGE.METERING_DAILY_HISTORY
WHERE USAGE_DATE >= DATEADD('day', -7, CURRENT_DATE() )
GROUP BY USAGE_DATE
ORDER BY USAGE_DATE;
""")

df_daily.set_index("USAGE_DATE", inplace=True)
st.line_chart(df_daily["CREDITS_USED"], use_container_width=True)


st.header("Database Storage Usage")

df_cloud = run_query("""
SELECT
ROUND(SUM(ACTIVE_BYTES + TIME_TRAVEL_BYTES + FAILSAFE_BYTES)/1e9, 2) AS TOTAL,
TABLE_CATALOG AS DB_NAME
FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS
WHERE TABLE_CATALOG IS NOT NULL
GROUP BY TABLE_CATALOG
HAVING TOTAL > 1; """)

st.bar_chart(df_cloud, x="DB_NAME", y="TOTAL")

st.success(" Dashboard Loaded Successfully! ")

