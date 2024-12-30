DROP TABLE IF EXISTS AdventureWorksDW2022.dbo.CUSTOMERS_406342;
CREATE TABLE AdventureWorksDW2022.dbo.CUSTOMERS_406342 (
    ProductKey INT,
    CurrencyAlternateKey VARCHAR(10),
    FirstName VARCHAR(100),
    LastName VARCHAR(100),
    OrderDateKey INT,
    OrderQuantity INT,
    UnitPrice DECIMAL(10,4),
	SecretCode VARCHAR(10)
);