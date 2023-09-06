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

/*The above query allows us to see which data contains a null for their
address. We then can join the table with itself and then search for data
that shares a parcel id, but not a unique ID. We do this because, rows 
that share a ParcelID but not a unique ID are very likely to share the
same address. So we can then update the data where the address is null
with the addresses we found using the above query.*/

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

/* The above code will return the Property address value up until it 
discovers a comma. This is thanks to the CHARINDEX command which searches
for the character in quotations.Then the -1 will delete the comma for us*/


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

In SQL Server, you can use the PARSENAME() function to return part of
an object name. For example, you can use it to return the schema part
(or any other part) of a four part name such as server.schema.db.object.
We can also use it to return specific parts of the owner address column!
Normally the command will return values until it finds a period.
Since each section in the address column is seperated by a comma, we can 
use the REPLACE command within the parsename command itself to instead look
for a comma and return all of the values up till that comma :D For example:

Select 
PARSENAME('object_name' , object_piece(this has to be a 1,2,3, or 4) )
From table_name

Doing that will return specific pieces in our address column. Additionally,
the values it returns is backwards from what you'd expect. So using 1 for the
object piece will actually return the last set of data in the column. If you
want to return the first set, you need to start with 3, since there are 3
seperate commas in the owner address column.*/


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

--Never Delete data from your raw data that you import. You'll typically do this 
--with views or temp tables

Select *
From NashvilleHousing
