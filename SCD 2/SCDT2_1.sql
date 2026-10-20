use database MDB;

create or replace schema SCD2;
use schema scd2;

CREATE OR REPLACE TABLE CUSTOMER_STG (
                                        CUSTOMER_ID STRING,
                                        CUSTOMER_NAME STRING, 
                                        CITY STRING, 
                                        EMAIL STRING, 
                                        PHONE STRING,
                                        UPDATED_AT TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP);

Select * from CUSTOMER_STG;
INSERT INTO CUSTOMER_STG
    (CUSTOMER_ID, CUSTOMER_NAME, CITY, EMAIL, PHONE)
VALUES
('C001', 'Ravi Kumar', 'Hyderabad', 'ravi.kumar@gmail.com', '9876500001'),
('C002', 'Sneha Reddy', 'Bangalore', 'sneha.reddy@gmail.com', '9876500002'),
('C003', 'Arjun Sharma', 'Chennai', 'arjun.sharma@gmail.com', '9876500003'),
('C004', 'Priya Patel', 'Mumbai', 'priya.patel@gmail.com', '9876500004'),
('C005', 'Kiran Rao', 'Pune', 'kiran.rao@gmail.com', '9876500005'),
('C006', 'Ananya Singh', 'Delhi', 'ananya.singh@gmail.com', '9876500006'),
('C007', 'Vikram Reddy', 'Hyderabad', 'vikram.reddy@gmail.com', '9876500007'),
('C008', 'Meera Nair', 'Kochi', 'meera.nair@gmail.com', '9876500008'),
('C009', 'Rahul Verma', 'Jaipur', 'rahul.verma@gmail.com', '9876500009'),
('C010', 'Divya Sharma', 'Chandigarh', 'divya.sharma@gmail.com', '9876500010'),
('C011', 'Suresh Kumar', 'Vijayawada', 'suresh.kumar@gmail.com', '9876500011'),
('C012', 'Pooja Gupta', 'Lucknow', 'pooja.gupta@gmail.com', '9876500012'),
('C013', 'Naveen Reddy', 'Warangal', 'naveen.reddy@gmail.com', '9876500013'),
('C014', 'Kavya Iyer', 'Coimbatore', 'kavya.iyer@gmail.com', '9876500014'),
('C015', 'Manoj Das', 'Kolkata', 'manoj.das@gmail.com', '9876500015'),
('C016', 'Asha Menon', 'Thiruvananthapuram', 'asha.menon@gmail.com', '9876500016'),
('C017', 'Rajesh Yadav', 'Ahmedabad', 'rajesh.yadav@gmail.com', '9876500017'),
('C018', 'Neha Joshi', 'Indore', 'neha.joshi@gmail.com', '9876500018'),
('C019', 'Pradeep Rao', 'Visakhapatnam', 'pradeep.rao@gmail.com', '9876500019'),
('C020', 'Lakshmi Devi', 'Tirupati', 'lakshmi.devi@gmail.com', '9876500020');

INSERT INTO CUSTOMER_STG
    (CUSTOMER_ID, CUSTOMER_NAME, CITY, EMAIL, PHONE)
VALUES
('C021', 'Akhil Reddy', 'Hyderabad', 'akhil.reddy@gmail.com', '9876500021'),
('C022', 'Swathi Kumar', 'Bangalore', 'swathi.kumar@gmail.com', '9876500022'),
('C023', 'Vamsi Krishna', 'Vijayawada', 'vamsi.krishna@gmail.com', '9876500023'),
('C024', 'Harini Rao', 'Chennai', 'harini.rao@gmail.com', '9876500024'),
('C025', 'Abhishek Verma', 'Delhi', 'abhishek.verma@gmail.com', '9876500025'),
('C026', 'Deepika Reddy', 'Warangal', 'deepika.reddy@gmail.com', '9876500026'),
('C027', 'Sai Teja', 'Visakhapatnam', 'sai.teja@gmail.com', '9876500027'),
('C028', 'Nithya Sharma', 'Mumbai', 'nithya.sharma@gmail.com', '9876500028'),
('C029', 'Pavan Kumar', 'Pune', 'pavan.kumar@gmail.com', '9876500029'),
('C030', 'Sravani Devi', 'Tirupati', 'sravani.devi@gmail.com', '9876500030'),
('C031', 'Tarun Patel', 'Ahmedabad', 'tarun.patel@gmail.com', '9876500031'),
('C032', 'Bhavana Nair', 'Kochi', 'bhavana.nair@gmail.com', '9876500032'),
('C033', 'Chaitanya Rao', 'Guntur', 'chaitanya.rao@gmail.com', '9876500033'),
('C034', 'Keerthi Singh', 'Jaipur', 'keerthi.singh@gmail.com', '9876500034'),
('C035', 'Praveen Das', 'Kolkata', 'praveen.das@gmail.com', '9876500035'),
('C036', 'Mounika Reddy', 'Nellore', 'mounika.reddy@gmail.com', '9876500036'),
('C037', 'Aditya Sharma', 'Lucknow', 'aditya.sharma@gmail.com', '9876500037'),
('C038', 'Sirisha Rao', 'Rajahmundry', 'sirisha.rao@gmail.com', '9876500038'),
('C039', 'Gautam Joshi', 'Indore', 'gautam.joshi@gmail.com', '9876500039'),
('C040', 'Anusha Menon', 'Coimbatore', 'anusha.menon@gmail.com', '9876500040');

Select * from CUSTOMER_STG;
--truncate table CUSTOMER_STG;

--drop table Customer_scd2;
--Creating the Dynamic Tables to iplement SCD Type2
Create or replace dynamic table Customer_scd2
LAG = '1 minute'
warehouse = compute_wh
refresh_mode = full
initialize = ON_CREATE AS
Select  CUSTOMER_ID,
        CUSTOMER_NAME,
        CITY,
        EMAIL,
        PHONE,
        UPDATED_AT,
        UPDATED_AT as START_DATE,
        NVL(LEAD(UPDATED_AT) over(partition by Customer_id order by UPDATED_AT),'9999-12-31') as END_DATE,
        CASE when LEAD(UPDATED_AT) over(partition by customer_id order by updated_at) is null then TRUE
            else FALSE END as IS_ACTIVE
        from CUSTOMER_STG ;

Select * from Customer_scd2 order by customer_id ;

--Updating the details using INSERT Statement Only not in UPDATES and DELETES
INSERT INTO CUSTOMER_STG
    (CUSTOMER_ID, CUSTOMER_NAME, CITY, EMAIL, PHONE)
VALUES
('C001', 'Ravi Kumar Reddy', 'Bangalore', 'ravi.reddy@gmail.com', '9876511001');

INSERT INTO CUSTOMER_STG
    (CUSTOMER_ID, CUSTOMER_NAME, CITY, EMAIL, PHONE)
VALUES
('C002', 'Sneha Sharma', 'Hyderabad', 'sneha.sharma@gmail.com', '9876511002');

INSERT INTO CUSTOMER_STG
    (CUSTOMER_ID, CUSTOMER_NAME, CITY, EMAIL, PHONE)
VALUES
('C003', 'Arjun Kumar', 'Pune', 'arjun.kumar@gmail.com', '9876511003');

INSERT INTO CUSTOMER_STG
    (CUSTOMER_ID, CUSTOMER_NAME, CITY, EMAIL, PHONE)
VALUES
('C004', 'Priya Patel', 'Chennai', 'priya.patel@gmail.com', '9876511004');

Select * from Customer_scd2;