CREATE TABLE t_hana_plucnarova_project_SQL_primary_final
SELECT
value AS value_payroll,
value_type_code,
industry_branch_code,
payroll_year,
calculation_code
FROM czechia_payroll cp 
JOIN czechia_payroll_calculation cpc
    ON cp.calculation_code = cpc.code
JOIN czechia_payroll_industry_branch cpib
    ON cp.industry_branch_code = cpib.code 
JOIN czechia_payroll_unit cpu
    ON cp.unit_code = cpu.code
JOIN czechia_payroll_value_type cpv
	ON cp.value_type_code = cpv.code
;


SELECT *
FROM t_hana_plucnarova_project_sql_primary_final
;


-- Otázka č.1 
-- Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?

-- Odpověď:
-- Z tabulky je zřejmé, že do roku 2008 mzdy rostly ve všech odvětvích.
-- Stejně tomu tak bylo i v letech2012, 2014, 2016 a 2019.
-- V ostatních letech v některých odvětvích mzdy rostly, v jiných však nikoliv.
-- Dle dat neexistuje rok, ve kterém by mzdy klesly ve všech odvětvích.


SELECT 
	thppspf.industry_branch_code,
	cpibh.name,
	round((thppspf.value_payroll  - thppspf2.value_payroll)/thppspf2.value_payroll  * 100, 2) AS value_growth,
	thppspf.payroll_year AS YEAR,
	thppspf2.payroll_year +1 AS YEAR_PREVIOUS,
	thppspf.value_type_code
FROM t_hana_plucnarova_project_sql_primary_final thppspf
JOIN czechia_payroll_industry_branch_hana cpibh 
	ON thppspf.industry_branch_code = cpibh.code 
JOIN t_hana_plucnarova_project_sql_primary_final thppspf2 
	ON thppspf.industry_branch_code = thppspf2.industry_branch_code 
	AND thppspf.payroll_year = thppspf2.payroll_year + 1
	AND thppspf.value_type_code = thppspf2.value_type_code
	WHERE thppspf.value_type_code = '5958'
	GROUP BY thppspf.industry_branch_code, thppspf.payroll_year
	ORDER BY thppspf.payroll_year, thppspf.industry_branch_code
;


-- Otázka č.2
-- Kolik je možné si koupit litrů mléka a kilogramů chleba za první a poslední srovnatelné období v dostupných datech cen a mezd?

-- Odpověď:
-- Dle dostupných dat a srovnatelného období bylo možné si koupit 740 ks chleba a 893 l mléka v roce 2006 a 859 ks chleba a 1.090 l mléka v roce 20018.


SELECT 
thppspf.payroll_year,
thppspf.value_type_code,
round(AVG(thppspf.value_payroll),2),
cph.category_code,
cpch.name,
cph.value,
round(thppspf.value_payroll/ cph.value) AS Bought_quantity_for_sallary
FROM t_hana_plucnarova_project_sql_primary_final thppspf 
JOIN czechia_price_hana cph 
	ON thppspf.payroll_year = YEAR(cph.date_from)
JOIN czechia_price_category_hana cpch 
	ON cph.category_code = cpch.code
WHERE thppspf.value_type_code = '5958'
and cph.category_code IN ('114201', '111301')
AND YEAR(cph.date_from) IN ('2006', '2018')
GROUP BY thppspf.payroll_year, cph.category_code 
;


-- Otázka č.3

CREATE TABLE t_czechia_price_plucnar_hana_one
SELECT
AVG(value),
category_code,
date_format(date_from, '%Y') AS DATE,
cpc.name
FROM czechia_price cp 
JOIN czechia_price_category cpc 
	ON cp.category_code = cpc.code
GROUP BY cp.category_code, date_format(date_from, '%Y')
;


SELECT *
FROM t_czechia_price_plucnar_hana_one tcppho 
;


-- Otázka č.3
-- Která kateogorie potravin zdražuje nejpomaleji (je u ní nejnižší procentuální meziroční růst)?

