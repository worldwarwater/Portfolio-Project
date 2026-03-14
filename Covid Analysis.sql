/*
=============================================================================
  COVID-19 Global Data Exploration
  Author: Stephen Drani
  Tools: Microsoft SQL Server, SSMS
  Skills: Joins, CTEs, Temporary Tables, Window Functions, Aggregate Functions,
          Data Type Conversions, Views
  Data Source: https://ourworldindata.org/covid-deaths
=============================================================================
*/

-- ==========================================================================
-- 1. Total Cases vs Total Deaths (Global)
-- Shows the likelihood of dying if you contract COVID in each country
-- Note: NULLIF prevents division by zero errors
-- ==========================================================================

SELECT
    [location],
    [date],
    [total_cases],
    [new_cases],
    [total_deaths],
    [population],
    CAST([total_deaths] AS FLOAT) / NULLIF([total_cases], 0) * 100 AS DeathPercentage
FROM
    [dbo].[covid-Deaths]
ORDER BY
    [location], [date];

-- ==========================================================================
-- 2. Death Percentage in the United States
-- Shows the probability of death after contracting COVID in the U.S. over time
-- ==========================================================================

SELECT
    [location],
    [date],
    [total_cases],
    [new_cases],
    [total_deaths],
    [population],
    CAST([total_deaths] AS FLOAT) / NULLIF([total_cases], 0) * 100 AS DeathPercentage
FROM
    [dbo].[covid-Deaths]
WHERE
    [location] = 'United States';

-- ==========================================================================
-- 3. Total Cases vs Population
-- Shows what percentage of each country's population has been infected
-- ==========================================================================

SELECT
    [location],
    [population],
    MAX([total_cases]) AS HighestInfectionCount,
    MAX([total_cases] * 1.0 / [population] * 100) AS PercentPopulationInfected
FROM
    [dbo].[covid-Deaths]
GROUP BY
    [location], [population]
ORDER BY
    [PercentPopulationInfected] DESC;

-- ==========================================================================
-- 4. Highest Death Count per Continent
-- Ranks continents by total COVID deaths
-- ==========================================================================

SELECT
    [continent],
    MAX([total_deaths]) AS TotalDeathCount
FROM
    [dbo].[covid-Deaths]
WHERE
    [continent] IS NOT NULL
GROUP BY
    [continent]
ORDER BY
    [TotalDeathCount] DESC;

-- ==========================================================================
-- 5. Global Death Percentage
-- Calculates the overall global death rate from new cases and new deaths
-- ==========================================================================

SELECT
    SUM([new_cases]) AS TotalNewCases,
    SUM([new_deaths]) AS TotalDeaths,
    (SUM([new_deaths]) * 1.0 / NULLIF(SUM([new_cases]), 0)) * 100 AS DeathPercentage
FROM
    [dbo].[covid-Deaths]
WHERE
    [continent] IS NOT NULL
ORDER BY
    1, 2;

-- ==========================================================================
-- 6. Rolling Vaccination Count Using CTE
-- Calculates a running total of vaccinations per country and the
-- percentage of the population vaccinated over time
-- ==========================================================================

WITH PopvsVac ([continent], [location], [date], [population], [new_vaccinations], RollingPeopleVaccinated, VaccinationPercentage) AS
(
    SELECT
        cd.[continent],
        cd.[location],
        cd.[date],
        cd.[population],
        vac.[new_vaccinations],
        SUM(vac.[new_vaccinations]) OVER (PARTITION BY cd.[location] ORDER BY cd.[date]) AS RollingPeopleVaccinated,
        (SUM(vac.[new_vaccinations]) OVER (PARTITION BY cd.[location] ORDER BY cd.[date]) * 100.0 / cd.[population]) AS VaccinationPercentage
    FROM
        [dbo].[covid-Deaths] AS cd
    JOIN
        [dbo].[covid-Vaccination] AS vac
        ON cd.location = vac.location
       AND cd.date = vac.date
    WHERE
        cd.[continent] IS NOT NULL
)
SELECT *
FROM PopvsVac;

-- ==========================================================================
-- 7. Rolling Vaccination Count Using Temporary Table
-- Same analysis as above but using a temp table approach for flexibility
-- ==========================================================================

IF OBJECT_ID('tempdb..#PercentPopulationsVaccinated') IS NOT NULL
    DROP TABLE #PercentPopulationsVaccinated;

CREATE TABLE #PercentPopulationsVaccinated(
    [continent] NVARCHAR(255),
    [location] NVARCHAR(255),
    [date] DATETIME,
    [population] NUMERIC(18, 0),
    [new_vaccinations] NUMERIC(18, 0),
    [RollingPeopleVaccinated] NUMERIC(18, 2),
    [VaccinationPercentage] NUMERIC(18, 2)
);

INSERT INTO #PercentPopulationsVaccinated (
    [continent],
    [location],
    [date],
    [population],
    [new_vaccinations],
    [RollingPeopleVaccinated],
    [VaccinationPercentage]
)
SELECT
    cd.[continent],
    cd.[location],
    cd.[date],
    cd.[population],
    vac.[new_vaccinations],
    SUM(ISNULL(vac.[new_vaccinations], 0)) OVER (PARTITION BY cd.[location] ORDER BY cd.[date]) AS RollingPeopleVaccinated,
    (SUM(ISNULL(vac.[new_vaccinations], 0)) OVER (PARTITION BY cd.[location] ORDER BY cd.[date]) * 100.0 / cd.[population]) AS VaccinationPercentage
FROM
    [dbo].[covid-Deaths] AS cd
JOIN
    [dbo].[covid-Vaccination] AS vac
    ON cd.location = vac.location
   AND cd.date = vac.date
WHERE
    cd.[continent] IS NOT NULL;

SELECT * FROM #PercentPopulationsVaccinated;

-- ==========================================================================
-- 8. Create View for Visualization Layer
-- Stores the vaccination progress query as a reusable view
-- for connecting to Tableau or Power BI
-- ==========================================================================

CREATE VIEW PercentPopulationsVaccinated AS
SELECT
    cd.[continent],
    cd.[location],
    cd.[date],
    cd.[population],
    vac.[new_vaccinations],
    SUM(ISNULL(vac.[new_vaccinations], 0)) OVER (PARTITION BY cd.[location] ORDER BY cd.[date]) AS RollingPeopleVaccinated,
    (SUM(ISNULL(vac.[new_vaccinations], 0)) OVER (PARTITION BY cd.[location] ORDER BY cd.[date]) * 100.0 / cd.[population]) AS VaccinationPercentage
FROM
    [dbo].[covid-Deaths] AS cd
JOIN
    [dbo].[covid-Vaccination] AS vac
    ON cd.location = vac.location
   AND cd.date = vac.date
WHERE
    cd.[continent] IS NOT NULL;
