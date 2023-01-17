/*
 * First primary table
 */
CREATE OR REPLACE TABLE t_payroll AS (
	SELECT cp.payroll_year AS payroll_year, 
		cpib.name AS work_branch, 
		ROUND(AVG(cp.value)) AS average_payroll,
		value_type_code,
		industry_branch_code
	FROM czechia_payroll cp 
	JOIN czechia_payroll_industry_branch cpib 
		ON cp.industry_branch_code = cpib.code 
	WHERE cp.value IS NOT NULL AND value_type_code = 5958
		AND cp.payroll_year BETWEEN 2006 AND 2018
	GROUP BY cp.payroll_year, cpib.name
	ORDER BY cpib.code, cp.payroll_year 
);
/*
 * Second primary table
 */
CREATE OR REPLACE TABLE t_food_prices AS (
	SELECT 
		cpc.name AS food_category, 
		ROUND(AVG(cp.value),1) AS average_price, 
		cpc.price_value AS amount_of_food, 
		cpc.price_unit AS price_unit, 
		YEAR(cp.date_from) AS food_year,
		cp.category_code
	FROM czechia_price cp 
	JOIN czechia_price_category cpc 
		ON cp.category_code = cpc.code 
	WHERE cp.region_code IS NULL
	GROUP BY YEAR(cp.date_from), cpc.name 
	ORDER BY cp.category_code, cp.date_from
);
/*
 * Third primary table
 */
CREATE OR REPLACE TABLE t_gdp_cze AS (
	SELECT e.GDP AS GDP,
		e.`year` AS GDP_year
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
		ON pr.payroll_year = tfp.food_year
	JOIN  t_gdp_cze tgc 
		ON pr.payroll_year = tgc.GDP_year 
);
/*
 * Create secondary_final table
 */
CREATE OR REPLACE TABLE t_jan_cikryt_project_SQL_secondary_final AS (
	SELECT 
		e.country AS country,
		e.`year` AS GDP_year,
		e.GDP AS GDP,
		e.gini AS GINI,
		e.population AS population
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
CREATE OR REPLACE VIEW v_answer_one AS (
	SELECT
		pt.payroll_year,
		pt.industry_branch_code,
		pt.work_branch,
		pt.average_payroll,
		LEAD(pt.average_payroll,1) OVER (PARTITION BY pt.work_branch ORDER BY pt.work_branch, pt.payroll_year) AS payroll_diff
	FROM t_jan_cikryt_project_sql_primary_final pt 
	GROUP BY pt.payroll_year, pt.work_branch 
	ORDER BY pt.work_branch, pt.payroll_year  
);
SELECT 
	pt.payroll_year,
	pt.industry_branch_code,
	pt.work_branch,
	pt.average_payroll,
	vao.payroll_diff,
	CASE 
		WHEN vao.payroll_diff > pt.average_payroll THEN	'stoupá'
		ELSE 'klesá'
	END AS rise_fall
FROM t_jan_cikryt_project_sql_primary_final pt 
JOIN v_answer_one vao
	ON	pt.industry_branch_code = vao.industry_branch_code
	AND pt.payroll_year = vao.payroll_year 
GROUP BY pt.payroll_year, pt.work_branch
ORDER BY pt.work_branch, pt.payroll_year  
;
/*
 * Answer to Q2
 */
SELECT
	pt.payroll_year,
	pt.average_payroll,
	pt.food_year,
	pt.food_category,
	pt.average_price,
	pt.amount_of_food,
	pt.price_unit,
	ROUND(AVG(average_payroll)/AVG(average_price)) AS available_quantity 
FROM t_jan_cikryt_project_sql_primary_final pt
WHERE food_category IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
	AND food_year IN (2006, 2018)
GROUP BY food_category, payroll_year
;
/*
 * Answer to Q3
 */
-- Table with LEAD function
CREATE OR REPLACE TABLE t_answer_three AS (
	SELECT 
		pt.food_year,
		pt.category_code,
		pt.food_category,
		pt.average_price,
		LEAD(pt.average_price,1) OVER (PARTITION BY pt.food_category ORDER BY pt.food_category, pt.food_year) AS price_diff
	FROM t_jan_cikryt_project_sql_primary_final pt
	GROUP BY pt.food_year, pt.food_category
	ORDER BY pt.food_category, pt.food_year 
);
-- VIEW contains calculation
CREATE OR REPLACE VIEW v_food_growth AS (
	SELECT 
		pt.food_year, 
		pt.category_code,
		pt.food_category,
		pt.average_price,
		tat.price_diff,
		ROUND(((tat.price_diff-pt.average_price)/pt.average_price)*100,2) AS percentage_yoy_growth
	FROM t_jan_cikryt_project_sql_primary_final pt
	JOIN t_answer_three tat 
		ON pt.category_code = tat.category_code
		AND pt.food_year = tat.food_year 
	GROUP BY pt.food_year, pt.food_category
	ORDER BY pt.food_category, pt.food_year
);
-- Final result
SELECT
	vfg.food_category,
	MIN(vfg.percentage_yoy_growth) AS minimum
FROM v_food_growth vfg
WHERE food_year != 2018
GROUP BY vfg.food_category 
ORDER BY minimum
;
/*
 * Answer to Q4
 */
-- TABLE with LEAD function
CREATE OR REPLACE TABLE t_answer_four AS (
	SELECT 
		pt.payroll_year,
		pt.industry_branch_code,
		pt.work_branch,
		pt.average_payroll,
		LEAD(pt.average_payroll,1) OVER (PARTITION BY pt.work_branch ORDER BY pt.work_branch, pt.payroll_year) AS payroll_diff
	FROM t_jan_cikryt_project_sql_primary_final pt 
	GROUP BY pt.payroll_year, pt.work_branch 
	ORDER BY pt.work_branch, pt.payroll_year  
);
-- VIEW contains calculation
CREATE OR REPLACE VIEW v_payroll_growth AS (
	SELECT 
		pt.payroll_year,
		pt.industry_branch_code,
		pt.work_branch,
		pt.average_payroll,
		taf.payroll_diff,
		ROUND(((taf.payroll_diff-pt.average_payroll)/pt.average_payroll)*100,2) AS percentage_yoy_payroll_growth
	FROM t_jan_cikryt_project_sql_primary_final pt
	JOIN t_answer_four taf  
		ON pt.industry_branch_code = taf.industry_branch_code
		AND pt.payroll_year = taf.payroll_year
	GROUP BY pt.payroll_year, pt.work_branch 
	ORDER BY pt.work_branch, pt.payroll_year
);
-- Final result
SELECT 
	vpg.payroll_year,
	vpg.work_branch,
	vpg.percentage_yoy_payroll_growth,
	vfg.food_category,
	vfg.percentage_yoy_growth,
	vfg.percentage_yoy_growth - vpg.percentage_yoy_payroll_growth AS diff
FROM v_payroll_growth vpg 
JOIN v_food_growth vfg 
	ON vpg.payroll_year = vfg.food_year 
WHERE vpg.payroll_year != 2018 AND vfg.food_year != 2018 AND vfg.percentage_yoy_growth - vpg.percentage_yoy_payroll_growth > 10
GROUP BY payroll_year
ORDER BY payroll_year, diff DESC 
;
/*
 * Answer to Q5
 */
SELECT 
	pt.payroll_year,
	pt.work_branch,
	pt.average_payroll,
	pt.food_category,
	pt.average_price,
	pt.amount_of_food,
	pt.price_unit,
	pt.GDP
FROM t_jan_cikryt_project_sql_primary_final pt
GROUP BY work_branch, food_category, GDP_year 
;
