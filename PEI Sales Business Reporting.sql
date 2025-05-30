--Business Reporting Requirements

-- Total amount spent and the country for the "Pending" delivery status for each country
SELECT 
    c.Country,
    SUM(o.Amount) AS TotalAmountSpent
FROM fact_shipping s
JOIN dim_customer c ON s.Customer_ID = c.Customer_ID
JOIN fact_orders o ON s.Customer_ID = o.Customer_ID
WHERE s.Status = 'Pending'
GROUP BY c.Country;


-- Total number of transactions, total quantity sold, and total amount spent for each customer, along with the product details

SELECT 
    c.Customer_ID,
    c.FirstName,
    c.LastName,
    p.Item,
    COUNT(o.Order_ID) AS TotalTransactions,
    SUM(o.Quantity) AS TotalQuantitySold,
    SUM(o.Amount) AS TotalAmountSpent
FROM fact_orders o
JOIN dim_customer c ON o.Customer_ID = c.Customer_ID
JOIN dim_item p ON o.Item_ID = p.Item_ID
GROUP BY c.Customer_ID, c.FirstName, c.LastName, p.Item
ORDER BY c.Customer_ID


-- The maximum product purchased for each country

WITH product_country_sales AS (
    SELECT 
        c.Country,
        p.Item,
        SUM(o.Quantity) AS TotalQuantity
    FROM fact_orders o
    JOIN dim_customer c ON o.Customer_ID = c.Customer_ID
    JOIN dim_item p ON o.Item_ID = p.Item_ID
    GROUP BY c.Country, p.Item
),
ranked_products AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY Country ORDER BY TotalQuantity DESC) AS rn
    FROM product_country_sales
)
SELECT Country, Item, TotalQuantity
FROM ranked_products
WHERE rn = 1;


--The most purchased product based on the age category: less than 30 and 30 or above

WITH product_age_sales AS (
    SELECT 
        c.AgeCategory,
        p.Item,
        SUM(o.Quantity) AS TotalQuantity
    FROM fact_orders o
    JOIN dim_customer c ON o.Customer_ID = c.Customer_ID
    JOIN dim_item p ON o.Item_ID = p.Item_ID
    GROUP BY c.AgeCategory, p.Item
),
ranked_age_products AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY AgeCategory ORDER BY TotalQuantity DESC) AS rn
    FROM product_age_sales
)
SELECT AgeCategory, Item, TotalQuantity
FROM ranked_age_products
WHERE rn = 1;


--The country that had the minimum transactions and sales amount

SELECT TOP 1
    c.Country,
    COUNT(o.Order_ID) AS TotalTransactions,
    SUM(o.Amount) AS TotalSalesAmount
FROM fact_orders o
JOIN dim_customer c ON o.Customer_ID = c.Customer_ID
GROUP BY c.Country
ORDER BY 
    COUNT(o.Order_ID) ASC,
    SUM(o.Amount) ASC;
