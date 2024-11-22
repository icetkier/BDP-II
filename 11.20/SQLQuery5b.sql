-- Zmiana nazwiska dla EmployeeKey = 270
-- Type 1: overwrite
-- Ustawienie Changing Attribute nadpisuje istniej¹cy rekord w przypadku zmiany danych. 
-- Dlatego nazwisko zosta³o zaktualizowane w miejscu bez tworzenia nowego rekordu.
UPDATE AdventureWorksDW2022.dbo.stg_dimemp
SET LastName = 'Nowak'
WHERE EmployeeKey = 270;

-- Zmiana tytu³u dla EmployeeKey = 274
-- Type 2: add new row
-- Ustawienie Historical Attribute powoduje utworzenie nowego rekordu w tabeli scd_dimemp 
-- z nowym tytu³em, oznaczaj¹c poprzedni rekord jako historyczny (ustawiaj¹c EndDate).
UPDATE AdventureWorksDW2022.dbo.stg_dimemp
SET TITLE = 'Senior Design Engineer'
WHERE EmployeeKey = 274;
