/*
 * First primary table
 */
CREATE OR REPLACE TABLE t_payroll AS (
	SELECT cp.payroll_year AS Platy_rok, 
		cpib.name AS Profesni_odvetvi, 
		round(avg(cp.value)) AS Prumerny_plat
	FROM czechia_payroll cp 
	JOIN czechia_payroll_industry_branch cpib 
		ON cp.industry_branch_code = cpib.code 
	WHERE cp.value IS NOT NULL
		AND cp.payroll_year BETWEEN 2006 AND 2018
	GROUP BY cp.payroll_year, cpib.name
	ORDER BY cpib.code, cp.payroll_year 
);
/*
 * Second primary table
 */
CREATE OR REPLACE TABLE t_food_prices AS (
	SELECT 
		cpc.name AS Kategorie_potravin, 
		cp.value AS Cena, 
		cpc.price_value AS Mnozstvi_potraviny, 
		cpc.price_unit AS Jednotka, 
		YEAR(cp.date_from) AS Pot_rok_z,
		YEAR(cp.date_to) AS Pot_rok_k
	FROM czechia_price cp 
	JOIN czechia_price_category cpc 
		ON cp.category_code = cpc.code 
	WHERE cp.region_code IS NULL
	GROUP BY cp.date_from, cpc.name 
	ORDER BY cp.category_code, cp.date_from
);
/*
 * Third primary table
 */
CREATE OR REPLACE TABLE t_gdp_cze AS (
	SELECT e.GDP AS HDP,
		e.`year` AS HDP_rok
	FROM economies e
	WHERE e.country = 'Czech Republic'
		AND e.`year` BETWEEN 2006 AND 2018
);
/*
 Add tables to primary_final_table
*/
CREATE OR REPLACE TABLE t_jan_cikryt_project_SQL_primary_final AS (
	SELECT *
	FROM t_payroll pr
	JOIN t_food_prices tfp 
		ON pr.Platy_rok = tfp.Pot_rok_z
	JOIN  t_gdp_cze tgc 
		ON pr.Platy_rok = tgc.HDP_rok 
);
/*
 * Create secondary_final table
 */
CREATE OR REPLACE TABLE t_jan_cikryt_project_SQL_secondary_final AS (
	SELECT 
		e.country AS Stát,
		e.`year` AS Rok,
		e.GDP AS HDP,
		e.gini AS GINI,
		e.population AS Populace
	FROM countries c
	JOIN economies e 
		ON c.country = e.country 
	WHERE c.continent = 'Europe'
		AND e.country != 'Czech Republic'
		AND e.`year` BETWEEN 2006 AND 2018
	ORDER BY e.country, e.`year`
);
/*
 * Answer to Q1
 */
SELECT 
	pt.Platy_rok ,
	pt.Profesni_odvetvi ,
	pt.Prumerny_plat 
FROM t_jan_cikryt_project_sql_primary_final pt 
GROUP BY pt.Platy_rok, pt.Profesni_odvetvi 
ORDER BY pt.Profesni_odvetvi, pt.Platy_rok  
;
/*
 * Answer to Q2
 */
SELECT
	pt.Platy_rok,
	pt.Profesni_odvetvi,
	pt.Prumerny_plat,
	pt.Kategorie_potravin,
	pt.Cena,
	pt.Mnozstvi_potraviny,
	pt.Jednotka,
	pt.Pot_rok_z AS Pot_rok,
	round(Prumerny_plat/Cena) AS Dostupne_mnozstvi 
FROM t_jan_cikryt_project_sql_primary_final pt
WHERE Kategorie_potravin IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
	AND Pot_rok_z IN (2006, 2018)
GROUP BY pt.Pot_rok_z, pt.Profesni_odvetvi, pt.Kategorie_potravin
ORDER BY pt.Profesni_odvetvi, pt.Kategorie_potravin, pt.Pot_rok_z
;
/*
 * Answer to Q3
 */

/*
 * Answer to Q4
 */

/*
 * Answer to Q5
 */
SELECT 
	pt.Platy_rok,
	pt.Profesni_odvetvi,
	pt.Prumerny_plat,
	pt.Kategorie_potravin,
	pt.Cena,
	pt.Mnozstvi_potraviny,
	pt.Jednotka,
	pt.HDP
FROM t_jan_cikryt_project_sql_primary_final pt
GROUP BY Profesni_odvetvi, Kategorie_potravin, HDP_rok 
;
