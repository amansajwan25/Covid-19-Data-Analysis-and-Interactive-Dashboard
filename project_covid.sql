CREATE TABLE covid_data (
    Date DATE,
    Country VARCHAR(100),
    Population BIGINT,
    Confirmed_Cases BIGINT,
    New_Cases BIGINT,
    Deaths BIGINT,
    New_Deaths BIGINT,
    Recovered BIGINT,
    Active_Cases BIGINT,
    Vaccinations BIGINT,
    Death_Rate_Percent DECIMAL(10,2),
    Recovery_Rate_Percent DECIMAL(10,2)
);

select * from covid_data;

--1. What are the total confirmed cases globally?
Create view confirmed_cases as
WITH latest_data AS (
    SELECT DISTINCT ON (country)
        country,
        confirmed_cases
    FROM covid_data
    ORDER BY country, date DESC
)
SELECT 
    SUM(confirmed_cases) AS global_confirmed_cases
FROM latest_data;

--2. Top 3 countries with highest number of cases
Create view top3_cases as
SELECT country,
    MAX(confirmed_cases) AS total_cases
FROM covid_data
GROUP BY country
ORDER BY total_cases DESC
LIMIT 3;

--3. Top 3 countries with highest death counts
Create view death_counts as
SELECT 
    country,
    MAX(deaths) AS total_deaths
FROM covid_data
GROUP BY country
ORDER BY total_deaths DESC
LIMIT 3;

--4. What was the daily/weekly trend of new cases

--DAILY
SELECT 
    date,
    SUM(new_cases) AS daily_new_cases
FROM covid_data
GROUP BY date
ORDER BY date;

--WEEKLY
SELECT
    DATE_TRUNC('week', date)::date AS week_start,
    SUM(new_cases) AS weekly_new_cases
FROM covid_data
GROUP BY DATE_TRUNC('week', date)
ORDER BY week_start;

--5. What is the death rate by country
SELECT
    country,
    MAX(confirmed_cases) AS total_cases,
    MAX(deaths) AS total_deaths,
    ROUND(
        MAX(deaths)::numeric 
        / NULLIF(MAX(confirmed_cases), 0) * 100,
        2
    ) AS death_rate_percent
FROM covid_data
GROUP BY country
ORDER BY death_rate_percent DESC;

--6. Top 3 countries with highest recovery rate

SELECT
    country,
    MAX(confirmed_cases) AS total_cases,
    MAX(recovered) AS total_recovered,
    ROUND(
        MAX(recovered)::numeric
        / NULLIF(MAX(confirmed_cases), 0) * 100,
        2
    ) AS recovery_rate_percent
FROM covid_data
GROUP BY country
ORDER BY recovery_rate_percent DESC;

--7. How did cases change during major COVID waves?
SELECT
    CASE
        WHEN date BETWEEN '2020-01-01' AND '2020-12-31'
            THEN '2020 Wave'
        WHEN date BETWEEN '2021-01-01' AND '2021-12-31'
            THEN '2021 Wave'
        WHEN date BETWEEN '2022-01-01' AND '2022-12-31'
            THEN '2022 Wave'
    END AS covid_wave,
    SUM(new_cases) AS total_new_cases
FROM covid_data
GROUP BY covid_wave
ORDER BY covid_wave;

--8. How did global vaccination numbers change over time

SELECT
    date,
    SUM(vaccinations) AS total_vaccinations
FROM covid_data
GROUP BY date
ORDER BY date;

--9. Which ountries top 5 had the largest single-day increase in cases
SELECT
    country,
    MAX(new_cases) AS highest_single_day_increase
FROM covid_datas
GROUP BY country
ORDER BY highest_single_day_increase DESC
LIMIT 5;