/*
 * First table
 */
CREATE TABLE IF NOT EXISTS t_payroll AS (
	SELECT cp.payroll_year AS Platy_rok, 
		cpib.name AS Profesni_odvetvi, 
		round(avg(cp.value)) AS Prumerny_plat
	FROM czechia_payroll cp 
	JOIN czechia_payroll_industry_branch cpib 
		ON cp.industry_branch_code = cpib.code 
	WHERE cp.value IS NOT NULL
	GROUP BY cp.payroll_year, cpib.name
	ORDER BY cpib.code, cp.payroll_year 
);
/*
 * Second table
 */
CREATE TABLE IF NOT EXISTS t_food_prices AS (
	SELECT 
		cpc.name AS Kategorie_potravin, 
		cp.value AS Cena, 
		cpc.price_value AS Mnozstvi_potraviny, 
		cpc.price_unit AS Jednotka, 
		YEAR(cp.date_from) AS Potraviny_rok 
	FROM czechia_price cp 
	JOIN czechia_price_category cpc 
		ON cp.category_code = cpc.code 
	WHERE region_code IS NULL
	GROUP BY date_from, cpc.name 
	ORDER BY cp.category_code, date_from
);
/*
 Add tables to primary_final_table
*/
CREATE OR REPLACE TABLE t_jan_cikryt_project_SQL_primary_final AS (
	SELECT *
	FROM t_payroll pr
	JOIN t_food_prices tfp 
		ON pr.Platy_rok = tfp.Potraviny_rok 
);
