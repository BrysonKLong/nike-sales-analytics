CREATE DATABASE nike_sales;
USE nike_sales;

-- My raw uncleaned table
CREATE TABLE nike_sales_raw (
    Order_ID VARCHAR(50),
    Gender_Category VARCHAR(50),
    Product_Line VARCHAR(50),
    Product_Name VARCHAR(100),
    Size VARCHAR(20),
    Units_Sold VARCHAR(20),
    MRP VARCHAR(20),
    Discount_Applied VARCHAR(20),
    Revenue VARCHAR(20),
    Order_Date VARCHAR(50),
    Sales_Channel VARCHAR(50),
    Region VARCHAR(50),
    Profit VARCHAR(20)
);

-- One of my beginning problems of my database was that I tried create a table I did not know that the import wizard automatically
-- created a table for me after importing so I kept running into errors leading to confusion.

-- My Import Test
CREATE TABLE nike_sales_import_test (
    Order_ID INT,
    Gender_Category VARCHAR(50),
    Product_Line VARCHAR(50),
    Product_Name VARCHAR(100),
    Size VARCHAR(20),
    Units_Sold INT,
    MRP DECIMAL(10,2),
    Discount_Applied DECIMAL(5,2),
    Revenue DECIMAL(10,2),
    Order_Date DATE,
    Sales_Channel VARCHAR(50),
    Region VARCHAR(50),
    Profit DECIMAL(10,2)
);

-- Another problem I ran into is that I had to create two tables in my database because when I imported my dataset many of the rows were
-- deleted because a lot of my rows didn't match my proper datatypes meaning a huge portion of the data is dirty.

-- In response for now before cleaning I decided to create 2 tables:
-- nike_sales_import_test (the one with the lower number of rows imported: 94)
-- and nike_sales_raw which imported all the rows successfully (2501 rows).

-- I then ran into another minor mistake, I forgot to import the csv into my raw table which solved my confusion of why there were no rows
-- appearing when I tried selecting them from some columns.

-- My final table with everything correct
CREATE TABLE nike_sales_clean (
    Order_ID INT NOT NULL,
    Gender_Category VARCHAR(50),
    Product_Line VARCHAR(50),
    Product_Name VARCHAR(100),
    Size VARCHAR(20),
    Units_Sold INT,
    MRP DECIMAL(10,2),
    Discount_Applied DECIMAL(5,2),
    Revenue DECIMAL(10,2),
    Order_Date DATE,
    Sales_Channel VARCHAR(50),
    Region VARCHAR(50),
    Profit DECIMAL(10,2)
);

-- Will I exclude NULL values from my analysis or fill them?
-- Initial data exploration revealed that missing values are represented as
-- empty strings ('') rather than SQL NULL values.
-- Before analysis, missing values will be standardized to NULL so they can
-- be handled consistently using SQL functions and filtering operations.

-- Counting the blank rows from the raw table
SELECT COUNT(*)
FROM nike_sales_raw
WHERE Units_Sold = '' 
OR MRP = '' 
OR Discount_Applied = '' 
OR Order_Date = '';

-- Missing Units Count: 1235
SELECT COUNT(*) AS Missing_Units
FROM nike_sales_raw
WHERE Units_Sold = '';

-- Missing MRP Count: 1254
SELECT COUNT(*) AS Missing_MRP
FROM nike_sales_raw
WHERE MRP = '';

-- Missing Discount Count: 1668
SELECT COUNT(*) AS Missing_Discount
FROM nike_sales_raw
WHERE Discount_Applied  = '';

-- if missing values tend to cluster together 
SELECT COUNT(*) AS Fully_Populated_Rows
FROM nike_sales_raw
WHERE Units_Sold <> '' 
AND MRP <> '' 
AND Discount_Applied <> '';

SELECT COUNT(*) AS Completely_Missing_Rows
FROM nike_sales_raw
WHERE Units_Sold = ''
AND MRP = ''
AND Discount_Applied = '';

-- Findings : Type of Row				Count
--           Fully populated			 207
-- 		Completely missing key values 	 418
--         Partially populated		     1876

