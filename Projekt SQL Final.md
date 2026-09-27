# Projekt z SQL — Dostupnost základních potravin v ČR

Autor: Adam Hrazdera

## Úvod

Cílem projektu je posoudit dostupnost základních potravin široké veřejnosti na základě průměrných mezd a cen potravin v České republice, a doplnit tento pohled o srovnání s HDP, GINI koeficientem a populací ostatních evropských států.

## Zdrojová data

**Primární tabulky (ČR):**
- `czechia_payroll` — mzdy podle odvětví, čtvrtletně, 2000–2021 (+ číselníky `czechia_payroll_calculation`, `czechia_payroll_industry_branch`, `czechia_payroll_unit`, `czechia_payroll_value_type`)
- `czechia_price` — ceny vybraných potravin podle kraje, 2006–2018 (+ číselník `czechia_price_category`)
- `czechia_region`, `czechia_district` — číselníky krajů/okresů

**Dodatečné tabulky (Evropa):**
- `countries` — informace o zemích světa (název, kontinent atd.)
- `economies` — HDP, GINI koeficient, populace podle země a roku

## Klíčová rozhodnutí a jejich zdůvodnění

1. **Společné srovnatelné období: 2006–2018** — `czechia_price` má data jen od 2006, `czechia_payroll` do 2021, ale primární tabulka pokrývá jen průnik obou.
2. **Filtr mezd:** `value_type_code = 5958` (Průměrná hrubá mzda na zaměstnance), `unit_code = 200` (Kč), `calculation_code = 200` (přepočtený — standardní metodika ČSÚ pro přepočet na plné úvazky).
3. **Chybí "celkem" agregace:** `czechia_region` obsahuje jen 14 jednotlivých krajů a `czechia_payroll_industry_branch` jen 19 jednotlivých odvětví — žádná z tabulek nemá řádek "celá ČR/všechna odvětví". Národní úroveň jsme proto dopočítali jako **prostý průměr** přes kraje (ceny), resp. přes odvětví a kvartály (mzdy). Jde o zjednodušení — přesnější by byl vážený průměr (např. podle počtu zaměstnanců v odvětví), to ale přesahuje rozsah tohoto projektu.
4. **Struktura `primary_final` tabulky — "široký" formát:** jeden řádek = jeden rok (2006–2018), s průměrnou mzdou a 27 sloupci cen (jeden na kategorii potravin). Zvoleno pro jednoduchost a přehlednost oproti normalizovanému/dlouhému formátu. Důsledek: otázka 1 (mzdy po odvětvích) se řeší dotazem přímo na zdrojovou tabulku `czechia_payroll`, ne na `primary_final`.
5. **`secondary_final` tabulka** obsahuje HDP/GINI/populaci pro evropské státy **kromě ČR** (ta je pokrytá primární tabulkou), roky 2006–2018.
6. **Nebyla upravována žádná primární zdrojová data** — veškeré transformace (agregace, pivotování) proběhly výhradně při tvorbě `_final` tabulek nebo v dotazech nad nimi.

## Chybějící a problematická data

- **Víno (`cena_vino`)** — v `czechia_price` chybí záznamy pro roky 2006–2014, hodnoty jsou dostupné až od roku 2015. Otázky srovnávající celé období (např. otázka 3) proto vino vylučují.
- **GINI koeficient** v tabulce `economies` má velké množství chybějících hodnot u řady zemí a let.
- **`calculation_code`** u mezd nabízí dvě metodiky (fyzický/přepočtený) — zvolili jsme přepočtený jako standardní ČSÚ přístup, ale nešlo to ověřit s jistotou bez dalšího kontextu.

## Vytvořené tabulky

