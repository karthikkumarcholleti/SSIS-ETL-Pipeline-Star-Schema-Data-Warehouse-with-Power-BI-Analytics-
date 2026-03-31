IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Final')
BEGIN
	EXEC('CREATE SCHEMA Final');
END

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'DataImport')
BEGIN
	EXEC('CREATE SCHEMA DataImport');
END


CREATE TABLE DataImport.Superstore (
    Row_ID smallint NOT NULL,
    Order_ID nvarchar(50) NOT NULL,
    Order_Date date NOT NULL,
    Ship_Date date NOT NULL,
    Ship_Mode nvarchar(50) NOT NULL,
    Customer_ID nvarchar(50) NOT NULL,
    Customer_Name nvarchar(50) NOT NULL,
    Segment nvarchar(50) NOT NULL,
    Country nvarchar(50) NOT NULL,
    City nvarchar(50) NOT NULL,
    State nvarchar(50) NOT NULL,
    Postal_Code int NOT NULL,
    Region nvarchar(50) NOT NULL,
    Product_ID nvarchar(50) NOT NULL,
    Category nvarchar(50) NOT NULL,
    Sub_Category nvarchar(50) NOT NULL,
    Product_Name nvarchar(150) NOT NULL,
    Sales DECIMAL(18,5) NOT NULL,
    Quantity tinyint NOT NULL,
    Discount DECIMAL(5,2) NOT NULL,
    Profit DECIMAL(18,2) NOT NULL);


DROP TABLE IF EXISTS Final.Customers;

SELECT DISTINCT CONVERT(VARCHAR(20), Customer_ID)   AS Customer_ID,  -- Since the column has mixed types
                CONVERT(NVARCHAR(100), Customer_Name) AS Customer_Name, -- Since the column coluld have Names from different languages
                CONVERT(VARCHAR(20), Segment)         AS Segment -- Since the column has text values
INTO Final.Customers FROM DataImport.Superstore;

ALTER TABLE Final.Customers
ADD Customer_Key INT IDENTITY(1, 1) PRIMARY KEY; -- Adding a surrogate primary key


-- Creating a dimension table 'Products' in the 'Final' schema
DROP TABLE IF EXISTS Final.Products;

SELECT CONVERT(VARCHAR(20), Product_ID) AS Product_ID, -- Since the column has mixed types
       CAST(SUM(Sales / NULLIF(1.0 - Discount, 0)) / NULLIF(SUM(Quantity), 0) AS DECIMAL(10, 2)) AS Selling_Price, -- Calculating Unit Price (safe divide-by-zero)
       CAST(SUM(Sales - Profit) / NULLIF(SUM(Quantity), 0) AS DECIMAL(10, 4)) AS Cost_Price, -- Calculating Cost Price (safe divide-by-zero)
       CONVERT(VARCHAR(50), Category) AS Category, -- Since the column has text values
       CONVERT(VARCHAR(50), Sub_Category) AS Sub_Category, -- Since the column has text values
       STRING_AGG(CONVERT(NVARCHAR(200), Product_Name), '/') AS Product_Name -- Concatenating product names for the same product ID
INTO Final.Products
FROM DataImport.Superstore
GROUP BY Product_ID, Category, Sub_Category;

ALTER TABLE Final.Products
ADD Product_Key INT IDENTITY(1, 1) PRIMARY KEY; -- Adding a surrogate primary key


-- Creating a dimnension table 'Address' in the 'Final' schema
DROP TABLE IF EXISTS Final.Address;

SELECT DISTINCT CONVERT(VARCHAR(50), Country) AS Country, -- Since the column has text values
                CONVERT(VARCHAR(50), City) AS City, -- Since the column has text values
                CONVERT(VARCHAR(50), State) AS State, -- Since the column has text values
                CONVERT(VARCHAR(20), Postal_Code) AS Postal_Code, -- Since columns like Postal Codes shoul dnot be aggrigated
                CONVERT(VARCHAR(20), Region) AS Region -- Since the column has text values
INTO Final.Address FROM DataImport.Superstore;

ALTER TABLE Final.Address
ADD Address_Key INT IDENTITY(1, 1) PRIMARY KEY; -- Adding a surrogate primary key


-- creating a dimension table 'Ship'in the 'Final' schema
DROP TABLE IF EXISTS Final.Ship;

SELECT DISTINCT CONVERT(VARCHAR(20), Ship_Mode) AS Ship_Mode
INTO Final.Ship FROM DataImport.Superstore;

ALTER TABLE Final.Ship 
ADD Ship_Key INT IDENTITY(1, 1) PRIMARY KEY;


-- creating a dimension table 'Dates'in the 'Final' schema
CREATE TABLE Final.Dates(
    Date DATE PRIMARY KEY,
    Year INT,
    Month INT,
    Month_Name VARCHAR(20),
    Quarter INT,
    Day_Name VARCHAR(20),
    Day_of_Week INT
);

DECLARE @StartDate DATE = '2014-01-01';
DECLARE @EndDate DATE = '2018-12-31';

;WITH DateCTE AS (
    SELECT @StartDate AS Dt
    UNION ALL
    SELECT DATEADD(DAY, 1, Dt)
    FROM DateCTE
    WHERE Dt < @EndDate
)
INSERT INTO Final.Dates
SELECT 
    Dt AS [Date],
    YEAR(Dt) AS [Year],
    MONTH(Dt) AS [Month],
    DATENAME(MONTH, Dt) AS [Month_Name],
    DATEPART(QUARTER, Dt) AS [Quarter],
    DATENAME(WEEKDAY, Dt) AS [Day_Name],
    DATEPART(WEEKDAY, Dt) AS [Day_Of_Week]
FROM DateCTE
OPTION (MAXRECURSION 32767);