-- How many rows are missing only discount? (426)
SELECT COUNT(*) AS Missing_Only_Discount
FROM nike_sales_raw
WHERE Discount_Applied = ''
AND Units_Sold <> ''
AND MRP <> '';

-- How may rows are missing only units? (613)
SELECT COUNT(*) AS Missing_Only_Units
FROM nike_sales_raw
WHERE Units_Sold = ''
AND MRP <> '';

-- How many rows are missng only MRP? (233)
SELECT COUNT(*) AS Missing_Only_MRP
FROM nike_sales_raw
WHERE MRP = ''
AND Units_Sold <> ''
AND Discount_Applied <> '';

-- Updated picture: 
-- Category:	           Rows:
-- Fully populated	        207
-- Missing only Discount	426
-- Missing only Units_Sold	613
-- Missing only MRP	        233
-- Missing all three	    418
-- Other combinations	    604

-- Discount_Applied values will be converted to NULL rather than 0.00.
-- Although blank discounts may represent transactions with no discount applied,
-- the dataset does not explicitly confirm this assumption.
-- Units sold blank values will be filled with NULL since I don't know how many units were sold
-- MRP will also be filled with NULL since it's safer than converting an unknown price to a free product
-- Missing dates will also be filled with NULL as well
-- Rows missing Units_Sold, MRP, and Discount_Applied simultaneously may
-- provide limited analytical value and will be evaluated further during
-- the cleaning stage.

-- Found that when Units Sold is empty, Revenue is 0.0
SELECT Units_Sold, MRP, Revenue
FROM nike_sales_raw
WHERE Units_Sold = ''
LIMIT 10;

-- Found that when missing MRP, Revenue is also 0.0
SELECT Units_Sold, MRP, Revenue
FROM nike_sales_raw
WHERE MRP = ''
LIMIT 10;

SELECT Units_Sold, Profit
FROM nike_sales_raw
WHERE Units_Sold = ''
LIMIT 10;

-- Missing Units_Sold values will be converted to NULL rather than 0.
-- Data exploration showed multiple records with missing quantities but
-- non-zero profit values, indicating that a blank quantity does not imply
-- that zero units were sold.
--
-- Replacing these values with 0 would create misleading relationships
-- between sales quantity and financial performance.

-- Negative Units_Sold values (-1) appear to represent returns, refunds,
-- or inventory adjustments rather than missing data and will be retained.

SELECT COUNT(*) AS Negative_Unit_Rows
FROM nike_sales_raw
WHERE Units_Sold = '-1.0';

SELECT Units_Sold, Revenue, Profit
FROM nike_sales_raw
WHERE Units_Sold = '-1.0'
LIMIT 10;

-- During data exploration, I investigated negative values in Units_Sold to determine
-- whether they represented missing data or legitimate business events.
--
-- By examining the associated Revenue and Profit values, I observed that many of these
-- records contained negative revenue and losses in profit, while others still contained
-- meaningful financial values.
--
-- This suggests that negative Units_Sold values likely represent business events such as
-- product returns, exchanges, cancellations, or inventory adjustments rather than missing data.
--
-- Therefore, negative Units_Sold values will be preserved during the cleaning process.

-- Finding missing order dates
SELECT COUNT(*) AS Missing_Order_Date
FROM nike_sales_raw
WHERE Order_Date = '';

-- Finding missing profits
SELECT COUNT(*) AS Missing_Profit
FROM nike_sales_raw
WHERE Profit = '';

-- Find negative values
SELECT DISTINCT Units_Sold
FROM nike_sales_raw
WHERE Units_Sold LIKE '-%'
ORDER BY Units_Sold;

-- Investigate Blank Discounts
SELECT Discount_Applied,
       Units_Sold,
       MRP,
       Revenue,
       Profit
FROM nike_sales_raw
WHERE Discount_Applied = ''
LIMIT 10;

-- Should a Discount exist when Revenue is a non-zero?
SELECT Discount_Applied, Revenue
FROM nike_sales_raw
WHERE Revenue <> '0.0'
LIMIT 20;

SELECT COUNT(*) AS NonZero_Revenue_With_Discount
FROM nike_sales_raw
WHERE Revenue <> '0.0'
AND Discount_Applied <> '';

