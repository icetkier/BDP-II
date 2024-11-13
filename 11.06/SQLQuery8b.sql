SELECT 
    OrderDate, 
    ProductKey, 
    UnitPrice
FROM (
    SELECT 
        OrderDate,
        ProductKey,
        UnitPrice,
        ROW_NUMBER() OVER (PARTITION BY OrderDate ORDER BY UnitPrice DESC) AS ProductRank
    FROM 
        AdventureWorksDW2022.dbo.FactInternetSales
) AS RankedProducts
WHERE 
    ProductRank <= 3
ORDER BY 
    OrderDate ASC;
