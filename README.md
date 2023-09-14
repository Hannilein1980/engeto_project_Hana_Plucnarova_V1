# engeto_project_Hana_Plucnarova_V1

Projekt SQL_Hana Plucnarová

Zadáním projektu bylo vytvoření finální tabulky, která bude podkladem k zodpovězení výzkumných otázek týkajících se vývoje cen potravin a mezd v České republice, dostupnosti potravin na základě průměrných příjmů a vlivu HDP na vývoj cen potravin a mezd v České republice. 

Finální tabulku t_hana_plucnarova_project_SQL_primary_final jsem vytvořila sloučením následujících tabulek:

czechia_payroll cp 
czechia_payroll_calculation cpc
czechia_payroll_industry_branch cpib
czechia_payroll_unit cpu
czechia_payroll_value_type cpv

Tato tabuka byla podkladem pro zodpovězení prvních dvou otázek zadání projektu.

Podkladem pro zodpovězení otázek číslo 3 a 4 bylo vytvoření tabulky t_czechia_price_plucnar_hana_one, ve které jsem upravila formát roku, abych urychlila query.

Podklame pro zodpovězení otázky č. 5 bylo vytvoření druhé finální tabulky t_hana_plucnarova_project_sql_secondary_final obsahující data z tabulek economies a countries.

