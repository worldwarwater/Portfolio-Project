/*
=============================================================================
  Nashville Housing Data Cleaning
  Author: Stephen Drani
  Tools: Microsoft SQL Server, SSMS
  Skills: Data Cleaning, String Parsing, Date Conversion, Self-Joins,
          CASE Statements, CTEs, Duplicate Removal, Schema Modification
  Data Source: https://www.kaggle.com/datasets/tmthyjames/nashville-housing-data
=============================================================================
*/

-- ==========================================================================
-- 1. Standardize Date Format
-- The original SaleDate column contained datetime values; converting to Date
-- for cleaner analysis. Initial CSV had formatting issues corrected pre-import.
-- ==========================================================================

SELECT
    [SaleDate],
    CONVERT(Date, [SaleDate]) AS NewSaleDate
FROM
    [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)] AS NashvilleHousing;

ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]
    ADD NewSaleDate Date;

UPDATE [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]
    SET NewSaleDate = CONVERT(Date, SaleDate);

-- ==========================================================================
-- 2. Populate Missing Property Addresses
-- Uses a self-join on ParcelID to fill NULL addresses from matching records.
-- Properties with the same ParcelID share the same address.
-- ==========================================================================

SELECT
    a.[ParcelID],
    a.[PropertyAddress],
    b.[ParcelID],
    b.[PropertyAddress],
    ISNULL(a.[PropertyAddress], b.[PropertyAddress]) AS PopulatedAddress
FROM
    [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)] AS a
JOIN
    [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)] AS b
    ON a.[ParcelID] = b.[ParcelID]
    AND a.[UniqueID] <> b.[UniqueID]
WHERE
    a.[PropertyAddress] IS NULL;

-- Apply the update
UPDATE a
SET a.[PropertyAddress] = ISNULL(a.[PropertyAddress], b.[PropertyAddress])
FROM
    [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)] AS a
JOIN
    [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)] AS b
    ON a.[ParcelID] = b.[ParcelID]
    AND a.[UniqueID] <> b.[UniqueID]
WHERE
    a.[PropertyAddress] IS NULL;

-- ==========================================================================
-- 3. Split PropertyAddress into Individual Columns (Address, City)
-- Uses SUBSTRING and CHARINDEX to parse the comma-delimited address field
-- ==========================================================================

SELECT
    SUBSTRING([PropertyAddress], 1, CHARINDEX(',', [PropertyAddress]) - 1) AS Address,
    SUBSTRING([PropertyAddress], CHARINDEX(',', [PropertyAddress]) + 1, LEN([PropertyAddress])) AS City
FROM
    [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)];

ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]
    ADD [PropertySplitAddress] NVARCHAR(255);

UPDATE [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]
    SET [PropertySplitAddress] = SUBSTRING([PropertyAddress], 1, CHARINDEX(',', [PropertyAddress]) - 1);

ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]
    ADD [PropertySplitCity] NVARCHAR(255);

UPDATE [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]
    SET [PropertySplitCity] = SUBSTRING([PropertyAddress], CHARINDEX(',', [PropertyAddress]) + 1, LEN([PropertyAddress]));

-- ==========================================================================
-- 4. Split OwnerAddress into Three Columns (Street, City, State)
-- Uses PARSENAME with REPLACE to leverage the period-based parsing function
-- ==========================================================================

SELECT
    PARSENAME(REPLACE([OwnerAddress], ',', '.'), 3) AS StreetAddress,
    PARSENAME(REPLACE([OwnerAddress], ',', '.'), 2) AS City,
    PARSENAME(REPLACE([OwnerAddress], ',', '.'), 1) AS State
FROM
    [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)];

-- ==========================================================================
-- 5. Standardize "Sold as Vacant" Field
-- Converts Y/N values to Yes/No for consistency across the dataset
-- ==========================================================================

-- Check current distribution
SELECT
    DISTINCT([SoldAsVacant]),
    COUNT([SoldAsVacant]) AS RecordCount
FROM
    [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]
GROUP BY
    [SoldAsVacant]
ORDER BY
    2;

-- Apply standardization
UPDATE [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]
SET [SoldAsVacant] = CASE
    WHEN [SoldAsVacant] = 'Y' THEN 'Yes'
    WHEN [SoldAsVacant] = 'N' THEN 'No'
    ELSE [SoldAsVacant]
END;

-- ==========================================================================
-- 6. Remove Duplicate Records
-- Uses ROW_NUMBER with a CTE to identify duplicates based on key fields.
-- Records sharing ParcelID, PropertyAddress, SalePrice, SaleDate, and
-- LegalReference are considered duplicates.
-- ==========================================================================

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY
                [ParcelID],
                [PropertyAddress],
                [SalePrice],
                [SaleDate],
                [LegalReference]
            ORDER BY
                [UniqueID]
        ) AS Row_Num
    FROM
        [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]
)
SELECT *
FROM RowNumCTE
WHERE Row_Num > 1;

-- ==========================================================================
-- 7. Drop Unused Columns
-- Removes redundant columns that have been replaced by cleaned versions
-- ==========================================================================

ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]
DROP COLUMN [OwnerAddress], [TaxDistrict], [PropertyAddress], [SaleDate];

-- Verify final clean dataset
SELECT *
FROM [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)];
