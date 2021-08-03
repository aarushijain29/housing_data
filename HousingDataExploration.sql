SELECT *
FROM HousingData..NashvilleHousing

-- Standardize date format
SELECT SaleDate, SalesDate, CONVERT(Date, SaleDate)
FROM HousingData..NashvilleHousing

ALTER TABLE HousingData..NashvilleHousing
ADD SalesDate Date;

UPDATE HousingData..NashvilleHousing
SET SalesDate = CONVERT(Date, SaleDate)

-- Populate Property Address Data

	-- Properties with same ParcelID have the same ParcelAddress
SELECT *
FROM HousingData..NashvilleHousing
-- WHERE PropertyAddress IS NULL
ORDER BY ParcelID

	-- We will use ParcelID to fill all the NULL PropertyAddress values
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM HousingData..NashvilleHousing a JOIN HousingData..NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
	-- Updating the table to fill all NULL PropertyAddress values
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingData..NashvilleHousing a JOIN HousingData..NashvilleHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking PorpertyAddress and OwnerAddress into Address, City and State

	-- Breaking PropertyAddress into Address and City

SELECT PropertyAddress
FROM HousingData..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM HousingData..NashvilleHousing

ALTER TABLE HousingData..NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE HousingData..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE HousingData..NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE HousingData..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

	-- Breaking OwnerAddress into Address, City and State

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) as OwnerSplitState,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as OwnerCity,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as OwnerSplitAddress
FROM HousingData..NashvilleHousing

	-- Adding and Updating Owner Address

ALTER TABLE HousingData..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

UPDATE HousingData..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

	-- Adding and Updating Owner City
ALTER TABLE HousingData..NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

UPDATE HousingData..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
	
	-- Adding and Updating Owner State
ALTER TABLE HousingData..NashvilleHousing
ADD OwnerSplitState nvarchar(255);

UPDATE HousingData..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM HousingData..NashvilleHousing

-- Change values Y and N in SoldAsVacant to Yes and No respectively

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM HousingData..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM HousingData..NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

-- Removing Duplicates

WITH RowNumCTE AS(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
ORDER BY UniqueID) row_num
FROM HousingData..NashvilleHousing
)


--DELETE
--FROM RowNumCTE
--WHERE row_num > 1

SELECT row_num 
FROM RowNumCTE
WHERE row_num > 1

-- Delete Unused Columns

SELECT *
FROM HousingData..NashvilleHousing

ALTER TABLE HousingData..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate