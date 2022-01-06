/*

Cleaning Data in SQL Queries

*/

-- Standardize Date Format

--Select SaleDate
--FROM PortfolioProject..NashvilleHousing

--Select SaleDate, CONVERT(DATE, SaleDate)
--From PortfolioProject..NashvilleHousing

--Update NashvilleHousing 
--SET SaleDate = CONVERT(DATE, SaleDate)

--For some reason, the above command doesnt work.

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE;

Update NashvilleHousing 
SET SaleDateConverted = CONVERT(DATE, SaleDate)

Select SaleDateConverted
From NashvilleHousing

---------------------------------------------------------

-- Populate Property Address Data

Select PropertyAddress
From PortfolioProject..NashvilleHousing
Where PropertyAddress IS NULL

SELECT *
FROM PortfolioProject..NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) --When a.PropertyAddress is null, replaces with b.PropertyAddress
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
--The above command is to populate null fields, since some rows have the same ParcelID, but some have nulls. The Unique ID makes
--sure that the rows are indeed different.

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))


SELECT * 
FROM PortfolioProject..NashvilleHousing

SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT
PARSENAME(Replace(OwnerAddress, ',', '.'), 3) AS Address --need to use replace since parsename only looks for periods
, PARSENAME(Replace(OwnerAddress, ',', '.'), 2) AS City
, PARSENAME(Replace(OwnerAddress, ',', '.'), 1) AS State
FROM PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerAddressSplit Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerAddressSplit = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerCitySplit Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerCitySplit = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerStateSplit Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerStateSplit = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

----------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group By SoldAsVacant

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		END
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
		When SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		END
-----------------------------------

-- Remove Duplicates
-- Note: not a common practice to remove data from a dataset in the workplace

--Checks for duplicates
WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() Over (
	PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY 
						UniqueID
						) row_num
From NashvilleHousing
)
--Order By ParcelID
Select * 
From RowNumCTE
Where row_num > 1
Order By PropertyAddress


--Deletes Duplicates
WITH RowNumCTE AS(
Select *, 
	ROW_NUMBER() Over (
	PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY 
						UniqueID
						) row_num
From NashvilleHousing
)
--Order By ParcelID
Delete
From RowNumCTE
Where row_num > 1

------------------------------------

-- Delete Unused Columns
-- Note: DON'T DELETE DATA WITHOUT PERMISSION

Select *
From PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate

