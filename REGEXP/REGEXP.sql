show databases;
use database MDB;
use schema public;

CREATE OR REPLACE TABLE strings (v VARCHAR(50));
INSERT INTO strings (v) VALUES
  ('San Francisco'),
  ('San Jose'),
  ('Santa Clara'),
  ('Sacramento');

Select v, v REGEXP 'San* [tT].*' as REG from strings where v REGEXP 'San* [jJ].*';
Select v, v REGEXP 'San* [jJ].*' as REG from strings where v REGEXP 'San* [jJ].*';

INSERT INTO strings (v) VALUES  ('Contains embedded single \\backslash');

SELECT *
  FROM strings   ORDER BY v;

--\b used for the word Boundary. We need to check the cities starts with San only not Santa
Select v, v REGEXP 'San\\b.*' as f from strings ORDER by v;
Select v, v REGEXP 'San\\b. *' as f from strings ORDER by v;
Select v, v REGEXP 'San\b.*' as f from strings ORDER by v;
Select v, v REGEXP 'San\\b .*' as f from strings ORDER by v;


SELECT v, v REGEXP '.*\\s\\\\.*' AS matches FROM strings ORDER BY v;
Select v,v REGEXP $$.*\s\\.*$$ as match from strings;
Select v,v REGEXP '^S.*' as match from strings;

Select v,v REGEXP $$.*\s[A-Za-z].*$$ as match from strings;

Select v,v REGEXP '^Santa.*\\s.*$$' as match from strings;

CREATE OR REPLACE TABLE regexp_practice (
    id            INT,
    first_name    STRING,
    last_name     STRING,
    email         STRING,
    country_code  STRING,
    phone_number  STRING,
    address       STRING,
    city          STRING,
    state         STRING,
    pincode       STRING,
    dob           STRING,
    pan_number    STRING,
    aadhaar       STRING,
    passport_no   STRING,
    notes         STRING
);

INSERT INTO regexp_practice
(id, first_name, last_name, email, country_code, phone_number, address, city, state, pincode, dob, pan_number, aadhaar, passport_no, notes)
VALUES
(1, 'Amit',   'Sharma',   'amit.sharma@example.com',   '+91',  '9876543210', 'Flat 12, Lake View Apartments, Jubilee Hills', 'Hyderabad', 'Telangana', '500033', '1990-05-12', 'ABCDE1234F', '123412341234', 'N1234567', 'Valid profile'),
(2, 'Priya',  'Reddy',    'priya.reddy@example.in',    '+91',  '9123456780', 'H.No 45, Road 10, Banjara Hills',              'Hyderabad', 'Telangana', '500034', '1988-11-03', 'PQRST6789K', '987698769876', 'M7654321', 'Has suite number'),
(3, 'Rahul',  'Kumar',    'rahul.kumar@sample',        '+91',  '9988776655', 'Plot 77, MIG 2, Kukatpally',                  'Hyderabad', 'Telangana', '500072', '1992-01-25', 'ABCDE1234',  '123456789012', 'P12345',   'Invalid email and PAN'),
(4, 'Sara',   'Ali',      'sara.ali@mail.com',         '+971', '501234567',  'Villa 18, Palm Jumeirah',                     'Dubai',     'Dubai',      '00000',  '1995-07-19', 'AAAPL1234C', '111122223333', 'A9876543', 'International number'),
(5, 'John',   'Doe',      'john.doe@gmail.com',        '+1',   '(415) 555-2671', '221B Baker Street',                        'London',    'London',     'NW16XE', '1985-09-30', 'ABCDE1234F', '444455556666', 'X1234567', 'Phone has formatting'),
(6, 'Neha',   'Patel',    'neha.patel@company.co.in',  '+91',  '98765 43210', 'Block C, Sector 62, Noida',                  'Noida',     'Uttar Pradesh', '201301', '2000-12-01', 'ZXYAB9999L', '999988887777', 'B7654321', 'Phone contains space'),
(7, 'Arjun',  'Singh',    'arjun.singh@example.org',   '+44',  '07123456789', 'Flat 8, Baker Street',                        'London',    'Greater London', 'NW16XE', '1998-03-14', 'PQRSX4321Z', '121212121212', 'K1122334', 'UK-style phone'),
(8, 'Meera',  'Nair',     'meera..nair@example.com',   '+91',  '987654321',   'House 9, MG Road',                            'Bengaluru', 'Karnataka',  '560001', '1989-08-08', 'ABCDE1234F', '101010101010', 'C9988776', 'Invalid email local part'),
(9, 'Vikram', 'Iyer',     'vikram.iyer@example.com',   '91',   '00919876543210','No 10, Anna Salai',                           'Chennai',   'Tamil Nadu', '600002', '1979-04-22', 'ABCDE1234F', '555566667777', 'D5544332', 'Country code without plus'),
(10,'Ananya',  'Das',      NULL,                        '+91',  NULL,          '55 Park Street',                                'Kolkata',   'West Bengal', '700016', '1996-02-29', 'ABCDE1234F', '888899990000', 'E2233445', 'Missing email and phone');

