SELECT 
    in_file, 
    COUNT(*) AS TotalRecords, 
    SUM(CASE WHEN email IS NULL THEN 1 ELSE 0 END) AS NullEmails
FROM 
    AdventureWorksDW2022.dbo.STG_CUSTOMERS
GROUP BY 
    in_file
ORDER BY 
    CAST(in_file AS INT);
