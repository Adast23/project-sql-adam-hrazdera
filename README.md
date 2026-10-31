# Projekt z SQL — Dostupnost základních potravin v ČR

Autor: Adam Hrazdera

Kompletní SQL skript (tvorba tabulek i dotazy na všechny výzkumné otázky) je v souboru [`project_sql.sql`](project_sql.sql).

## Úvod

Cílem projektu je posoudit dostupnost základních potravin široké veřejnosti na základě průměrných mezd a cen potravin v České republice a doplnit tento pohled o HDP, GINI koeficient a populaci ostatních evropských států.

## Zdrojová data

**Primární tabulky (ČR):**
- `czechia_payroll` — mzdy podle odvětví, čtvrtletně, 2000–2021 (+ číselníky `czechia_payroll_calculation`, `czechia_payroll_industry_branch`, `czechia_payroll_unit`, `czechia_payroll_value_type`)
- `czechia_price` — ceny vybraných potravin podle kraje, 2006–2018 (+ číselník `czechia_price_category`)
- `czechia_region`, `czechia_district` — číselníky krajů a okresů

**Dodatečné tabulky (Evropa):**
- `countries` — informace o zemích světa (název, kontinent atd.)
- `economies` — HDP, GINI koeficient, populace podle země a roku

## Výstupní tabulky

### `t_adam_hrazdera_project_sql_primary_final`

Jeden řádek = jeden rok (2006–2018), 49 sloupců:

| Skupina sloupců | Obsah |
|---|---|
| `rok` | rok (společné období mzdových a cenových dat) |
| `prumerna_mzda` | průměrná hrubá mzda za ČR (průměr přes odvětví a čtvrtletí) |
| `mzda_*` (19 sloupců) | průměrná hrubá mzda v jednotlivých odvětvích (A–S) |
| `cena_*` (27 sloupců) | průměrná cena každé kategorie potravin (průměr přes kraje a měsíce) |
| `hdp` | HDP České republiky |

Tabulka obsahuje všechna data potřebná pro zodpovězení výzkumných otázek 1–5, všechny dotazy čtou pouze z ní.

### `t_adam_hrazdera_project_sql_secondary_final`

HDP, GINI koeficient a populace evropských států (bez ČR) za roky 2006–2018. Sloupce: `country`, `year`, `gdp`, `gini`, `population`.

## Klíčová rozhodnutí

1. **Společné období 2006–2018** — `czechia_price` začíná v roce 2006, mzdy pokračují až do roku 2021. Primární tabulka pokrývá průnik obou.
2. **Filtr mezd:** `value_type_code = 5958` (průměrná hrubá mzda na zaměstnance), `unit_code = 200` (Kč), `calculation_code = 200` (přepočtený počet zaměstnanců).
3. **Chybí agregace „celkem":** `czechia_region` obsahuje jen 14 krajů a `czechia_payroll_industry_branch` jen 19 odvětví, žádný řádek pro celou ČR ani pro všechna odvětví. Celostátní hodnoty jsou proto **prostý (nevážený) průměr** přes kraje (ceny), resp. přes odvětví a čtvrtletí (mzdy). Vážený průměr (např. podle počtu zaměstnanců) by byl přesnější, ale přesahuje rozsah projektu.
4. **„Široký" formát primární tabulky** — odvětví i kategorie potravin jsou sloupce, řádek je rok. Zvoleno kvůli přehlednosti a jednoduchosti dotazů.
5. **HDP ČR** je v primární tabulce (`hdp`), protože sekundární tabulka záměrně obsahuje jen ostatní evropské státy.
6. **Žádná zdrojová data nebyla upravována.** Všechny transformace probíhají při tvorbě `_final` tabulek.

## Chybějící a problematická data

- **Víno (`cena_vino`)** — v `czechia_price` chybí data za roky 2006–2014, hodnoty jsou až od roku 2015. Otázky srovnávající celé období proto víno vylučují.
- **GINI koeficient** v tabulce `economies` má u řady zemí a let chybějící hodnoty.
- **Metodika mezd:** `calculation_code` nabízí dvě varianty (fyzický / přepočtený počet zaměstnanců), zvolil jsem přepočtený.

## Výzkumné otázky

### 1. Rostou mzdy ve všech odvětvích, nebo v některých klesají?

