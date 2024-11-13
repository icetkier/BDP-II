SELECT 
    OrderDate, 
    COUNT(*) AS Orders_Cnt
FROM 
    AdventureWorksDW2022.dbo.FactInternetSales
GROUP BY 
    OrderDate
HAVING 
    COUNT(*) < 100
ORDER BY 
    Orders_Cnt DESC;
