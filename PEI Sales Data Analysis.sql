/* Creating PEI Sales Database*/

CREATE DATABASE PEISalesDB;

/*Creating Tables to load raw data from Excel, CSV and JSON*/

/*Customer*/

CREATE TABLE Customers (
    Customer_ID INT PRIMARY KEY,
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    Age INT,
    Country VARCHAR(100)
);

GO

/*Orders*/

CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Item VARCHAR(100),
    Amount INT,
    Customer_ID INT
);

GO

/*Shipping*/

CREATE TABLE Shippings (
    Shipping_ID INT PRIMARY KEY,
    Status VARCHAR(50),
    Customer_ID INT
);

GO

select * from Shippings