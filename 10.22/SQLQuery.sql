CREATE PROCEDURE usp_GetCurrencyRates
    @YearsAgo INT = 11
AS
BEGIN
    DECLARE @DateYearsAgo DATE = DATEADD(YEAR, -@YearsAgo, GETDATE());
    SELECT 
        f.CurrencyKey,
        f.DateKey,
        f.AverageRate,
        f.EndOfDayRate,
        f.Date,
        d.CurrencyAlternateKey
    FROM 
        AdventureWorksDW2022.dbo.FactCurrencyRate AS f
    INNER JOIN 
        AdventureWorksDW2022.dbo.DimCurrency AS d
    ON 
        f.CurrencyKey = d.CurrencyKey
    WHERE 
        (d.CurrencyAlternateKey = 'GBP' OR d.CurrencyAlternateKey = 'EUR')
        AND f.Date <= @DateYearsAgo;
END;

-- Kwerenda jest zapytaniem skierowanym do bazy danych, kt�re pozwala na przeszukiwanie, przegl�danie i analizowanie danych. Kwerendy s�u�� do
-- wyci�gania konkretnej informacji z bazy danych na podstawie ustalonych kryteri�w, cz�sto w celu jednorazowego u�ycia lub analizy bie��cych danych.
-- Proces ETL natomiast obejmuje trzy etapy: ekstrakcj� (Extract), transformacj� (Transform) i �adowanie danych (Load). Celem ETL jest przekszta�cenie 
-- danych z r�nych �r�de� i zintegrowanie ich w jednym docelowym magazynie danych, takim jak hurtownia danych. ETL pozwala na przechowywanie danych w 
-- znormalizowanej formie, co wspiera kompleksowe analizy i d�ugoterminowe raportowanie.

-- Zalety procesu ETL:
-- Usprawnienie analizy danych � ETL konsoliduje dane z r�nych �r�de�, standaryzuje je i integruje, co u�atwia ich analiz�.
-- Poprawa jako�ci danych � Transformacja obejmuje czyszczenie danych, co minimalizuje b��dy i niesp�jno�ci, zwi�kszaj�c ich jako�� i wiarygodno��.
-- Integracja r�nych �r�de� � ETL pozwala na scalenie danych z wielu system�w, tworz�c kompleksowy obraz dzia�alno�ci firmy.
-- Automatyzacja proces�w � Dzi�ki automatyzacji proces ETL mo�e dzia�a� regularnie i bez interwencji cz�owieka, co zwi�ksza efektywno�� i ogranicza ryzyko b��d�w.

-- Wady procesu ETL:
-- Wysoki koszt wdro�enia � Proces ETL wymaga cz�sto zaawansowanych narz�dzi i zasob�w, co mo�e wi�za� si� z du�ymi kosztami.
-- Z�o�ono�� � Implementacja ETL wymaga cz�sto specjalistycznej wiedzy, co mo�e sprawia� trudno�ci w mniejszych organizacjach.
-- Ryzyko b��d�w podczas �adowania danych � Je�li proces �adowania nie jest odpowiednio zarz�dzany, mog� pojawi� si� problemy z integralno�ci� danych w magazynie docelowym.
-- Op�nienie w dost�pie do aktualnych danych � Poniewa� proces ETL zazwyczaj odbywa si� w cyklach (np. codziennie, co godzin�), mo�e nie uwzgl�dnia� najnowszych zmian w danych w czasie rzeczywistym.