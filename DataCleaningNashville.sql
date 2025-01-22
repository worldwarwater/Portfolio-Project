-- intial version of csv file had SaleDate not configured properly that was changed in csv file but can be done in sql
Select 
    [SaleDate],
    CONVERT(Date,[SaleDate]) as NewSaleDate
FROM 
    [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)] as NashvilleHousing

Udpate NashvilleHousing
Set SaleDate = CONVERT(Date,[NewSaleDate])
ALTER Table NashvilleHousing 
 Add NewSaleDate Date;

Update NashvilleHousing 
    Set NewSaleDate = CONVERT(Date, SaleDate)

-- Populate Property Address Data
SELECT 
    a.[ParcelID],
    a.[PropertyAddress],
    b.[ParcelID],
    b.[PropertyAddress],
    ISNULL(a.[PropertyAddress],b.[PropertyAddress])
FROM
    [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)] AS a
JOIN
    [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)] AS b 
    on a.[ParcelID] = b.[ParcelID]
    AND a.[UniqueID] = b.[UniqueID]
Where a.[PropertyAddress] is null 
-- this is to now update the columns

UPDATE a
SET a.[PropertyAddress] = ISNULL(a.[PropertyAddress], b.[PropertyAddress])
FROM 
    [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)] AS a
JOIN 
    [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)] AS b
    ON a.[ParcelID] = b.[ParcelID]
    AND a.[UniqueID] = b.[UniqueID]
WHERE a.[PropertyAddress] IS NULL;

--- Breaking out PropertyAddress into Indvidual Columns(Address, City, State)


SELECT 
    SUBSTRING([PropertyAddress],1, CHARINDEX(',',[PropertyAddress])-1) as Address,
    SUBSTRING([PropertyAddress], CHARINDEX(',',[PropertyAddress])+1,LEN([PropertyAddress])) as Address

FROM
    [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]

ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]
ADD [PropertySplitAddress] NVARCHAR(255);

UPDATE [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]
Set [PropertySplitAddress] = SUBSTRING([PropertyAddress],1, CHARINDEX(',',[PropertyAddress])-1) 

ALTER Table [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]
ADD [PropertySplitCity] NVARCHAR(255)
UPDATE [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]
SET [PropertySplitCity] = SUBSTRING([PropertyAddress], CHARINDEX(',',[PropertyAddress])+1,LEN([PropertyAddress]))

SELECT *
FROM
    [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]


-- Breaking up OwnerAddress into three separate columns using the commas point of separation
SELECT
    PARSENAME(REPLACE([OwnerAddress], ',', '.'), 3) AS StreetAddress,
    PARSENAME(REPLACE([OwnerAddress], ',', '.'), 2) AS City,
    PARSENAME(REPLACE([OwnerAddress], ',', '.'), 1) AS State
FROM
    [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]

-- Change the Y and N to Yes and No in "Sold as Vacant" Field

SELECT
    Distinct([SoldAsVacant]),
    Count([SoldAsVacant])
From 
    [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]
GROUP by 
    [SoldAsVacant]
Order by 2
-- The Change 
SELECT
[SoldAsVacant],
Case When [SoldAsVacant] = 'Y' Then 'Yes'
 When [SoldAsVacant] = 'N' Then 'No'
Else [SoldAsVacant]
 END
FROM
    [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]
-- update Run count to find the count
UPDATE [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]
Set [SoldAsVacant] = Case When [SoldAsVacant] = 'Y' Then 'Yes'
 When [SoldAsVacant] = 'N' Then 'No'
Else [SoldAsVacant]
 END

-- Remove Duplicates
With RowNumCTE AS (
SELECT *,
    Row_Number() OVER (
        PARTITION By [ParcelID],[PropertyAddress],[SalePrice],[SaleDate],[legalReference]
        Order by [UniqueID]
    ) As Row_Num
From
    [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]
)

select *
From RowNumCTE
Where Row_Num > 1


Select * 
FROM
[dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]

-- Delete Unused Columns 
Select * 
FROM
[dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]

Alter Table [dbo].[Nashville Housing Data for Data Cleaning (reuploaded)]
Drop COLUMN [OwnerAddress],[TaxDistrict], [PropertyAddress],[SaleDate]