CREATE TABLE Final.FactSales(
    Sales_Key INT IDENTITY(1,1) PRIMARY KEY,
    Order_ID NVARCHAR(50) NOT NULL,
    Order_Date DATE NOT NULL,
    Ship_Date DATE NOT NULL,
    Ship_Key INT NOT NULL,
    Customer_Key INT NOT NULL,
    Product_Key INT NOT NULL,
    Address_Key INT NOT NULL,
    Actual_Amount DECIMAL(18, 4) NOT NULL,
    Sale_Amount DECIMAL(18, 4) NOT NULL,
    Quantity INT NOT NULL,
    Discount DECIMAL(5, 2) NOT NULL,
    Profit DECIMAL(18, 4) NOT NULL
)

ALTER TABLE Final.FactSales
ADD CONSTRAINT FK_Customer
FOREIGN KEY(Customer_Key)
REFERENCES Final.Customers(Customer_Key);

ALTER TABLE Final.FactSales
ADD CONSTRAINT FK_Product
FOREIGN KEY(Product_Key)
REFERENCES Final.Products(Product_Key);

ALTER TABLE Final.FactSales
ADD CONSTRAINT FK_Address
FOREIGN KEY(Address_Key)
REFERENCES Final.Address(Address_Key);

ALTER TABLE Final.FactSales
ADD CONSTRAINT FK_Ship
FOREIGN KEY(Ship_Key)
REFERENCES Final.Ship(Ship_Key);

ALTER TABLE Final.FactSales
ADD CONSTRAINT FK_OrderDate
FOREIGN KEY(Order_Date) 
REFERENCES Final.Dates(Date);

ALTER TABLE Final.FactSales
ADD CONSTRAINT FK_ShipDate
FOREIGN KEY(Ship_Date)
REFERENCES Final.Dates(Date);

SELECT * FROM Final.FactSales;


-- ALTER TABLE Final.FactSales DROP CONSTRAINT FK_Customer;
-- ALTER TABLE Final.FactSales DROP CONSTRAINT FK_Product;
-- ALTER TABLE Final.FactSales DROP CONSTRAINT FK_OrderDate;
-- ALTER TABLE Final.FactSales DROP CONSTRAINT FK_ShipDate;
-- ALTER TABLE Final.FactSales DROP CONSTRAINT FK_Address;
-- ALTER TABLE Final.FactSales DROP CONSTRAINT FK_Ship;
-- DROP TABLE IF EXISTS Final.FactSales;