-- Odpověď:
-- Nelze jednoznačně říct, která kategorie potravin zdražuje meziročně nejméně. 
-- Dle analyzovaných dat dochází k nejnižšímu meziročnímu nárůstu cen zejména u kategorie potravin ovoce a zeleniny.


SELECT 
tcppho.category_code,
tcppho.name,
tcppho.`AVG(value)`, 
ROUND((tcppho.`AVG(value)`-tcppho2.`AVG(value)`)/tcppho2.`AVG(value)`* 100,2) AS value_growth_percent,
tcppho.`DATE`,
tcppho2.`DATE`+1 AS year_previous
FROM t_czechia_price_plucnar_hana_one tcppho
JOIN t_czechia_price_plucnar_hana_one tcppho2 
	ON tcppho.category_code = tcppho2.category_code 
	AND tcppho.`DATE` = tcppho2.`DATE`+1
	WHERE tcppho.`DATE`  >= '2006' AND tcppho.`DATE`  <= '2018'
	GROUP BY tcppho.`DATE`, tcppho.category_code
	ORDER BY tcppho.`DATE` ASC, ROUND((tcppho.`AVG(value)`-tcppho2.`AVG(value)`)/tcppho2.`AVG(value)`* 100,2), tcppho.name
;


-- Otázka č.4
-- Existuje rok, ve kterém by meziroční nárůst potravin výrazně vyšší než růst mezd (větší než 10%)?

-- Odpověď:
-- Nejvyšší meziroční nárůst potravin byl v roce 2008, a to o 37%. Ke druhému nejvyššímu meziročnímu nárůstu potravin
-- došlo v roce 2007. V roce 2007 potraviny vzrostly meziročně o 12%.


SELECT 
ROUND((tcppho.`AVG(value)`-tcppho2.`AVG(value)`)/tcppho2.`AVG(value)`* 100,2) AS value_growth_percent,
tcppho.`DATE`,
tcppho2.`DATE`+ 1 AS year_previous
FROM t_czechia_price_plucnar_hana_one tcppho
JOIN t_czechia_price_plucnar_hana_one tcppho2 
	ON tcppho.category_code = tcppho2.category_code 
	AND tcppho.`DATE` = tcppho2.`DATE`+ 1
	WHERE tcppho.`DATE`  >= '2006' AND tcppho.`DATE`  <= '2018'
	GROUP BY tcppho.date
;



-- Otázka č.5

CREATE TABLE t_hana_plucnarova_project_sql_secondary_final
SELECT
e.country AS state,
e.YEAR,
e.GDP,
e.gini,
c.country AS country,
c.continent 
FROM economies e 
JOIN countries c 
	ON e.country = c.country
	WHERE c.continent = 'Europe'
	GROUP BY c.country, e.YEAR
	
	
-- Otázka č.5
-- Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vrzoste výrazněji v jednom roce, projeví se to na cenách
-- potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?	
	
-- Odpověď:
-- Ano, zejména data z let 2013 až 2018 potrvzují teorii, že růst HDP se projevuje výraznějším růstem mezd a potravin v následujícím roce. 
	
	
SELECT 
thppssf.state,
thppssf.`YEAR`,
round(thppssf.GDP) AS GDP,
thppssf.gini,
round(AVG(thppspf.value_payroll)) AS average_payroll,
round(tcppho.`AVG(value)`) AS average_food_price,
thppspf.value_type_code,
thppspf.payroll_year 
FROM t_hana_plucnarova_project_sql_secondary_final thppssf 
JOIN t_hana_plucnarova_project_sql_primary_final thppspf 
	ON thppssf.`YEAR` = thppspf.payroll_year
JOIN t_czechia_price_plucnar_hana_one tcppho 
	ON thppssf.`YEAR` = tcppho.`DATE` 
WHERE thppssf.state = 'Czech Republic'
AND thppspf.value_type_code = '5958'
GROUP BY thppssf.`YEAR` 
;