```sql
CREATE TABLE t_adam_hrazdera_project_sql_primary_final AS
SELECT 
    m.payroll_year AS rok,
    m.prumerna_mzda,
    c.cena_ryze, c.cena_mouka, c.cena_chleba, c.cena_pecivo, c.cena_testoviny,
    c.cena_hovezi, c.cena_vepreova, c.cena_kureci, c.cena_salam,
    c.cena_mleko, c.cena_jogurt, c.cena_syr, c.cena_vejce, c.cena_maslo, c.cena_tuk,
    c.cena_pomerance, c.cena_banany, c.cena_jablka,
    c.cena_rajcata, c.cena_papriky, c.cena_mrkev, c.cena_brambory,
    c.cena_cukr, c.cena_voda, c.cena_vino, c.cena_pivo, c.cena_kapr
FROM (
    SELECT payroll_year, AVG(value) AS prumerna_mzda
    FROM czechia_payroll
    WHERE value_type_code = 5958 AND unit_code = 200 AND calculation_code = 200
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

```sql
CREATE TABLE t_adam_hrazdera_project_sql_secondary_final AS
SELECT e.country, e.year, e.gdp, e.gini, e.population
FROM economies e
JOIN countries c ON e.country = c.country
WHERE c.continent = 'Europe'
  AND e.year BETWEEN 2006 AND 2018
  AND e.country <> 'Czech Republic'
ORDER BY e.country, e.year;
```

## Výzkumné otázky a odpovědi

### 1. Rostou mzdy ve všech odvětvích, nebo v některých klesají?

```sql
SELECT 
    cpib.name AS odvetvi,
    AVG(CASE WHEN cp.payroll_year = 2006 AND cp.value_type_code = 5958 THEN cp.value END) AS mzda_2006,
    AVG(CASE WHEN cp.payroll_year = 2018 AND cp.value_type_code = 5958 THEN cp.value END) AS mzda_2018
FROM czechia_payroll cp
JOIN czechia_payroll_industry_branch cpib ON cp.industry_branch_code = cpib.code
WHERE cp.unit_code = 200 AND cp.calculation_code = 200
  AND cp.payroll_year IN (2006, 2018)
GROUP BY cpib.name
ORDER BY cpib.name;
```

**Odpověď:** Mzdy vzrostly ve **všech 19 sledovaných odvětvích** mezi lety 2006 a 2018, žádné odvětví nezaznamenalo pokles. Nejvýraznější růst zaznamenaly Informační a komunikační činnosti (35 793 → 56 728 Kč), nejmenší absolutní přírůstek Ubytování, stravování a pohostinství (11 674 → 19 270 Kč).

### 2. Kolik litrů mléka a kilogramů chleba lze koupit za mzdu na začátku a na konci období?

```sql
SELECT
    rok,
    prumerna_mzda / cena_chleba AS kg_chleba,
    prumerna_mzda / cena_mleko AS litry_mleka
FROM t_adam_hrazdera_project_sql_primary_final
WHERE rok IN (2006, 2018)
ORDER BY rok;
```

**Odpověď:** Dostupnost obou potravin se zlepšila:
- Chléb: 1 307,6 kg (2006) → 1 363,1 kg (2018)
- Mléko: 1 460,3 l (2006) → 1 667,2 l (2018)

Mzdy tedy rostly rychleji než ceny těchto dvou základních potravin.

### 3. Která kategorie potravin zdražuje nejpomaleji?

```sql
WITH ceny AS (
    SELECT 'chleba' AS kategorie,
           (SELECT cena_chleba FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006) AS cena_2006,
           (SELECT cena_chleba FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018) AS cena_2018
    UNION ALL
    -- ... (analogicky pro všech 27 kategorií)
    SELECT 'kapr',
           (SELECT cena_kapr FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2006),
           (SELECT cena_kapr FROM t_adam_hrazdera_project_sql_primary_final WHERE rok = 2018)
)
SELECT 
    kategorie, cena_2006, cena_2018,
    ROUND(CAST(((cena_2018 - cena_2006) / cena_2006) * 100 AS numeric), 2) AS procento_narustu
