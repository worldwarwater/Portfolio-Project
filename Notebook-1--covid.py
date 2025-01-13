{
    "metadata": {
        "kernelspec": {
            "name": "SQL",
            "display_name": "SQL",
            "language": "sql"
        },
        "language_info": {
            "name": "sql",
            "version": ""
        }
    },
    "nbformat_minor": 2,
    "nbformat": 4,
    "cells": [
        {
            "cell_type": "markdown",
            "source": [
                "\\-- Covid 19 Data Exploration \n",
                "\n",
                "Skills: Joins, CTE's, Temporary Tables, -- add more\n",
                "\n",
                "\\--Looking at total\\_cases(1) vs total\\_deaths(2)\n",
                "\n",
                "slight issues in the writing of the syntax wouldn't first allow for simple 2/1 when the numerator was smaller than the denominator that is why Nullif was used -- could have been solved in the data cleaning process"
            ],
            "metadata": {
                "azdata_cell_guid": "e5ea51fb-d030-4df9-95d6-9845f80b789a"
            },
            "attachments": {}
        },
        {
            "cell_type": "code",
            "source": [
                "SELECT\n",
                "    [continent],\n",
                "    [date],\n",
                "    [total_cases],\n",
                "    [new_cases],\n",
                "    [total_deaths],\n",
                "    [population],\n",
                "    CAST([total_deaths] AS FLOAT) / NULLIF([total_cases], 0) * 100 AS DeathPercentage\n",
                "FROM \n",
                "    [dbo].[covid-Deaths]\n",
                "ORDER BY \n",
                "    [continent], [date];"
            ],
            "metadata": {
                "azdata_cell_guid": "2d0cc61a-95a5-4ceb-b4e7-b0d08fa82406",
                "language": "sql"
            },
            "outputs": [
                {
                    "output_type": "error",
                    "ename": "",
                    "evalue": "Msg 208, Level 16, State 1, Line 1\nInvalid object name 'dbo.covid-Deaths'.",
                    "traceback": []
                },
                {
                    "output_type": "display_data",
                    "data": {
                        "text/html": "Total execution time: 00:00:00.016"
                    },
                    "metadata": {}
                }
            ],
            "execution_count": 1
        },
        {
            "cell_type": "markdown",
            "source": [
                ""
            ],
            "metadata": {
                "azdata_cell_guid": "7eebc908-e58f-41e7-8261-c1314f642de9"
            }
        },
        {
            "cell_type": "markdown",
            "source": [
                "\\--Countries with the Highest Infection Rate compared to the Population"
            ],
            "metadata": {
                "azdata_cell_guid": "06af4e6f-3c93-4716-98f8-13e25cd66a29"
            },
            "attachments": {}
        },
        {
            "cell_type": "code",
            "source": [
                "SELECT \n",
                "    [continent],\n",
                "    [population],\n",
                "    MAX([total_cases]) AS HighestInfectionCount,\n",
                "    MAX([total_cases] * 1.0 / [population] * 100) AS PercentPopulationInfected\n",
                "FROM\n",
                "    [dbo].[covid-Deaths]\n",
                "Group by [continent], [population]\n",
                "order by \n",
                "    [PercentPopulationInfected] Desc"
            ],
            "metadata": {
                "azdata_cell_guid": "5d33631d-9f33-43f0-966a-d98ee6e7a58d",
                "language": "sql"
            },
            "outputs": [],
            "execution_count": null
        },
        {
            "cell_type": "markdown",
            "source": [
                "\\-- Highest Death Count per Population"
            ],
            "metadata": {
                "azdata_cell_guid": "57ac7c22-4bc5-46fc-b975-b641f0ed8823"
            },
            "attachments": {}
        },
        {
            "cell_type": "code",
            "source": [
                "SELECT \n",
                "    [continent],\n",
                "    MAX([total_deaths]) AS TotalDeathCount\n",
                "FROM\n",
                "    [dbo].[covid-Deaths]\n",
                "where [continent] is not NULL\n",
                "Group by \n",
                "    [continent]\n",
                "order by \n",
                "    [TotalDeathCount] Desc"
            ],
            "metadata": {
                "azdata_cell_guid": "5c165976-80bc-40bb-82b3-61459c051eb8",
                "language": "sql",
                "tags": []
            },
            "outputs": [],
            "execution_count": null
        },
        {
            "cell_type": "markdown",
            "source": [
                "Highest Death count continent"
            ],
            "metadata": {
                "azdata_cell_guid": "e4fed0d7-91e0-41f0-81e3-74461a8c2997"
            },
            "attachments": {}
        },
        {
            "cell_type": "code",
            "source": [
                "SELECT \n",
                "    [continent],\n",
                "    MAX([total_deaths]) AS TotalDeathCount\n",
                "FROM\n",
                "    [dbo].[covid-Deaths]\n",
                "where [continent] is not NULL\n",
                "Group by \n",
                "    [continent]\n",
                "order by \n",
                "    [TotalDeathCount] Desc"
            ],
            "metadata": {
                "azdata_cell_guid": "ab635226-416e-462d-8db0-778d21173528",
                "language": "sql"
            },
            "outputs": [],
            "execution_count": null
        },
        {
            "cell_type": "markdown",
            "source": [
                "Looking at Total Population vs Vaccinations -- creating temporary tables to first find RollingPeopleVaccainated then using the to find the VaccinationPercentage"
            ],
            "metadata": {
                "azdata_cell_guid": "e418c245-c140-42b0-b326-a12db6e598e0"
            },
            "attachments": {}
        },
        {
            "cell_type": "markdown",
            "source": [
                ""
            ],
            "metadata": {
                "azdata_cell_guid": "9e205ad5-f528-416f-bbd2-abc22f9c0984"
            }
        },
        {
            "cell_type": "code",
            "source": [
                "WITH PopvsVac ([continent], [location], [date], [population], [new_vaccinations], RollingPeopleVaccinated, VaccinationPercentage) AS\n",
                "(\n",
                "    SELECT \n",
                "        cd.[continent],\n",
                "        cd.[location],\n",
                "        cd.[date],\n",
                "        cd.[population],\n",
                "        vac.[new_vaccinations],\n",
                "        SUM(vac.[new_vaccinations]) OVER (PARTITION BY cd.[location] ORDER BY cd.[date]) AS RollingPeopleVaccinated,\n",
                "        (SUM(vac.[new_vaccinations]) OVER (PARTITION BY cd.[location] ORDER BY cd.[date]) * 100.0 / cd.[population]) AS VaccinationPercentage\n",
                "    FROM\n",
                "        [dbo].[covid-Deaths] AS cd\n",
                "    JOIN\n",
                "        [dbo].[covid-Vaccination] AS vac \n",
                "        ON cd.location = vac.location\n",
                "       AND cd.date = vac.date\n",
                "    WHERE\n",
                "        cd.[continent] IS NOT NULL\n",
                ")\n",
                "SELECT *\n",
                "FROM PopvsVac;"
            ],
            "metadata": {
                "azdata_cell_guid": "a265adea-22a0-424f-9733-c1417f63afe6",
                "language": "sql"
            },
            "outputs": [],
            "execution_count": null
        },
        {
            "cell_type": "markdown",
            "source": [
                "Creating Temp Table called #PercentsPopulationVaccinated then using insert Into to find RollingPeople Vaccinated and Vaccination Percentage ( needed a if statement to drop already existing script to run several time incase of user error in the script)"
            ],
            "metadata": {
                "azdata_cell_guid": "74881a30-f6f8-4023-908b-dae5455e6e25"
            },
            "attachments": {}
        },
        {
            "cell_type": "code",
            "source": [
                "-- Check if the temporary table exists and drop it if it does\n",
                "IF OBJECT_ID('tempdb..#PercentPopulationsVaccinated') IS NOT NULL\n",
                "    DROP TABLE #PercentPopulationsVaccinated;\n",
                "-- Create the temporary table\n",
                "CREATE TABLE #PercentPopulationsVaccinated(\n",
                "    [continent] NVARCHAR(255),\n",
                "    [location] NVARCHAR(255),\n",
                "    [date] DATETIME,\n",
                "    [population] NUMERIC(18, 0),\n",
                "    [new_vaccinations] NUMERIC(18, 0),\n",
                "    [RollingPeopleVaccinated] NUMERIC(18, 2),\n",
                "    [VaccinationPercentage] NUMERIC(18, 2)\n",
                ");\n",
                "-- Insert the data into the temporary table\n",
                "INSERT INTO #PercentPopulationsVaccinated (\n",
                "    [continent],\n",
                "    [location],\n",
                "    [date],\n",
                "    [population],\n",
                "    [new_vaccinations],\n",
                "    [RollingPeopleVaccinated],\n",
                "    [VaccinationPercentage]\n",
                ")\n",
                "SELECT \n",
                "    cd.[continent],\n",
                "    cd.[location],\n",
                "    cd.[date],\n",
                "    cd.[population],\n",
                "    vac.[new_vaccinations],\n",
                "    SUM(ISNULL(vac.[new_vaccinations], 0)) OVER (PARTITION BY cd.[location] ORDER BY cd.[date]) AS RollingPeopleVaccinated,\n",
                "    (SUM(ISNULL(vac.[new_vaccinations], 0)) OVER (PARTITION BY cd.[location] ORDER BY cd.[date]) * 100.0 / cd.[population]) AS VaccinationPercentage\n",
                "FROM\n",
                "    [dbo].[covid-Deaths] AS cd\n",
                "JOIN\n",
                "    [dbo].[covid-Vaccination] AS vac \n",
                "    ON cd.location = vac.location\n",
                "   AND cd.date = vac.date\n",
                "WHERE\n",
                "    cd.[continent] IS NOT NULL;\n",
                "-- Optional: Select data from the temporary table to verify results\n",
                "SELECT * FROM #PercentPopulationsVaccinated;"
            ],
            "metadata": {
                "azdata_cell_guid": "4f9d4ea5-2fe6-44e5-b9eb-bcf60076fd36",
                "language": "sql"
            },
            "outputs": [],
            "execution_count": null
        }
    ]
}