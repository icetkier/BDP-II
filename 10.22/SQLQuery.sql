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

-- Kwerenda jest zapytaniem skierowanym do bazy danych, które pozwala na przeszukiwanie, przegl¹danie i analizowanie danych. Kwerendy s³u¿¹ do
-- wyci¹gania konkretnej informacji z bazy danych na podstawie ustalonych kryteriów, czêsto w celu jednorazowego u¿ycia lub analizy bie¿¹cych danych.
-- Proces ETL natomiast obejmuje trzy etapy: ekstrakcjê (Extract), transformacjê (Transform) i ³adowanie danych (Load). Celem ETL jest przekszta³cenie 
-- danych z ró¿nych Ÿróde³ i zintegrowanie ich w jednym docelowym magazynie danych, takim jak hurtownia danych. ETL pozwala na przechowywanie danych w 
-- znormalizowanej formie, co wspiera kompleksowe analizy i d³ugoterminowe raportowanie.

-- Zalety procesu ETL:
-- Usprawnienie analizy danych – ETL konsoliduje dane z ró¿nych Ÿróde³, standaryzuje je i integruje, co u³atwia ich analizê.
-- Poprawa jakoœci danych – Transformacja obejmuje czyszczenie danych, co minimalizuje b³êdy i niespójnoœci, zwiêkszaj¹c ich jakoœæ i wiarygodnoœæ.
-- Integracja ró¿nych Ÿróde³ – ETL pozwala na scalenie danych z wielu systemów, tworz¹c kompleksowy obraz dzia³alnoœci firmy.
-- Automatyzacja procesów – Dziêki automatyzacji proces ETL mo¿e dzia³aæ regularnie i bez interwencji cz³owieka, co zwiêksza efektywnoœæ i ogranicza ryzyko b³êdów.

-- Wady procesu ETL:
-- Wysoki koszt wdro¿enia – Proces ETL wymaga czêsto zaawansowanych narzêdzi i zasobów, co mo¿e wi¹zaæ siê z du¿ymi kosztami.
-- Z³o¿onoœæ – Implementacja ETL wymaga czêsto specjalistycznej wiedzy, co mo¿e sprawiaæ trudnoœci w mniejszych organizacjach.
-- Ryzyko b³êdów podczas ³adowania danych – Jeœli proces ³adowania nie jest odpowiednio zarz¹dzany, mog¹ pojawiæ siê problemy z integralnoœci¹ danych w magazynie docelowym.
-- OpóŸnienie w dostêpie do aktualnych danych – Poniewa¿ proces ETL zazwyczaj odbywa siê w cyklach (np. codziennie, co godzinê), mo¿e nie uwzglêdniaæ najnowszych zmian w danych w czasie rzeczywistym.