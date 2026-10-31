-- ============================================================
-- Projekt z SQL — Dostupnost základních potravin v ČR
-- Autor: Adam Hrazdera
-- ============================================================
-- Pozn.: zdrojové tabulky (czechia_*, countries, economies) nejsou
-- nikde upravovány, pouze čteny. Všechny dotazy na výzkumné otázky
-- čtou výhradně z tabulek t_adam_hrazdera_project_sql_primary_final
-- a t_adam_hrazdera_project_sql_secondary_final.


-- ============================================================
-- 1) PRIMÁRNÍ TABULKA: mzdy (celkem i po odvětvích), ceny potravin a HDP ČR
--    Jeden řádek = jeden rok (2006-2018)
-- ============================================================

CREATE TABLE t_adam_hrazdera_project_sql_primary_final AS
SELECT 
    m.rok,
    m.prumerna_mzda,
    m.mzda_zemedelstvi,
    m.mzda_tezba,
    m.mzda_zpracovatelsky_prumysl,
    m.mzda_energetika,
    m.mzda_vodohospodarstvi,
    m.mzda_stavebnictvi,
    m.mzda_obchod,
    m.mzda_doprava,
    m.mzda_ubytovani_stravovani,
    m.mzda_ict,
    m.mzda_financnictvi,
    m.mzda_nemovitosti,
    m.mzda_profesni_cinnosti,
    m.mzda_administrativa,
    m.mzda_verejna_sprava,
    m.mzda_vzdelavani,
    m.mzda_zdravotnictvi,
    m.mzda_kultura,
    m.mzda_ostatni,
    c.cena_ryze,
    c.cena_mouka,
    c.cena_chleba,
    c.cena_pecivo,
    c.cena_testoviny,
    c.cena_hovezi,
    c.cena_vepreova,
    c.cena_kureci,
    c.cena_salam,
    c.cena_mleko,
    c.cena_jogurt,
    c.cena_syr,
    c.cena_vejce,
    c.cena_maslo,
    c.cena_tuk,
    c.cena_pomerance,
    c.cena_banany,
    c.cena_jablka,
    c.cena_rajcata,
    c.cena_papriky,
    c.cena_mrkev,
    c.cena_brambory,
    c.cena_cukr,
    c.cena_voda,
    c.cena_vino,
    c.cena_pivo,
    c.cena_kapr,
    e.hdp
