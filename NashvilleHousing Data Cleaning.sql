/*CLEANING DATA IN SQL QUERIES*/

Select *
From NashvilleHousing
------------------------------------------------------------------------------------------

--Standardize Data Format

Select *
From NashvilleHousing

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update NashvilleHousing 
SET SaleDateConverted = CONVERT(Date, SaleDate)

Select SaleDateConverted, CONVERT(Date, SaleDate)
From NashvilleHousing

-------------------------------------------------------------------------------------------
-- Populate Property Address data

Select *
From NashvilleHousing
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)

/*The isnull will search for a null value in a.PropAdd and replace it
with the data from b.PropAdd*/

From NashvilleHousing a
JOIN NashvilleHousing b on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------

-- Breaking out Address into individual columns (Address, City, State)

Select PropertyAddress
From NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
From NashvilleHousing


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, 
LEN(PropertyAddress)) AS City
From NashvilleHousing

---------------------------------------------------------------------------------------

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

Update NashvilleHousing 
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

Update NashvilleHousing 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, 
LEN(PropertyAddress))

Select *
From NashvilleHousing


---------------------------------------------------------------------------------------
/*Splitting owner address into address, city, state via Parsename.

Select OwnerAddress
From NashvilleHousing

Select PARSENAME(Replace(OwnerAddress,',', '.'), 3) as Address
, PARSENAME(Replace(OwnerAddress,',', '.'), 2) as City
, PARSENAME(Replace(OwnerAddress,',', '.'), 1) as State
From NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

Update NashvilleHousing 
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',', '.'), 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

Update NashvilleHousing 
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',', '.'), 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

Update NashvilleHousing 
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',', '.'), 1)

---------------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
	CASE when SoldAsVacant = 'Y' THEN 'Yes'
		 when SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
From NashvilleHousing

Update NashvilleHousing SET
SoldAsVacant = CASE when SoldAsVacant = 'Y' THEN 'Yes'
		 when SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
------------------------------------------------------------------------------------------

-- Remove Duplicates

Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueId) as row_num

From NashvilleHousing
Order by row_num desc

WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueId) as row_num

From NashvilleHousing
--Order by ParcelID
)

Select *
From RowNumCTE
Where row_num > 1;

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate

--It's not good practice to delete RAW data, this is typically done with views and temp tables

Select *
From NashvilleHousing