FROM ceny
ORDER BY procento_narustu ASC;
```

**Odpověď:** Nejnižší (resp. záporný) nárůst mají **cukr** (-27,51 %) a **rajčata** (-23,07 %) — obě kategorie ve skutečnosti zlevnily. Mezi kategoriemi, jejichž cena skutečně rostla, zdražovaly nejpomaleji **banány** (+7,39 %). Poznámka k metodice: srovnání je založeno na krajních letech (2006 vs. 2018), nikoli na skutečném meziročním trendu za celé období. Kategorie víno byla vyloučena kvůli chybějícím datům z roku 2006.

### 4. Existuje rok, kde byl meziroční nárůst cen výrazně vyšší (>10 p. b.) než růst mezd?

```sql
WITH ceny_dlouhe AS (
    SELECT rok, 'chleba' AS kategorie, cena_chleba AS cena FROM t_adam_hrazdera_project_sql_primary_final
    UNION ALL
    -- ... (analogicky pro všech 27 kategorií)
    SELECT rok, 'kapr', cena_kapr FROM t_adam_hrazdera_project_sql_primary_final
),
rust_cen AS (
    SELECT rok,
        (cena - LAG(cena) OVER (PARTITION BY kategorie ORDER BY rok))
            / LAG(cena) OVER (PARTITION BY kategorie ORDER BY rok) * 100 AS rust_procento
    FROM ceny_dlouhe
),
rust_cen_rocni AS (
    SELECT rok, ROUND(CAST(AVG(rust_procento) AS numeric), 2) AS rust_cen
    FROM rust_cen GROUP BY rok
),
rust_mzda AS (
    SELECT rok,
        ROUND(CAST((prumerna_mzda - LAG(prumerna_mzda) OVER (ORDER BY rok))
            / LAG(prumerna_mzda) OVER (ORDER BY rok) * 100 AS numeric), 2) AS rust_mzdy
    FROM t_adam_hrazdera_project_sql_primary_final
)
SELECT m.rok, m.rust_mzdy, c.rust_cen, c.rust_cen - m.rust_mzdy AS rozdil_procentnich_bodu
FROM rust_mzda m
JOIN rust_cen_rocni c ON m.rok = c.rok
WHERE m.rok > 2006
ORDER BY m.rok;
```

**Odpověď:** Žádný rok nepřekročil hranici 10 procentních bodů. Nejblíže byl rok **2013** (rozdíl 7,5 p. b. — mzdy klesly o 1,49 %, ceny rostly o 6,01 %). Opačným směrem se přiblížil rok **2009** (rozdíl -9,67 p. b. — ceny prudce klesly o 6,58 % vlivem krize, mzdy dál rostly o 3,09 %). Metodika: "růst cen" je prostý průměr meziročního růstu přes všech 27 kategorií potravin.

### 5. Má výška HDP vliv na změny ve mzdách a cenách potravin?

```sql
SELECT 
    year, gdp,
    LAG(gdp) OVER (ORDER BY year) AS gdp_predchozi_rok,
    ROUND(CAST((gdp - LAG(gdp) OVER (ORDER BY year))
        / LAG(gdp) OVER (ORDER BY year) * 100 AS numeric), 2) AS rust_hdp_procent
FROM economies
WHERE country = 'Czech Republic' AND year BETWEEN 2006 AND 2018
ORDER BY year;
```

**Odpověď:** Mezi růstem HDP a růstem mezd existuje **mírná souvislost** — patrná zejména kolem krize v roce 2009 (propad HDP -4,66 % doprovázen zpomalením růstu mezd na 3,09 %) a v roce 2017 (vysoký růst HDP 5,17 % i mezd 6,19 %) — souvislost ale není konzistentní ve všech letech. Mezi HDP a cenami potravin **jasná souvislost patrná není** — např. v letech 2012–2013 HDP stagnovalo, zatímco ceny potravin výrazně rostly, což naznačuje, že ceny potravin ovlivňují spíš jiné faktory (světové ceny komodit, neúroda, dovozní náklady) než domácí HDP.

## Shrnutí

Dostupnost základních potravin (chléb, mléko) se v ČR mezi lety 2006 a 2018 zlepšila díky tomu, že mzdy rostly rychleji než jejich ceny. Mzdy rostly ve všech sledovaných odvětvích bez výjimky. Vztah mezi HDP a mzdami je patrný, ale ne silný a konzistentní; vztah mezi HDP a cenami potravin nebyl prokázán.