FROM (
    SELECT 
        payroll_year AS rok,
        AVG(value) AS prumerna_mzda,
        AVG(CASE WHEN industry_branch_code = 'A' THEN value END) AS mzda_zemedelstvi,
        AVG(CASE WHEN industry_branch_code = 'B' THEN value END) AS mzda_tezba,
        AVG(CASE WHEN industry_branch_code = 'C' THEN value END) AS mzda_zpracovatelsky_prumysl,
        AVG(CASE WHEN industry_branch_code = 'D' THEN value END) AS mzda_energetika,
        AVG(CASE WHEN industry_branch_code = 'E' THEN value END) AS mzda_vodohospodarstvi,
        AVG(CASE WHEN industry_branch_code = 'F' THEN value END) AS mzda_stavebnictvi,
        AVG(CASE WHEN industry_branch_code = 'G' THEN value END) AS mzda_obchod,
        AVG(CASE WHEN industry_branch_code = 'H' THEN value END) AS mzda_doprava,
        AVG(CASE WHEN industry_branch_code = 'I' THEN value END) AS mzda_ubytovani_stravovani,
        AVG(CASE WHEN industry_branch_code = 'J' THEN value END) AS mzda_ict,
        AVG(CASE WHEN industry_branch_code = 'K' THEN value END) AS mzda_financnictvi,
        AVG(CASE WHEN industry_branch_code = 'L' THEN value END) AS mzda_nemovitosti,
        AVG(CASE WHEN industry_branch_code = 'M' THEN value END) AS mzda_profesni_cinnosti,
        AVG(CASE WHEN industry_branch_code = 'N' THEN value END) AS mzda_administrativa,
        AVG(CASE WHEN industry_branch_code = 'O' THEN value END) AS mzda_verejna_sprava,
        AVG(CASE WHEN industry_branch_code = 'P' THEN value END) AS mzda_vzdelavani,
        AVG(CASE WHEN industry_branch_code = 'Q' THEN value END) AS mzda_zdravotnictvi,
        AVG(CASE WHEN industry_branch_code = 'R' THEN value END) AS mzda_kultura,
        AVG(CASE WHEN industry_branch_code = 'S' THEN value END) AS mzda_ostatni
    FROM czechia_payroll
    WHERE value_type_code = 5958   -- průměrná hrubá mzda na zaměstnance
      AND unit_code = 200          -- Kč
      AND calculation_code = 200   -- přepočtený počet zaměstnanců
      AND payroll_year BETWEEN 2006 AND 2018
    GROUP BY payroll_year
) m
JOIN (
    SELECT 
        EXTRACT(YEAR FROM date_from) AS rok,
        AVG(CASE WHEN category_code = 111101 THEN value END) AS cena_ryze,
        AVG(CASE WHEN category_code = 111201 THEN value END) AS cena_mouka,
        AVG(CASE WHEN category_code = 111301 THEN value END) AS cena_chleba,
        AVG(CASE WHEN category_code = 111303 THEN value END) AS cena_pecivo,
        AVG(CASE WHEN category_code = 111602 THEN value END) AS cena_testoviny,
        AVG(CASE WHEN category_code = 112101 THEN value END) AS cena_hovezi,
        AVG(CASE WHEN category_code = 112201 THEN value END) AS cena_vepreova,
        AVG(CASE WHEN category_code = 112401 THEN value END) AS cena_kureci,
        AVG(CASE WHEN category_code = 112704 THEN value END) AS cena_salam,
        AVG(CASE WHEN category_code = 114201 THEN value END) AS cena_mleko,
        AVG(CASE WHEN category_code = 114401 THEN value END) AS cena_jogurt,
        AVG(CASE WHEN category_code = 114501 THEN value END) AS cena_syr,
        AVG(CASE WHEN category_code = 114701 THEN value END) AS cena_vejce,
        AVG(CASE WHEN category_code = 115101 THEN value END) AS cena_maslo,
        AVG(CASE WHEN category_code = 115201 THEN value END) AS cena_tuk,
        AVG(CASE WHEN category_code = 116101 THEN value END) AS cena_pomerance,
        AVG(CASE WHEN category_code = 116103 THEN value END) AS cena_banany,
        AVG(CASE WHEN category_code = 116104 THEN value END) AS cena_jablka,
        AVG(CASE WHEN category_code = 117101 THEN value END) AS cena_rajcata,
        AVG(CASE WHEN category_code = 117103 THEN value END) AS cena_papriky,
        AVG(CASE WHEN category_code = 117106 THEN value END) AS cena_mrkev,
        AVG(CASE WHEN category_code = 117401 THEN value END) AS cena_brambory,
        AVG(CASE WHEN category_code = 118101 THEN value END) AS cena_cukr,
        AVG(CASE WHEN category_code = 122102 THEN value END) AS cena_voda,
        AVG(CASE WHEN category_code = 212101 THEN value END) AS cena_vino,
        AVG(CASE WHEN category_code = 213201 THEN value END) AS cena_pivo,
        AVG(CASE WHEN category_code = 2000001 THEN value END) AS cena_kapr
    FROM czechia_price
    GROUP BY EXTRACT(YEAR FROM date_from)
) c ON m.rok = c.rok
JOIN (
    SELECT 
        year AS rok,
        gdp AS hdp
    FROM economies
    WHERE country = 'Czech Republic'
      AND year BETWEEN 2006 AND 2018
) e ON m.rok = e.rok
ORDER BY m.rok;


-- ============================================================
-- 2) SEKUNDÁRNÍ TABULKA: HDP, GINI a populace evropských států (bez ČR)
-- ============================================================

CREATE TABLE t_adam_hrazdera_project_sql_secondary_final AS
SELECT 
    e.country, 
    e.year, 
    e.gdp, 
    e.gini, 
    e.population
FROM economies e
JOIN countries c ON e.country = c.country
WHERE c.continent = 'Europe'
  AND e.year BETWEEN 2006 AND 2018
  AND e.country <> 'Czech Republic'
ORDER BY e.country, e.year;