-- Discount_Applied contains a high proportion of missing values.
-- Exploratory analysis suggests that discount values are only recorded
-- for promotional transactions, while standard-price sales are left blank.
--
-- To preserve uncertainty and avoid introducing artificial values into the
-- dataset, missing discount values will remain NULL in the cleaned table.

-- Viewing how the dates are formatted
SELECT DISTINCT Order_Date
FROM nike_sales_raw
WHERE Order_Date <> ''
LIMIT 20;

-- Viewing the table before instertion
DESCRIBE nike_sales_clean;

-- Testing to see if the negative value is unique
SELECT DISTINCT Units_Sold
FROM nike_sales_raw
WHERE Units_Sold <> ''
ORDER BY CAST(Units_Sold AS DECIMAL(10,1));

-- ==========================================================
-- NIKE SALES DATA CLEANING PIPELINE
-- ==========================================================
--
-- Source Table:
--     nike_sales_raw
--
-- Destination Table:
--     nike_sales_clean
--
-- Objective:
--     Convert the raw imported dataset into an analytics-ready
--     dataset with standardized datatypes and missing value handling.
--
-- ==========================================================
-- DATA PROFILING FINDINGS
-- ==========================================================
--
-- 1. Missing values are represented as empty strings ('')
--    rather than SQL NULL values.
--
-- 2. Units_Sold contains negative values (-1) which appear to
--    represent legitimate business events such as returns,
--    exchanges, cancellations, or inventory adjustments.
--    These values will be preserved.
--
-- 3. Missing Units_Sold values will be converted to NULL rather
--    than 0 because exploratory analysis revealed records with
--    missing quantities but non-zero profits.
--
-- 4. Missing MRP values will be converted to NULL because an
--    unknown product price is not equivalent to a free product.
--
-- 5. Discount values will remain NULL rather than being replaced
--    with 0.0 in order to avoid introducing assumptions into the data.
--
-- 6. Order_Date contains multiple formats including:
--       YYYY-MM-DD
--       DD-MM-YYYY
--       YYYY/MM/DD
--    Dates will be standardized during transformation.
--
-- 7. Profit contains no missing values and therefore requires
--    no imputation or transformation beyond datatype conversion.
--
-- ==========================================================
-- TRANSFORMATION BEGINS BELOW
-- ==========================================================

INSERT INTO nike_sales_clean
SELECT

    -- Convert Order_ID from text to integer
    CAST(NULLIF(Order_ID, '') AS UNSIGNED) AS Order_ID,

    -- Convert blank strings to NULL for categorical variables
    NULLIF(Gender_Category, '') AS Gender_Category,
    NULLIF(Product_Line, '') AS Product_Line,
    NULLIF(Product_Name, '') AS Product_Name,
    NULLIF(Size, '') AS Size,

    -- Preserve negative values such as -1 while converting blanks to NULL
    CAST(NULLIF(Units_Sold, '') AS DECIMAL(10,1)) AS Units_Sold,

    -- Unknown prices remain NULL
    CAST(NULLIF(MRP, '') AS DECIMAL(10,2)) AS MRP,

    -- Preserve uncertainty rather than assuming 0 discount
    CAST(NULLIF(Discount_Applied, '') AS DECIMAL(5,2)) AS Discount_Applied,

    -- Revenue conversion
    CAST(NULLIF(Revenue, '') AS DECIMAL(10,2)) AS Revenue,

    -- Standardize multiple date formats
    CASE
        WHEN Order_Date LIKE '____-__-__'
            THEN STR_TO_DATE(Order_Date, '%Y-%m-%d')

        WHEN Order_Date LIKE '__-__-____'
            THEN STR_TO_DATE(Order_Date, '%d-%m-%Y')

        WHEN Order_Date LIKE '____/__/__'
            THEN STR_TO_DATE(Order_Date, '%Y/%m/%d')

        ELSE NULL
    END AS Order_Date,

    NULLIF(Sales_Channel, '') AS Sales_Channel,
    NULLIF(Region, '') AS Region,

    CAST(NULLIF(Profit, '') AS DECIMAL(10,2)) AS Profit

