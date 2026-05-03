-- Databricks notebook source
---Step 1: Exploratory Data Analysis
--- I want to see my table in the coding environment to start exploring each column
SELECT * 
FROM `workspace`.`case_study1`.`coffee_shop` 
LIMIT 10;

------------------------------------------------------
--- 1. Checking the Date Range
------------------------------------------------------
--- They started collecting the data on 2023-01-01
SELECT MIN(transaction_date) AS min_date
FROM `workspace`.`case_study1`.`coffee_shop`;

--- They last collected the data on 2023-06-30 
--- the duration of the data is 6 months
SELECT MAX(transaction_date) AS latest_date
FROM `workspace`.`case_study1`.`coffee_shop`;
------------------------------------------------------
--- 2. Checking the names of the different stores
------------------------------------------------------
---We have 3 stores and their names are Lower Manhattan, Hell's Kitchen and Astoria
SELECT DISTINCT store_location
FROM `workspace`.`case_study1`.`coffee_shop`;

--- Count the number of stores in the data
SELECT COUNT(DISTINCT store_id) AS number_of_stores
FROM `workspace`.`case_study1`.`coffee_shop`;
------------------------------------------------------
--- 3. Checking the products sold at the stores
------------------------------------------------------
---9 product categories
---80 product details
---29 product types
SELECT DISTINCT product_category
FROM `workspace`.`case_study1`.`coffee_shop`;

SELECT DISTINCT product_detail
FROM `workspace`.`case_study1`.`coffee_shop`;

SELECT DISTINCT product_category AS category,
                product_detail AS product_name
FROM `workspace`.`case_study1`.`coffee_shop`;

SELECT DISTINCT product_type
FROM `workspace`.`case_study1`.`coffee_shop`;
-----------------------------------------------------
---4 checking for NULLS in various columns
----------------------------------------------------
---No NULL in the columns
select *
FROM `workspace`.`case_study1`.`coffee_shop`
where unit_price IS NULL
OR transaction_qty IS NULL
OR transaction_date IS NULL;

------------------------------------------------------
--- 5. Checking the product prices
------------------------------------------------------
--- The cheapest price is 0.8 and the expensive price is 45
SELECT MIN(unit_price) AS cheapest_price
FROM `workspace`.`case_study1`.`coffee_shop`;

SELECT MAX(unit_price) AS expensive_price
FROM `workspace`.`case_study1`.`coffee_shop`;

------------------------------------------------------
--- 6. Checking the size of the data
------------------------------------------------------
--- There are 149116 rows, 149116 number of sales, 80 products and 3 stores
SELECT COUNT(*) AS number_of_rows,
      COUNT(DISTINCT transaction_id) AS number_of_sales,
      COUNT(DISTINCT product_id) AS number_of_products,
      COUNT(DISTINCT store_id) AS number_of_stores
FROM `workspace`.`case_study1`.`coffee_shop`;
-----------------------------------------------------
---7. Date functions
-----------------------------------------------------
SELECT transaction_id,
      transaction_date,
      Dayname(transaction_date) AS day_name,
      Monthname(transaction_date) AS month_name,
      transaction_qty*unit_price AS revenue_per_transaction
FROM `workspace`.`case_study1`.`coffee_shop`;

-----------------------------------------------------
---Step 2: Combining functions to get a clean and enhanced dataset
---Extracting the day name, month name and day of month, Aggregate the data (COUNT the Distinct id's and calculate Revenue)
---Create new columns using case statement to enhance the table for better insights (day_classification, time_buckets(i.e time_classification), spend_buckets)
--- 7 new columns added: day_name, month_name, day_of_month, day_classification, time_classification, Revenue and spend_buckets
-----------------------------------------------------
SELECT 
---Dates
      transaction_date,
      Dayname(transaction_date) AS day_name,
      Monthname(transaction_date) AS month_name,
      date_format(transaction_time, 'HH:mm:ss') AS purchase_time,
      Dayofmonth(transaction_date) AS day_of_month,

      CASE
            WHEN Dayname(transaction_date) IN('Sun','Sat') THEN 'Weekend'
            ELSE 'Weekday'
      END AS day_classification,
      
      CASE
            WHEN date_format(transaction_time, 'HH:mm:ss') BETWEEN '05:00:00' AND '08:59:59' THEN '01. Rush Hour'
            WHEN date_format(transaction_time, 'HH:mm:ss') BETWEEN '09:00:00' AND '11:59:59' THEN '02. Mid Morning'
            WHEN date_format(transaction_time, 'HH:mm:ss') BETWEEN '12:00:00' AND '15:59:59' THEN '03. Afternoon'
            WHEN date_format(transaction_time, 'HH:mm:ss') BETWEEN '16:00:00' AND '18:00:00' THEN '04. Rush Hour'
            ELSE '05. Night'
      END AS time_classification,

--- COUNTS of IDs
      COUNT(DISTINCT transaction_id) AS number_of_sales,
      COUNT(DISTINCT store_id) AS number_of_stores,
      COUNT(DISTINCT product_id) AS number_of_products,
---Revenue 
      sum(transaction_qty*unit_price) AS Revenue,

      CASE
            WHEN Revenue <=50 THEN '01. Low spend'
            WHEN Revenue BETWEEN 51 AND 200 THEN '02. Medium spend'
            WHEN Revenue BETWEEN 201 AND 300 THEN '03. Moreki'
            ELSE '04. Blesser'
      END AS spend_buckets,

---Categorical columns
      store_location,
      product_category,
      product_detail
FROM `workspace`.`case_study1`.`coffee_shop`
GROUP BY transaction_date,
      day_name,
      month_name,
      purchase_time,
      time_classification,
      store_location,
      product_category,
      product_detail,
      day_classification,
      day_of_month;





