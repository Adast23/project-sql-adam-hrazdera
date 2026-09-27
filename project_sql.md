# Projekt z SQL — kompletní SQL skript

Autor: Adam Hrazdera

> Pozn.: primární zdrojové tabulky (`czechia_*`, `countries`, `economies`) nejsou nikde upravovány, pouze čteny.

## 1) Vytvoření tabulky `t_adam_hrazdera_project_sql_primary_final`

Mzdy + ceny potravin za ČR, roky 2006–2018.

```sql
CREATE TABLE t_adam_hrazdera_project_sql_primary_final AS
SELECT 
    m.payroll_year AS rok,
    m.prumerna_mzda,
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
    c.cena_kapr
FROM (
    SELECT 
        payroll_year,
        AVG(value) AS prumerna_mzda
    FROM czechia_payroll
    WHERE value_type_code = 5958   -- průměrná hrubá mzda na zaměstnance
      AND unit_code = 200          -- Kč
      AND calculation_code = 200   -- přepočtený (FTE)
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
) c ON m.payroll_year = c.rok
ORDER BY rok;
```

## 2) Vytvoření tabulky `t_adam_hrazdera_project_sql_secondary_final`

HDP, GINI, populace ostatních evropských států, 2006–2018.

```sql
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
```

## Otázka 1: Rostou mzdy ve všech odvětvích, nebo v některých klesají?

Řeší se dotazem přímo na zdrojovou `czechia_payroll`, protože `primary_final` agreguje mzdy přes všechna odvětví dohromady.

```sql
SELECT 
    cpib.name AS odvetvi,
    AVG(CASE WHEN cp.payroll_year = 2006 AND cp.value_type_code = 5958 THEN cp.value END) AS mzda_2006,
    AVG(CASE WHEN cp.payroll_year = 2018 AND cp.value_type_code = 5958 THEN cp.value END) AS mzda_2018
FROM czechia_payroll cp
JOIN czechia_payroll_industry_branch cpib ON cp.industry_branch_code = cpib.code
WHERE cp.unit_code = 200
  AND cp.calculation_code = 200
  AND cp.payroll_year IN (2006, 2018)
GROUP BY cpib.name
ORDER BY cpib.name;
```

**Odpověď:** mzdy vzrostly ve všech 19 odvětvích, žádné nezaznamenalo pokles.

## Otázka 2: Kolik litrů mléka a kg chleba lze koupit za mzdu na začátku a na konci srovnatelného období?

```sql
SELECT
    rok,
    prumerna_mzda,
    prumerna_mzda / cena_chleba AS kg_chleba,
    prumerna_mzda / cena_mleko AS litry_mleka
FROM t_adam_hrazdera_project_sql_primary_final
WHERE rok IN (2006, 2018)
ORDER BY rok;
```

**Odpověď:** chléb 1307,6 kg (2006) → 1363,1 kg (2018); mléko 1460,3 l (2006) → 1667,2 l (2018). Dostupnost obou potravin se zlepšila.

## Otázka 3: Která kategorie potravin zdražuje nejpomaleji?

```sql
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
```

**Odpověď:** cukr (-27,51 %) a rajčata (-23,07 %) ve skutečnosti zlevnily. Mezi rostoucími kategoriemi zdražovaly nejpomaleji banány (+7,39 %). Kategorie víno nemá data za rok 2006, proto je bez výsledku.

## Otázka 4: Existuje rok, kde byl meziroční nárůst cen výrazně vyšší (>10 procentních bodů) než růst mezd?

```sql
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
        kategorie,
        cena,
        LAG(cena) OVER (PARTITION BY kategorie ORDER BY rok) AS cena_predchozi,
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
```

**Odpověď:** žádný rok nepřekročil hranici 10 procentních bodů. Nejblíže byl rok 2013 (+7,5 p. b. — mzdy klesly o 1,49 %, ceny rostly o 6,01 %) a rok 2009 opačným směrem (-9,67 p. b.).

## Otázka 5: Má výška HDP vliv na změny ve mzdách a cenách potravin?

HDP ČR čerpáno přímo z `economies`, protože `secondary_final` ČR záměrně vylučuje.

```sql
SELECT 
    year,
    gdp,
    LAG(gdp) OVER (ORDER BY year) AS gdp_predchozi_rok,
    ROUND(
        CAST(
            (gdp - LAG(gdp) OVER (ORDER BY year)) 
            / LAG(gdp) OVER (ORDER BY year) * 100 
        AS numeric), 2
    ) AS rust_hdp_procent
FROM economies
WHERE country = 'Czech Republic'
  AND year BETWEEN 2006 AND 2018
ORDER BY year;
```

**Odpověď:** mírná souvislost mezi HDP a mzdami (patrná zejména kolem krize 2009 a růstu 2017), ale nekonzistentní ve všech letech. Mezi HDP a cenami potravin jasná souvislost patrná není (např. 2012–2013 HDP stagnovalo, ceny potravin přesto rostly).