-- ============================================================
-- OTÁZKA 1: Rostou mzdy ve všech odvětvích, nebo v některých klesají?
-- Výpis všech případů, kdy mzda v odvětví meziročně klesla.
-- ============================================================

WITH mzdy_dlouhe AS (
    SELECT rok, 'Zemědělství' AS odvetvi, mzda_zemedelstvi AS mzda FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'Těžba', mzda_tezba FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'Zpracovatelský průmysl', mzda_zpracovatelsky_prumysl FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'Energetika', mzda_energetika FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'Vodohospodářství', mzda_vodohospodarstvi FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'Stavebnictví', mzda_stavebnictvi FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'Obchod', mzda_obchod FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'Doprava', mzda_doprava FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'Ubytování a stravování', mzda_ubytovani_stravovani FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'ICT', mzda_ict FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'Peněžnictví', mzda_financnictvi FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'Nemovitosti', mzda_nemovitosti FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'Profesní činnosti', mzda_profesni_cinnosti FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'Administrativa', mzda_administrativa FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'Veřejná správa', mzda_verejna_sprava FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'Vzdělávání', mzda_vzdelavani FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'Zdravotnictví', mzda_zdravotnictvi FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'Kultura', mzda_kultura FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'Ostatní', mzda_ostatni FROM t_adam_hrazdera_project_sql_primary_final
),
zmeny AS (
    SELECT
        rok,
        odvetvi,
        mzda,
        LAG(mzda) OVER (PARTITION BY odvetvi ORDER BY rok) AS mzda_predchozi_rok
    FROM mzdy_dlouhe
)
SELECT
    odvetvi,
    rok,
    mzda_predchozi_rok,
    mzda,
    ROUND(CAST((mzda - mzda_predchozi_rok) / mzda_predchozi_rok * 100 AS numeric), 2) AS zmena_procent
FROM zmeny
WHERE mzda < mzda_predchozi_rok
ORDER BY odvetvi, rok;

-- Odpověď: 25 meziročních poklesů v 16 z 19 odvětví; nejvíce v roce 2013
--          (11 odvětví). Bez poklesu zůstaly jen zpracovatelský průmysl,
--          zdravotnictví a ostatní činnosti.


-- ============================================================
-- OTÁZKA 2: Kolik litrů mléka a kg chleba lze koupit za mzdu
--           v prvním a posledním srovnatelném období?
-- ============================================================

SELECT
    rok,
    prumerna_mzda,
    prumerna_mzda / cena_chleba AS kg_chleba,
    prumerna_mzda / cena_mleko AS litry_mleka
FROM t_adam_hrazdera_project_sql_primary_final
WHERE rok IN (2006, 2018)
ORDER BY rok;


-- ============================================================
-- OTÁZKA 3: Která kategorie potravin zdražuje nejpomaleji?
-- ============================================================

