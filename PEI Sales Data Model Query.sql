--Creating Dimensions and Fact Tables based on the proposed Data Model


-- Dimension: Customer
CREATE TABLE dim_customer (
    Customer_ID INT PRIMARY KEY,
    FirstName NVARCHAR(100),
    LastName NVARCHAR(100),
    Age INT,
    Country NVARCHAR(100),
    AgeCategory NVARCHAR(20)
);

-- Dimension: Product
CREATE TABLE dim_item (
    Item_ID INT PRIMARY KEY IDENTITY(1,1),
    Item NVARCHAR(200),
    Amount INT  -- Standard price per product
);

-- Fact Table: Orders
CREATE TABLE fact_orders (
    Order_ID INT PRIMARY KEY,
    Item_ID INT,
	Item NVARCHAR(200),
    Amount INT,
    Quantity INT DEFAULT 1,
    Customer_ID INT,
    CONSTRAINT fk_orders_product FOREIGN KEY (Item_ID) REFERENCES dim_item(Item_ID),
    CONSTRAINT fk_orders_customer FOREIGN KEY (Customer_ID) REFERENCES dim_customer(Customer_ID)
);

-- Fact Table: Shipping
CREATE TABLE fact_shipping (
    Shipping_ID INT PRIMARY KEY,
    Status NVARCHAR(50),
    Customer_ID INT,
    CONSTRAINT fk_shipping_customer FOREIGN KEY (Customer_ID) REFERENCES dim_customer(Customer_ID)
);

-- Loading data from stg_customer to dim_customer
INSERT INTO dim_customer (Customer_ID, FirstName, LastName, Age, Country, AgeCategory)
SELECT 
    Customer_ID,
    FirstName,
    LastName,
    Age,
    Country,
    CASE 
        WHEN Age < 30 THEN 'Less than 30'
        ELSE 'Above 30'
    END AS AgeCategory -- Added bew column Age category to distinguish different age group customer
FROM stg_customers;

SELECT * FROM dim_customer;

-- Loading distinct items and amounts from stg_orders to dim_items
INSERT INTO dim_item(Item, Amount)
SELECT DISTINCT 
    Item AS ProductName,
    Amount  -- Assumes same price per product; if prices vary, consider using average or latest price
FROM stg_orders
GROUP BY Item, Amount;


-- Loading fact_orders from stg_orders along with ProductID lookup
INSERT INTO fact_orders (Order_ID, Item_id, Item, Amount, Quantity, Customer_ID)
SELECT 
    o.Order_ID,
    p.Item_ID,
	p.Item,
    o.Amount,
    1 AS Quantity,
    o.Customer_ID
FROM stg_orders o
JOIN dim_item p ON o.Item = p.Item and o.Amount = p.Amount
JOIN dim_customer c ON o.Customer_ID = c.Customer_ID;

SELECT * FROM fact_orders


-- Loading fact_shipping from stg_shipping
INSERT INTO fact_shipping (Shipping_ID, Status, Customer_ID)
SELECT 
    Shipping_ID,
    Status,
    Customer_ID
FROM stg_shippings
WHERE Customer_ID IN (SELECT Customer_ID FROM dim_customer); 


SELECT * FROM fact_shipping
