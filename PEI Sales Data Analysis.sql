/* Creating PEI Sales Database*/

CREATE DATABASE PEISalesDB;

USE PEISalesDB


/*Creating Tables to load raw data from Excel, CSV and JSON*/

/*Customer*/
CREATE TABLE stg_customers (
    Customer_ID INT PRIMARY KEY,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    Age INT,
    Country VARCHAR(100)
);

GO

/*stg_orders*/
CREATE TABLE stg_orders (
    Order_ID INT PRIMARY KEY,
    Item VARCHAR(100),
    Amount INT,
    Customer_ID INT
);

GO

/*Shipping*/
CREATE TABLE stg_shippings (
    Shipping_ID INT PRIMARY KEY,
    Status VARCHAR(50),
    Customer_ID INT
);


-- Checking row counts in staging tables

SELECT COUNT(*) AS Total_Customer_Rows FROM stg_customers;

SELECT COUNT(*) AS Total_Orders_Rows FROM stg_orders;

SELECT COUNT(*) AS Total_Shipping_Rows FROM stg_shippings;

-- Checking Nulls in stg_customers table
SELECT
  COUNT(*) AS total_records,
  SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
  SUM(CASE WHEN FirstName IS NULL THEN 1 ELSE 0 END) AS null_firstname,
  SUM(CASE WHEN LastName IS NULL THEN 1 ELSE 0 END) AS null_lastname,
  SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS null_age,
  SUM(CASE WHEN Country IS NULL THEN 1 ELSE 0 END) AS null_country
FROM stg_customers;

-- Checking Nulls in stg_orders table
SELECT
  COUNT(*) AS total_records,
  SUM(CASE WHEN Order_ID IS NULL THEN 1 ELSE 0 END) AS null_order_id,
  SUM(CASE WHEN Item IS NULL THEN 1 ELSE 0 END) AS null_item,
  SUM(CASE WHEN Amount IS NULL THEN 1 ELSE 0 END) AS null_amount,
  SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END) AS null_customer_id
FROM stg_orders;

-- Checking  Nulls in stg_shippings table
SELECT
  COUNT(*) AS total_records,
  SUM(CASE WHEN Shipping_ID IS NULL THEN 1 ELSE 0 END) AS null_shipping_id,
  SUM(CASE WHEN Status IS NULL THEN 1 ELSE 0 END) AS null_status,
  SUM(CASE WHEN Customer_ID IS NULL THEN 1 ELSE 0 END) AS null_customer_id
FROM stg_shippings;

/*Checking for Duplicate records*/

-- Duplicate CustomerIDs
SELECT Customer_ID, COUNT(*) AS Duplicate_CustomerIDs
FROM stg_customers
GROUP BY Customer_ID
HAVING COUNT(*) > 1;

-- Duplicate Order_IDs
SELECT Order_ID, COUNT(*) AS Duplicate_Order_IDs
FROM stg_orders
GROUP BY Order_ID
HAVING COUNT(*) > 1;

-- Duplicate Shipping_IDs
SELECT Shipping_ID, COUNT(*) AS Duplicate_Shipping_IDs
FROM stg_shippings
GROUP BY Shipping_ID
HAVING COUNT(*) > 1;

-- Duplicate Items with different amount
select Item, Amount from stg_orders 
group by Item, Amount

/*Checking Data Type Validity*/

SELECT * FROM stg_customers 
WHERE FirstName LIKE '%!%' OR FirstName LIKE '%@%' OR FirstName REGEXP'[0-9]';

-- Alpha-Numeric and Special Characters in First Name
SELECT * FROM stg_customers
WHERE FirstName LIKE '%[^a-zA-Z0-9 _-]%'

-- Alpha-Numeric and Special Characters in Last Name
SELECT * FROM stg_customers	
WHERE LastName LIKE '%[^a-zA-Z0-9 _-]%'

-- Alpha-Numeric and Special Characters in Country
SELECT * FROM stg_customers
WHERE Country LIKE '%[^a-zA-Z0-9 _-]%'

-- Alpha-Numeric and Special Characters in Item
SELECT * FROM stg_orders
WHERE Item LIKE '%[^a-zA-Z0-9 _-]%'

-- Age Range
SELECT MIN(Age) as Min_Age, MAX(Age) as Max_Age, AVG(Age) as Avg_Age FROM stg_customers;

-- Negative or unrealistic ages
SELECT * FROM stg_customers WHERE Age <= 0 OR Age >= 120;

-- Invalid Amounts
SELECT * FROM stg_orders WHERE Amount <= 0;

-- Product distribution
SELECT Item, COUNT(*) FROM stg_orders GROUP BY Item;

-- Amount validation by product
SELECT Item, MIN(Amount) as Min_Amount, MAX(Amount) as Max_Amount, AVG(Amount) as Avg_Amount
FROM stg_orders 
GROUP BY Item;

-- Invalid Customer_ID references
SELECT o.* FROM stg_orders o 
LEFT JOIN stg_customers c ON o.Customer_ID = c.Customer_ID 
WHERE c.Customer_ID IS NULL;

-- Status distribution
SELECT Status, COUNT(*) as Total_Shippings FROM stg_shippings GROUP BY Status

-- Invalid status values
SELECT DISTINCT Status FROM stg_shippings 
WHERE Status NOT IN ('Pending', 'Delivered');

/*Checking Referential Integrity*/
/*Ensuring all CustomerIDs in orders Data and shippings Data exist in customers Data*/


--Invalid Customer in Orders
SELECT * FROM stg_orders o
LEFT JOIN stg_customers c ON o.Customer_ID = c.Customer_ID
WHERE c.Customer_ID IS NULL;

--Invalid Customer in Shippings
SELECT * FROM stg_shippings s
LEFT JOIN stg_customers c ON s.Customer_ID = c.Customer_ID
WHERE c.Customer_ID IS NULL;


-- Duplicate orders
SELECT Customer_ID, Item, Amount, COUNT(*) 
FROM stg_orders 
GROUP BY Customer_ID, Item, Amount 
HAVING COUNT(*) > 1;


-- Cross Data Analysis

-- Customers in Orders but not Shipping (61
SELECT COUNT(DISTINCT o.Customer_ID) as Customers_order_vs_shippings
FROM stg_orders o 
LEFT JOIN stg_shippings s ON o.Customer_ID = s.Customer_ID 
WHERE s.Shipping_ID IS NULL;

-- Customers in Shipping but not Orders 
SELECT COUNT(DISTINCT s.Customer_ID) as Customers_shipping_vs_orders
FROM stg_shippings s 
LEFT JOIN stg_orders o ON s.Customer_ID = o.Customer_ID 
WHERE o.Order_ID IS NULL;