FROM nike_sales_raw;

-- Initial transformation failed because Units_Sold values were stored in the
-- raw dataset as decimal-formatted strings (e.g., '3.0', '-1.0') rather than
-- integer-formatted strings ('3', '-1').
--
-- Attempting to cast these values directly to SIGNED integers resulted in:
-- Error Code: 1292 - Truncated incorrect INTEGER value.
--
-- The transformation was adjusted to first cast Units_Sold to DECIMAL(10,1)
-- before inserting into the INT column of nike_sales_clean.

-- Check dates are standardized
SELECT DISTINCT Order_Date
FROM nike_sales_clean
WHERE Order_Date IS NOT NULL
LIMIT 20;

-- Verify Units_Sold is now integers
SELECT DISTINCT Units_Sold
FROM nike_sales_clean
ORDER BY Units_Sold;

-- Verify missing values became actual NULL values
SELECT COUNT(*)
FROM nike_sales_clean
WHERE Units_Sold IS NULL
OR MRP IS NULL
OR Discount_Applied IS NULL
OR Order_Date IS NULL;

-- Show all the regions
SELECT DISTINCT Region
From nike_sales_clean 
ORDER BY Region;

-- Changed 'Hyd' and 'hyderbad' to 'Hyderabad'
UPDATE nike_sales_clean
SET Region = 'Hyderabad'
WHERE Region = 'Hyd'
OR Region = 'hyderbad';

-- Changed Bengaluru to Bangalore
UPDATE nike_sales_clean
SET Region = 'Bangalore'
WHERE Region = 'Bengaluru';

-- During exploratory analysis, inconsistent region names were identified.
-- Variations such as 'Hyd', 'hyderbad', and 'Hyderabad' referred to the
-- same geographic location, as did 'Bangalore' and 'Bengaluru'.
--
-- These values were standardized in the cleaned dataset to ensure that
-- revenue and profit were aggregated correctly by region.

-- Show me the 10 individual transactions with the highest revenue.
SELECT *
FROM nike_sales_clean
WHERE Region IN ('Bangalore', 'Delhi', 'Hyderabad', 'Kolkata', 'Mumbai', 'Pune')
ORDER BY Revenue DESC
LIMIT 10;

-- Total Revenue & Profit
SELECT
    SUM(Revenue) AS Total_Revenue,
    SUM(Profit) AS Total_Profit
FROM nike_sales_clean;
-- SELECT: Chooses what information to display
-- SUM(): Adds every value in the column together
-- AS: Renames the calculated column
-- FROM: Specifies which table to retrieve data from

-- Revenue & Profit by Region
SELECT Region,
       SUM(Revenue) AS Revenue,
       SUM(Profit) AS Profit
FROM nike_sales_clean
GROUP BY Region
ORDER BY Revenue DESC;
-- SELECT: Chooses the columns to display
-- SUM(): Calculates total revenue and profit
-- AS: Gives calculated columns readable names
-- FROM: Selects the table to query
-- GROUP BY: Combines rows with the same region
-- ORDER BY: Sorts the results
-- DESC: Displays highest values first

-- Monthly Revenue Trend
SELECT
    YEAR(Order_Date) AS Year,
    MONTH(Order_Date) AS Month,
    SUM(Revenue) AS Monthly_Revenue
FROM nike_sales_clean
WHERE Order_Date IS NOT NULL
GROUP BY Year, Month
ORDER BY Year, Month;
-- YEAR(): Extracts the year from a date
-- MONTH(): Extracts the month from a date
-- SUM(): Calculates total monthly revenue
-- WHERE: Filters rows before calculations
-- IS NOT NULL: Excludes missing dates
-- GROUP BY: Groups transactions by month and year
-- ORDER BY: Sorts months chronologically

-- Revenue by Product Line
SELECT Product_Line,
       SUM(Revenue) AS Revenue
FROM nike_sales_clean
GROUP BY Product_Line
ORDER BY Revenue DESC;
-- SELECT: Chooses the columns to display
-- SUM(): Calculates total revenue
-- GROUP BY: Combines rows with the same product line
-- ORDER BY: Sorts the results
-- DESC: Displays highest revenue first 