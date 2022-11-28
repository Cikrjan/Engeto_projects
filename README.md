Průvodní listina k SQL_project_1
===

U všech výzkumných otázek se zkoumaly data z období roků 2006 až 2018, z důvodu absence dat v databázi cen potravin za období roků 2000 až 2005 a 2019 až 2021.
 

Výzkumné otázky
 1.	Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
 2.	Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?
 3.	Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)?
 4.	Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
 5.	Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, 
	projeví se to na cenách potravin či mzdách ve stejném nebo násdujícím roce výraznějším růstem?
	
Odpovědi na výzkumné otázky
 1.	V žádném odvětví v průběhu let mzdy nerostou bez jakékoliv výkyvu.
 
	Nejblíže tomu je odvětví Zemědělství, lesnictví, rybářství, kde se vyskytují jen dva propady mezd a to v roce 2011 a 2017.
	Pokud bychom porovnali přímo mzdy z počátečního a koncového roku, lze vidět růst ve všech odvětví.
	
 2.	V roce 2006, tedy v prvním srovnatelném období, bylo možné koupit 1203 kilogramů chleba a 1345 litrů mléka. 
	V roce 2018, tedy v posledním srovnatelném období, bylo možné koupit 1252 kilogramů chleba a 1531 litrů mléka.

 3.	Nejnižší percentuální meziroční nárůst má kategorie "Rajská jablka červená kulatá" s hodnotou -30,28%.
 
	U této otázky jsem vytvořil pomocnou tabulku, ve které jsem si pomocí funkce LEAD zobrazil roky 2007 - 2018. 
	Sloučením této tabulky a tabulky t_jan_cikryt_project_sql_primary_final jsem v jednom řádku dostal rozdíl aktuálního a předchozího roku. 
	Z toho bylo poté možné vypočítat percentilový meziroční nárůst. Poté jsem vytvořil VIEW, aby bylo možno s tímto výsledkem dále pracovat.
	Nakonec jsem vyfiltroval minimální hodnotu ze všech kategorií potravin. 
	Rok 2018 není relevantní pro výpočet, protože nejsou k dispozici ceny potravin z roku 2019.
 
 4.	V každém roce nalezneme meziroční růst potravin, který je výrazně vyšší než meziroční růst mezd (větší než 10%). 
 
	U této otázky jsem postupoval obdobně jako u otázky č. 3, s tím, že jsem si navíc vytvořil VIEW s meziročním růstem mezd, který jsem následně spojil s VIEW obsahující meziroční růst cen potravin.
	Z tohoto pak bylo možné zobrazit žádaný desetiprocentní rozdíl.
 
 5.	Ne, růst HDP nemá vliv na změny ve mzdách a cenách potravin. 
 
	Z uvedených dat lze vyčíst, že ve většině případů ikdyž HDP jeden rok poklesne, platy nebo ceny potravin si drží stejnou nebo dokonce vyšší hodnotu. 
	Pokud bychom porovnali data v proůběhu let srovnávaného období, lze u všech tří měřených sloupců (mzdy, ceny potravin, HDP) vidět růst.
 
 
 
 