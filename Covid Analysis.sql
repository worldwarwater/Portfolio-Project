/*
-- Covid 19 Data Exploration 

Skills: Joins, CTE's, Temporary Tables, -- add more

--Looking at total_cases(1) vs total_deaths(2)

slight issues in the writing of the syntax wouldn't first allow for simple 2/1 when the numerator was smaller than the denominator that is why Nullif was used -- could have been solved in the data cleaning process

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

-- Total Death vs Total cases as DeatPercentage for U.S
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
where
[location]= 'United States' 
--Total Cases vs Population as PercentPopulationInfected
SELECT 
    [location],
    [population],
    MAX([total_cases]) AS HighestInfectionCount,
    MAX([total_cases] * 1.0 / [population] * 100) AS PercentPopulationInfected
FROM
    [dbo].[covid-Deaths]
Group by [location], [population]
order by 
    [PercentPopulationInfected] Desc

-- Highest Death count per Continent 

SELECT 
    [continent],
    MAX([total_deaths]) AS TotalDeathCount
FROM
    [dbo].[covid-Deaths]
where [continent] is not NULL
Group by 
    [continent]
order by 
    [TotalDeathCount] Desc;

--Finding Death Percantage using TotalDeats / TotalnewCases

  SELECT 
    --[date],
    SUM([new_cases]) AS TotalNewCases,
    SUM([new_deaths]) AS TotalDeaths,
    (SUM([new_deaths]) * 1.0 / NULLIF(SUM([new_cases]), 0)) * 100 AS DeathPercentage
FROM
    [dbo].[covid-Deaths]
WHERE
    [continent] IS NOT NULL
--GROUP BY 
 --   [date]
ORDER BY 
    1,2;
 
SELECT 
    cd.[continent],
    cd.[location],
    cd.[date],
    cd.[population],
    vac.[new_vaccinations],
    SUM(vac.[new_vaccinations]) OVER (Partition by cd.[location] order by cd.[location], cd.[date])
     as RollingPeopleVaccinated,
     (RollingPeopleVaccinated/[population])
FROM
    [dbo].[covid-Deaths] AS cd
Join
    [dbo].[covid-Vaccination] as vac 
    ON cd.location = vac.location
   AND cd.date = vac.date
where
    cd.[continent] is not NULL
order by 2,3
-- Use CTE

With PopvsVac ([continent],[location],[date],[population],[new_vaccinations], RollingPeopleVaccinated) AS
(
SELECT 
    cd.[continent],
    cd.[location],
    cd.[date],
    cd.[population],
    vac.[new_vaccinations],
    SUM(vac.[new_vaccinations]) OVER (Partition by cd.[location] order by cd.[location], cd.[date])
     as RollingPeopleVaccinated,
     (RollingPeopleVaccinated/[population]) * 100
FROM
    [dbo].[covid-Deaths] AS cd
Join
    [dbo].[covid-Vaccination] as vac 
    ON cd.location = vac.location
   AND cd.date = vac.date
where
    cd.[continent] is not NULL
--order by 2,3
)
SELECT *
From PopvsVac

-- Looking at Total Population vs Vaccinations -- creating temporary tables to first find RollingPeopleVaccainated then using the to find the VaccinationPercentage
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


*/
-- Check if the temporary table exists and drop it if it does
IF OBJECT_ID('tempdb..#PercentPopulationsVaccinated') IS NOT NULL
    DROP TABLE #PercentPopulationsVaccinated;

-- Create the temporary table
CREATE TABLE #PercentPopulationsVaccinated(
    [continent] NVARCHAR(255),
    [location] NVARCHAR(255),
    [date] DATETIME,
    [population] NUMERIC(18, 0),
    [new_vaccinations] NUMERIC(18, 0),
    [RollingPeopleVaccinated] NUMERIC(18, 2),
    [VaccinationPercentage] NUMERIC(18, 2)
);

-- Insert the data into the temporary table
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

-- Optional: Select data from the temporary table to verify results
SELECT * FROM #PercentPopulationsVaccinated;


Create View PercentPopulationsVaccinated as 
Select
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
    cd.[continent] IS NOT NULL; */
    