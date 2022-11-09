/*
 * First table
 */
CREATE TABLE IF NOT EXISTS t_payroll AS (
	SELECT cp.payroll_year AS Rok, 
		cpib.name AS Profesni_odvetvi, 
		round(avg(cp.value)) AS Prumerny_plat
	FROM czechia_payroll cp 
	JOIN czechia_payroll_industry_branch cpib 
		ON cp.industry_branch_code = cpib.code 
	WHERE cp.value IS NOT NULL
	GROUP BY cp.payroll_year, cpib.name
	ORDER BY cpib.code, cp.payroll_year 
);
-- Add first table to primary_final_table
CREATE TABLE IF NOT EXISTS t_jan_cikryt_project_SQL_primary_final AS (
	SELECT *
	FROM t_payroll
);


