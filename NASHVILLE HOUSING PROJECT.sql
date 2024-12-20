SELECT * 
FROM PortfolioProject.. NashvilleHousing


-- DATA CLEANING AGENDA 
 
 -- POPULATE PROPERTY ADDRESS DATA
 -- BREAKING OUT ADRESS INTO INDIVIDUAL COLUMNS(ADRESS, CITY, STATE)
 -- CHANGE 1 AND 0 INTO YES OR NO
 -- REMOVING DUPLICATES
 -- DELETING UNUSED COLUMNS




  -- POPULATE PROPERTY ADDRESS DATA
 
SELECT *
FROM PortfolioProject.. NashvilleHousing
WHERE PropertyAddress IS NULL 
ORDER BY ParcelID

SELECT NH1.UniqueID, NH1.ParcelID, NH1.PropertyAddress,NH2.UniqueID, NH2.ParcelID, NH2.PropertyAddress, ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)
FROM PortfolioProject.. NashvilleHousing  NH1
JOIN PortfolioProject.. NashvilleHousing NH2
	ON NH1.ParcelID = NH2.ParcelID
	AND NH1.UniqueID <> NH2.UniqueID
	WHERE NH1.PropertyAddress IS NULL 
	
UPDATE NH1
SET PropertyAddress = ISNULL(NH1.PropertyAddress, NH2.PropertyAddress)
FROM PortfolioProject.. NashvilleHousing  NH1
JOIN PortfolioProject.. NashvilleHousing NH2
	ON NH1.ParcelID = NH2.ParcelID
	AND NH1.UniqueID <> NH2.UniqueID
	WHERE NH1.PropertyAddress IS NULL


-- BREAKING OUT PROPERTY ADDRESS INTO INDIVIDUAL COLUMNS(ADRESS, CITY, STATE)
SELECT PropertyAddress,
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
FROM PortfolioProject.. NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))


-- BREAKING OUT OWNER ADDRESS INTO INDIVIDUAL COLUMNS(ADRESS, CITY, STATE)
SELECT OwnerAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM PortfolioProject.. NashvilleHousing



ALTER TABLE PortfolioProject.. NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE PortfolioProject.. NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE PortfolioProject.. NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE PortfolioProject.. NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)
 
 
ALTER TABLE PortfolioProject.. NashvilleHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE PortfolioProject.. NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)
 
 
 

 -- CHANGE 1 AND 0 INTO YES OR NO

 SELECT SoldAsVacant,
 CASE 
	WHEN SoldAsVacant = 1 THEN 'Yes'
	ELSE 'No'
    --ELSE SoldAsVacant
END AS SoldAsVacant2
FROM PortfolioProject.. NashvilleHousing

ALTER TABLE PortfolioProject.. NashvilleHousing
ADD SoldAsVacant2 Nvarchar(255)


UPDATE PortfolioProject.. NashvilleHousing
SET SoldAsVacant2 =  CASE 
	WHEN SoldAsVacant = 1 THEN 'Yes'
	ELSE 'No'
    --ELSE SoldAsVacant
END




 -- REMOVING DUPLICATES WHERE UNIQUEID IS NOT THE CRITERIA FOR NON DUPLICATES
 SELECT *
 FROM PortfolioProject.. NashvilleHousing

WITH CTE AS (
SELECT *,
	ROW_NUMBER()OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
	 FROM PortfolioProject.. NashvilleHousing
	 )
SELECT *
	 FROM CTE
WHERE row_num > 1

--DELETE UNUSED COLUMNS

SELECT *
FROM PortfolioProject.. NashvilleHousing


ALTER TABLE PortfolioProject.. NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, PropertyCity, 

ALTER TABLE PortfolioProject.. NashvilleHousing
DROP COLUMN SoldAsVacant
