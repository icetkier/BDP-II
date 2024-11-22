-- Zmiana imienia dla EmployeeKey = 275
-- Type 0: retain original
-- Dla pola FirstName zastosowano Fixed Attribute, co oznacza brak mo�liwo�ci zmiany atrybutu po jego pierwszym za�adowaniu. 
-- W konfiguracji SSIS, opcja "Fail the transformation if changes are detected in a fixed attribute" spowodowa�a, �e proces 
-- zako�czy� si� b��dem przy wykryciu r�nicy, co zapobieg�o zmianie danych w tabeli scd_dimemp.
UPDATE AdventureWorksDW2022.dbo.stg_dimemp
SET FirstName = 'Ryszard'
WHERE EmployeeKey = 275;