WITH ceny AS (
    SELECT 'ryze' AS kategorie,
           (SELECT cena_ryze FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006) AS cena_2006,
           (SELECT cena_ryze FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018) AS cena_2018
    UNION ALL
    SELECT 'mouka',
           (SELECT cena_mouka FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_mouka FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'chleba',
           (SELECT cena_chleba FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_chleba FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'pecivo',
           (SELECT cena_pecivo FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_pecivo FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'testoviny',
           (SELECT cena_testoviny FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_testoviny FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'hovezi',
           (SELECT cena_hovezi FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_hovezi FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'vepreova',
           (SELECT cena_vepreova FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_vepreova FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'kureci',
           (SELECT cena_kureci FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_kureci FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'salam',
           (SELECT cena_salam FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_salam FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'mleko',
           (SELECT cena_mleko FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_mleko FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'jogurt',
           (SELECT cena_jogurt FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_jogurt FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'syr',
           (SELECT cena_syr FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_syr FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'vejce',
           (SELECT cena_vejce FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_vejce FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'maslo',
           (SELECT cena_maslo FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_maslo FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'tuk',
           (SELECT cena_tuk FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_tuk FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'pomerance',
           (SELECT cena_pomerance FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_pomerance FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'banany',
           (SELECT cena_banany FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_banany FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'jablka',
           (SELECT cena_jablka FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_jablka FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'rajcata',
           (SELECT cena_rajcata FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_rajcata FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'papriky',
           (SELECT cena_papriky FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_papriky FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'mrkev',
           (SELECT cena_mrkev FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_mrkev FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'brambory',
           (SELECT cena_brambory FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_brambory FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'cukr',
           (SELECT cena_cukr FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_cukr FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'voda',
           (SELECT cena_voda FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_voda FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'vino',
           (SELECT cena_vino FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_vino FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'pivo',
           (SELECT cena_pivo FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_pivo FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
    UNION ALL
    SELECT 'kapr',
           (SELECT cena_kapr FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_kapr FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
)
SELECT 
    kategorie,
    cena_2006,
    cena_2018,
    ROUND(CAST(((cena_2018 - cena_2006) / cena_2006) * 100 AS numeric), 2) AS procento_narustu
FROM ceny
ORDER BY procento_narustu ASC;


-- ============================================================
-- OTÁZKA 4: Existuje rok, kdy byl meziroční nárůst cen potravin
--           výrazně vyšší než růst mezd (o více než 10 p. b.)?
-- ============================================================

WITH ceny_dlouhe AS (
    SELECT rok, 'ryze' AS kategorie, cena_ryze AS cena FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'mouka', cena_mouka FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'chleba', cena_chleba FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'pecivo', cena_pecivo FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'testoviny', cena_testoviny FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'hovezi', cena_hovezi FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'vepreova', cena_vepreova FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'kureci', cena_kureci FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'salam', cena_salam FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'mleko', cena_mleko FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'jogurt', cena_jogurt FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'syr', cena_syr FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'vejce', cena_vejce FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'maslo', cena_maslo FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'tuk', cena_tuk FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'pomerance', cena_pomerance FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'banany', cena_banany FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'jablka', cena_jablka FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'rajcata', cena_rajcata FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'papriky', cena_papriky FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'mrkev', cena_mrkev FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'brambory', cena_brambory FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'cukr', cena_cukr FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'voda', cena_voda FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'vino', cena_vino FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'pivo', cena_pivo FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    SELECT rok, 'kapr', cena_kapr FROM t_adam_hrazdera_project_sql_primary_final
),
rust_cen AS (
    SELECT
        rok,
        (cena - LAG(cena) OVER (PARTITION BY kategorie ORDER BY rok))
            / LAG(cena) OVER (PARTITION BY kategorie ORDER BY rok) * 100 AS rust_procento
    FROM ceny_dlouhe
),
rust_cen_rocni AS (
    SELECT rok, ROUND(CAST(AVG(rust_procento) AS numeric), 2) AS rust_cen
    FROM rust_cen
    GROUP BY rok
),
rust_mzda AS (
    SELECT 
        rok,
        ROUND(
            CAST(
                (prumerna_mzda - LAG(prumerna_mzda) OVER (ORDER BY rok)) 
                / LAG(prumerna_mzda) OVER (ORDER BY rok) * 100 
            AS numeric), 2
        ) AS rust_mzdy
    FROM t_adam_hrazdera_project_sql_primary_final
)
SELECT 
    m.rok,
    m.rust_mzdy,
    c.rust_cen,
    c.rust_cen - m.rust_mzdy AS rozdil_procentnich_bodu
FROM rust_mzda m
JOIN rust_cen_rocni c ON m.rok = c.rok
WHERE m.rok > 2006
ORDER BY m.rok;


-- ============================================================
-- OTÁZKA 5: Má výška HDP vliv na změny ve mzdách a cenách potravin?
-- Meziroční růst HDP a mezd; růst cen potravin viz dotaz k otázce 4.
-- ============================================================

SELECT 
    rok,
    ROUND(CAST((hdp - LAG(hdp) OVER (ORDER BY rok)) 
        / LAG(hdp) OVER (ORDER BY rok) * 100 AS numeric), 2) AS rust_hdp_procent,
    ROUND(CAST((prumerna_mzda - LAG(prumerna_mzda) OVER (ORDER BY rok)) 
        / LAG(prumerna_mzda) OVER (ORDER BY rok) * 100 AS numeric), 2) AS rust_mzdy_procent
FROM t_adam_hrazdera_project_sql_primary_final
ORDER BY rok;
