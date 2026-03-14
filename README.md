# SQL Portfolio Projects

A collection of SQL projects demonstrating data exploration, analysis, and cleaning skills using Microsoft SQL Server.

## Projects

### 1. COVID-19 Global Data Exploration
**File:** [`Covid Analysis.sql`](Covid%20Analysis.sql)

Exploratory analysis of global COVID-19 data examining infection rates, death percentages, and vaccination progress across countries and continents.

**Skills Demonstrated:**
- Complex JOINs across multiple tables
- Common Table Expressions (CTEs)
- Window Functions (SUM OVER PARTITION BY)
- Temporary Tables for multi-step calculations
- CAST and data type conversions
- Aggregate functions with GROUP BY
- Views for reusable queries

**Key Analyses:**
- Death percentage by country (total deaths vs. total cases)
- Population infection rates by country
- Highest death counts by continent
- Global death percentage trends
- Rolling vaccination counts with population percentage using CTEs and temp tables

---

### 2. Nashville Housing Data Cleaning
**File:** [`DataCleaningNashville.sql`](DataCleaningNashville.sql)

End-to-end data cleaning project on Nashville housing sales data, transforming raw records into analysis-ready format.

**Skills Demonstrated:**
- Date format standardization (CONVERT)
- NULL value handling with self-JOINs and ISNULL
- String parsing with SUBSTRING, CHARINDEX, and PARSENAME
- CASE statements for value standardization
- Duplicate detection and removal using ROW_NUMBER with CTEs
- Schema modification (ALTER TABLE, DROP COLUMN)

**Cleaning Steps:**
1. Standardized date formats across the dataset
2. Populated missing property addresses using ParcelID self-joins
3. Split combined address fields into individual columns (Address, City, State)
4. Converted Y/N values to Yes/No for consistency
5. Identified and removed duplicate records
6. Dropped redundant columns to streamline the dataset

---

## Tools & Technologies
- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- T-SQL

## Data Sources
- COVID-19 data: [Our World in Data](https://ourworldindata.org/covid-deaths)
- Nashville housing data: [Kaggle](https://www.kaggle.com/datasets/tmthyjames/nashville-housing-data)

## Author
**Stephen Drani** — [LinkedIn](https://linkedin.com/in/stephen-drani-a58140232) | [GitHub](https://github.com/worldwarwater)