Porovnání jednotlivých let (každý rok proti předchozímu, zvlášť pro každé odvětví) ukazuje, že mzdy **neklesaly nikde jen v dlouhodobém součtu, ale meziročně klesaly poměrně často**:

- V letech 2006 → 2018 vzrostly mzdy ve **všech 19 odvětvích**.
- Alespoň v jednom roce meziročně klesly mzdy v **16 z 19 odvětví** (celkem **25 případů**). Bez jediného poklesu zůstaly pouze zpracovatelský průmysl, zdravotní a sociální péče a ostatní činnosti.
- Nejvíce poklesů se objevilo v roce **2013**: mzdy klesly v 11 odvětvích současně.
- Největší jednotlivý pokles: **peněžnictví a pojišťovnictví v roce 2013 (−8,83 %)**, dále energetika 2013 (−4,44 %), těžba 2013 (−3,24 %) a 2009 (−3,12 %) a profesní činnosti 2013 (−3,02 %).
- Doprava 2011: pokles o 0,5 Kč (po zaokrouhlení 0,00 %).

### 2. Kolik litrů mléka a kg chleba lze koupit za průměrnou mzdu na začátku a na konci období?

| Rok | Chléb (kg) | Mléko (l) |
|---|---|---|
| 2006 | 1 307,6 | 1 460,3 |
| 2018 | 1 363,1 | 1 667,2 |

Dostupnost obou potravin se zlepšila, mzdy rostly rychleji než jejich ceny.

### 3. Která kategorie potravin zdražuje nejpomaleji?

Porovnání cen 2006 vs. 2018:

- **Cukr (−27,51 %)** a **rajčata (−23,07 %)** ve skutečnosti zlevnily.
- Mezi kategoriemi, jejichž cena rostla, zdražovaly nejpomaleji **banány (+7,39 %)**.
- Nejrychleji zdražilo máslo (+98,38 %).
- Víno nelze porovnat (chybí cena z roku 2006).

Poznámka: metoda porovnává krajní roky, nikoli průměr meziročních změn.

### 4. Existuje rok, kdy byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (o více než 10 p. b.)?

Nenašel se žádný takový rok. Nejblíže byl rok **2013**: ceny potravin vzrostly o 6,01 %, mzdy klesly o 1,49 % (rozdíl 7,5 p. b.). V roce 2009 byl rozdíl opačný: ceny klesly o 6,58 %, mzdy vzrostly o 3,09 % (−9,67 p. b.). „Růst cen" je prostý průměr meziročního růstu přes všech 27 kategorií.

### 5. Má výška HDP vliv na změny ve mzdách a cenách potravin?

| Rok | Růst HDP (%) | Růst mezd (%) |
|---|---|---|
| 2007 | 5,57 | 6,89 |
| 2008 | 2,69 | 7,70 |
| 2009 | −4,66 | 3,09 |
| 2010 | 2,43 | 1,92 |
| 2011 | 1,76 | 2,34 |
| 2012 | −0,79 | 2,91 |
| 2013 | −0,05 | −1,49 |
| 2014 | 2,26 | 2,59 |
| 2015 | 5,39 | 2,62 |
| 2016 | 2,54 | 3,68 |
| 2017 | 5,17 | 6,19 |
| 2018 | 3,20 | 7,72 |

- **Mzdy:** souvislost je mírná a nekonzistentní. Propad HDP v roce 2009 se projevil zpomalením růstu mezd (3,09 % oproti 7,70 % v roce 2008) a po stagnaci HDP v letech 2012–2013 mzdy v roce 2013 dokonce klesly. Silný růst HDP v roce 2015 (5,39 %) se ale ve mzdách téhož roku neprojevil (2,62 %), zvýšení přišlo až později.
- **Ceny potravin:** jasná souvislost s HDP patrná není. V letech 2012–2013 HDP stagnovalo, ceny potravin přesto rostly o 7,47 % a 6,01 %, což naznačuje vliv jiných faktorů.

## Shrnutí

Dostupnost základních potravin (chléb, mléko) se v letech 2006–2018 zlepšila, protože mzdy rostly rychleji než jejich ceny. Dlouhodobě vzrostly mzdy ve všech odvětvích, ale v 16 z nich zaznamenaly alespoň jednoletý pokles, nejvýrazněji v roce 2013. Vztah HDP a mezd je patrný, ale slabý, vztah HDP a cen potravin nebyl prokázán.
