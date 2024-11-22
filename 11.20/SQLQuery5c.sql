-- Zmiana imienia dla EmployeeKey = 275
-- Type 0: retain original
-- Dla pola FirstName zastosowano Fixed Attribute, co oznacza brak mo¿liwoœci zmiany atrybutu po jego pierwszym za³adowaniu. 
-- W konfiguracji SSIS, opcja "Fail the transformation if changes are detected in a fixed attribute" spowodowa³a, ¿e proces 
-- zakoñczy³ siê b³êdem przy wykryciu ró¿nicy, co zapobieg³o zmianie danych w tabeli scd_dimemp.
UPDATE AdventureWorksDW2022.dbo.stg_dimemp
SET FirstName = 'Ryszard'
WHERE EmployeeKey = 275;