INSERT INTO regexp_practice
(id, first_name, last_name, email, country_code, phone_number, address, city, state, pincode, dob, pan_number, aadhaar, passport_no, notes)
VALUES
(1,  'Amit',    'Sharma',   'amit.sharma@example.com',    '+91',  '9876543210',   'Flat 12, Lake View Apartments',      'Hyderabad', 'Telangana',    '500033', '1990-05-12', 'ABCDE1234F', '123412341234', 'N1234567', 'Correct'),
(2,  'Priya',   'Reddy',    'priya.reddy@example.in',     '+91',  '9123456780',   'H.No 45, Road 10',                   'Hyderabad', 'Telangana',    '500034', '1988-11-03', 'PQRST6789K', '987698769876', 'M7654321', 'Correct'),
(3,  'Rahul',   'Kumar',    'rahul.kumar@sample',         '+91',  '9988776655',   'Plot 77, MIG 2',                     'Hyderabad', 'Telangana',    '500072', '1992-01-25', 'ABCDE1234',  '123456789012', 'P12345',   'Wrong email, PAN, passport'),
(4,  'Sara',    'Ali',      'sara.ali@mail.com',          '+971', '501234567',    'Villa 18, Palm Jumeirah',            'Dubai',     'Dubai',        '00000',  '1995-07-19', 'AAAPL1234C', '111122223333', 'A9876543', 'Wrong pincode'),
(5,  'John',    'Doe',      'john.doe@gmail.com',         '+1',   '(415) 555-2671','221B Baker Street',                  'London',    'London',       'NW16XE', '1985-09-30', 'ABCDE1234F', '444455556666', 'X1234567', 'Wrong pincode format'),
(6,  'Neha',    'Patel',    'neha.patel@company.co.in',   '+91',  '98765 43210',   'Block C, Sector 62',                 'Noida',     'Uttar Pradesh','201301', '2000-12-01', 'ZXYAB9999L', '999988887777', 'B7654321', 'Phone has space'),
(7,  'Arjun',   'Singh',    'arjun.singh@example.org',    '+44',  '07123456789',   'Flat 8, Baker Street',               'London',    'Greater London','NW16XE', '1998-03-14', 'PQRSX4321Z', '121212121212', 'K1122334', 'UK phone, wrong pincode'),
(8,  'Meera',   'Nair',     'meera..nair@example.com',    '+91',  '987654321',     'House 9, MG Road',                   'Bengaluru', 'Karnataka',    '560001', '1989-08-08', 'ABCDE1234F', '101010101010', 'C9988776', 'Invalid email and short phone'),
(9,  'Vikram',  'Iyer',     'vikram.iyer@example.com',    '91',   '00919876543210','No 10, Anna Salai',                  'Chennai',   'Tamil Nadu',   '600002', '1979-04-22', 'ABCDE1234F', '555566667777', 'D5544332', 'Country code missing plus'),
(10, 'Ananya',  'Das',      NULL,                         '+91',  NULL,            '55 Park Street',                     'Kolkata',   'West Bengal',  '700016', '1996-02-29', 'ABCDE1234F', '888899990000', 'E2233445', 'Missing email and phone'),
(11, 'Rohit',   'Verma',    'rohit.verma@example.com',    '+91',  '8888888888',    'Apt 4B, MG Road',                    'Pune',      'Maharashtra',  '411001', '1991/06/15', 'ABCDE1234F', '123443211234', 'F1122334', 'Wrong DOB format'),
(12, 'Kiran',   'Bose',     'kiran.bose@example.co.in',   '+91',  '7777777777',    'B-101, Residency Road',              'Kolkata',   'West Bengal',  '700001', '1993-13-01', 'ABCDE1234F', '223344556677', 'G2233445', 'Invalid month in DOB'),
(13, 'Divya',   'Menon',    'divya.menon@example.com',    '+91',  '9999999999',    'No 18, Brigade Road',                'Bengaluru', 'Karnataka',    '560002', '1994-02-30', 'ABCDE1234F', '334455667788', 'H3344556', 'Invalid DOB day'),
(14, 'Asha',    'Iyer',     'asha.iyer@domain',           '+91',  '1234567890',    'Plot 5, OMR',                        'Chennai',   'Tamil Nadu',   '600100', '1990-10-10', 'ABCDE1234',  '445566778899', 'I4455667', 'Wrong email and PAN'),
(15, 'Farhan',  'Khan',     'farhan.khan@example.com',    '+971', '0501234567',    'Villa 2, Downtown',                  'Dubai',     'Dubai',        '123456', '1987-12-12', 'ABCDE1234F', '556677889900', 'J5566778', 'Wrong pincode length'),
(16, 'Pooja',   'Gupta',    'pooja.gupta@example.com',    '+91',  '987654321O',    'Flat 2, Lake Road',                  'Kolkata',   'West Bengal',  '700020', '1992-04-04', 'ABCDE1234F', '667788990011', 'K6677889', 'Phone contains letter O'),
(17, 'Suresh',  'Naik',     'suresh.naik@example.com',    '+91',  '91234-56789',    'House 77, Old Airport Road',         'Bengaluru', 'Karnataka',    '560017', '1986-09-09', 'ABCDE1234F', '778899001122', 'L7788990', 'Phone has hyphen'),
(18, 'Maya',    'Shah',     'maya.shah@example.com',      '+91',  '9012345678',    'Building #9, Hill View',             'Mumbai',    'Maharashtra',  '400001', '1984-01-01', 'ABCDE1234F', '889900112233', 'M8899001', 'Address has special character'),
(19, 'Nitin',   'Jain',     'nitin.jain@example.com',     '+91',  '9234567890',    'Floor 3, Tower A',                   'Delhi',     'Delhi',        '110001', '1995-06-18', 'ABCDE1234F', '990011223344', 'N9900112', 'Correct'),
(20, 'Latha',   'Krishnan', 'latha.krishnan@example.com', '+91',  '9345678901',    'No 14, Gandhi Street',               'Chennai',   'Tamil Nadu',   '600018', '1997-08-21', 'ABCDE1234F', '001122334455', 'P0011223', 'Correct');

Select * from regexp_practice;

Select e.*,length(e.phone_number) from regexp_practice e where e.phone_number NOT REGEXP '^[0-9]{10}$';

Select * from regexp_practice where email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.][A-Za-z].*$';

SELECT *
FROM regexp_practice
WHERE email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+[.][A-Za-z]{2,}$';

SELECT *,length(pan_number)
FROM regexp_practice where pan_number REGEXP '^[A-Z]{5}[0-9]{4}[A-Z]{1}$' and pincode REGEXP '^[0-9]{6}';

Select * from regexp_practice;

SELECT REGEXP_COUNT('Excelence', 'e', 1, 'c') AS e_in_excelence;
SELECT REGEXP_COUNT('Excelence', 'e', 1, 'i') AS e_in_excelence;
SELECT REGEXP_COUNT('Excelence', 'e', 4, 'i') AS e_in_excelence;
SELECT REGEXP_COUNT('It was the best of times, it was the worst of times was', '\\bwas\\b', 1) AS result;
SELECT REGEXP_COUNT('It was the best of times, it was the worst of times was if was is was ', '\\swas\\s', 1) AS result;
