/*

Cleaning Data in SQL Queries

*/

SELECT * 
FROM PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted, Convert(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = Convert(date, SaleDate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date; 

Update NashvilleHousing
SET SaleDateConverted = Convert(date, SaleDate)

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

SELECT *
FROM PortfolioProject..NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

SELECT a.PArcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
Where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress 
FROM PortfolioProject..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress VARCHAR(255); 

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity VARCHAR(255); 

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

SELECT * 

FROM PortfolioProject..NashvilleHousing

-- Without SUBSTRING. We use PARSENAME

SELECT OwnerAddress 
FROM PortfolioProject..NashvilleHousing

SELECT 
PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress VARCHAR(255); 

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity VARCHAR(255); 

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState VARCHAR(255); 

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE (OwnerAddress, ',', '.'), 1)

SELECT * 
FROM PortfolioProject..NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT  DISTINCT (SoldAsVacant), count(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUp BY SoldAsVacant
Order BY 2

SELECT SoldAsVacant, 
CASE When SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant
	 END
FROM PortfolioProject..NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
	 When SoldAsVacant = 'N' then 'No'
	 ELSE SoldAsVacant
	 END

-- Remove Duplicates:

WITH RowNumCTE AS(
SELECT *, ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
FROM PortfolioProject..NashvilleHousing
) 
SELECT *  
FROM RowNumCTE
WHERE row_num > 1
Order by PropertyAddress


-- Delete Unused Columns:

SELECT *  
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

