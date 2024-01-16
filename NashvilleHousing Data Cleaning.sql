/*This project will showcase the various ways to clean data using SQL

We'll start by selecting the whole table and look 
for any changes that need to be made*/

SELECT *
FROM Nashville_Housing
     
/*Right off the bat, we can see that the SaleDate column is including the 
hours minutes and seconds which is honestly not needed in this situation, so we 
can start by changing the data type to Date.*/

/*We can do this through the use of an alter statement. It will change the data 
type from a DateTime type to strictly date. We use alter instead of update because
update is not capable of changing the data type of data.*/

ALTER TABLE Nashville_Housing 
ALTER COLUMN SaleDate DATE;

SELECT *
FROM Nashville_Housing;

------------------------------------------------------------------------------------------
/*Looking through the data, there are quite a few nulls in the 
property address column. The Unique ID appears to be a primary key for
this table, but the Parcel ID seems like it could be connected to each 
house. After ordering by the Parcel ID, we can find duplicates throughout 
the dataset and this is proven true. So what we need to do is populate the 
null data with data found in another row where the two rows share the same
parcel ID. That sounds tricky but it is easier than it sounds.*/

SELECT *
FROM Nashville_Housing
WHERE PropertyAddress IS NULL;

/*This can be done by a self-join based on where the parcel ID is the same,
but the Unique ID is NOT the same. Because we need the rows to not be the
same when we go to populate our data, otherwise the nulls won't get populated.
We can then use ISNULL to create a temporary row where we can populate all of
the rows that are null with another column that we choose. For this instance,
we will choose the 2nd property address column from our self-join. We're doing 
this because the address will be the same as long as the parcelID is the same,
we can populate the data based on the address column from our 2nd table.*/

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
		ISNULL(a.PropertyAddress, b.PropertyAddress) PopulatedAddress
FROM Nashville_Housing a
JOIN Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

/* We will now create our update statement to populate the null
data from our table. We'll set the Property Address to our ISNULL
and include the entire join statement in the from statement. One thing
to mention is that when updating using a join, you need to include the 
alias after the update as opposed to the table name.*/

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing a
JOIN Nashville_Housing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;
------------------------------------------------------------------------------------------
/*Using our earlier query, we will now see that there are zero columns
with a null value in the property address column.*/

/*Upon sifting through the data, I came across something that might be
worth changing in the property address column. It contains the address 
and the city. This data would be more usable if it was separated into 
different columns. This would allow us to analyze our data based 
on the city which might be helpful for later querying/visualizations.*/

SELECT PropertyAddress
FROM Nashville_Housing

/*We'll be going about this by using a Substring. The substring searches
in a specific column and then goes until it finds a specific character (using
the charindex function) and then stops once it has found that character. In 
this instance, we'll use a comma since that is how the address and city are 
separated. We use -1 at the end of the charindex that way it goes back one
character space and doesn't include the comma. Now to get the city is a bit 
trickier. We are going to remove the 1 because we don't want to start at the 
beginning, we instead will start at the very first comma in the column, which 
will come after the address. Next, we'll change that -1 to + 1 because we want 
to go one space past the comma so it won't be included. and finally, we specify 
how far to go, so we use LEN to signify that we want to to the end of the column*/

SELECT PropertyAddress,
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1,
	LEN(PropertyAddress)) as city
FROM Nashville_Housing

/*Now that we've got our column broken up the way we want, we can
go about updating our table. But first, we need to create two new
columns to house our data.*/

ALTER TABLE Nashville_Housing
ADD PropertySplitAddress Nvarchar(255);

UPDATE Nashville_Housing
SET PropertySplitAddress = 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE Nashville_Housing
ADD PropertySplitCity Nvarchar(255);

UPDATE Nashville_Housing
SET PropertySplitCity = 
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1,
	   LEN(PropertyAddress));

SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM Nashville_Housing;
------------------------------------------------------------------------------------------
/*There is another address column in this dataset called 
Owner address. We'll be doing the same thing for this column
in that we'll be breaking it into separate components. However,
instead of using substrings, we'll use something called ParseName*/

SELECT OwnerAddress
FROM Nashville_Housing

/*Parsename looks for a period and includes the data between the period 
specified. So if there are 3 periods in the data, and you choose 2 as the 
number, then only the middle string will be returned. One thing to remember
about parsename is that it works backward from what you would expect. Using 1
returns the final string in the column. It's easier to understand by seeing
One last thing is that we need to replace the commas in the column with periods,
otherwise, parsename will not know how to separate the string.*/

SELECT  PARSENAME(REPLACE(OwnerAddress,',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress,',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
FROM Nashville_Housing

/* We're now going to do what we did before with the property address
and create new columns to put our data in.*/

ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress Nvarchar(255);

UPDATE Nashville_Housing
SET OwnerSplitAddress = 
	PARSENAME(REPLACE(OwnerAddress,',', '.'), 3);

ALTER TABLE Nashville_Housing
ADD OwnerSplitCity Nvarchar(255);

UPDATE Nashville_Housing
SET OwnerSplitCity = 
	PARSENAME(REPLACE(OwnerAddress,',', '.'), 2);

ALTER TABLE Nashville_Housing
ADD OwnerSplitState Nvarchar(255);

UPDATE Nashville_Housing
SET OwnerSplitState = 
	PARSENAME(REPLACE(OwnerAddress,',', '.'), 1);

SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM Nashville_Housing;
------------------------------------------------------------------------------------------
/*The next section that we need to adjust is the Sold as vacant column.
Upon inspecting it, we can see that the yes's and no's are also sometimes
represented by a y or n. For uniformity's sake, we'll be changing all of the 
y's to Yes and all of the n's to No.*/

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2;

/*We can go about this by using a case statement!*/

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	     WHEN SoldAsVacant = 'N' THEN 'No'
	     ELSE SoldAsVacant 
	END
FROM Nashville_Housing;

/*To update the original column, I include the entire case
statement in the update and that's all there is to it.*/

UPDATE Nashville_Housing SET
SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant 
		 END;
------------------------------------------------------------------------------------------
/*Upon checking the sold as vacant column, we can now see that
the answers are all Yes or No.*/

SELECT DISTINCT(SoldAsVacant)
FROM Nashville_Housing;

/*This last section will be about removing our duplicates
by using window functions and then throwing that into a cte
so that we can further filter it based on whether there are multiple
rows of the same data. We are partitioning by multiple columns 
that realistically wouldn't be shared with two different rows.
We need to partition the data this way because every row has a
uniqueID that is unique to it, despite it being a duplicate row.*/

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
FROM Nashville_Housing)

SELECT *
FROM RowNumCTE
WHERE row_num > 1;

/*Now we need to delete these duplicate rows. To do this, we simply replace
the select * statement with Delete and then rerun the code.*/

WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
FROM Nashville_Housing)

DELETE
FROM RowNumCTE
WHERE row_num > 1;

/*Now we just rerun the previous code with the SELECT * statement and we'll find that
there are no more duplicates.*/


------------------------------------------------------------------------------------------
/*Removing our unneeded columns*/

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress;

--It's not good practice to delete RAW data, this is typically done with views and temp tables

Select *
From NashvilleHousing
