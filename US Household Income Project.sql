# US Household Income Data Cleaning

SELECT * 
FROM us_household_income;

SELECT *
FROM us_household_income_statistics; 

# The first column in income stats has random characters in it from the import, let's fix that first

ALTER TABLE us_household_income_statistics
RENAME COLUMN ï»¿id TO id;

# First things first, we'll want to see if there's any duplicates in the data

SELECT id, COUNT(ID)
FROM us_household_income
GROUP BY id
HAVING COUNT(ID) > 1;

# It appears to indeed have a few duplicates, so we'll need to remove those


SELECT *
FROM (SELECT row_id,
id,
ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) as row_num
FROM us_household_income) as duplicates
WHERE row_num >1;

# Now that we've got our duplicates, we can plug that query into a delete statement to remove them

DELETE FROM us_household_income
WHERE row_id IN(
	SELECT row_id
	FROM (SELECT 	row_id,
					id,
					ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) as row_num
	FROM us_household_income) as duplicates
	WHERE row_num >1);

# Next we'll do the same thing, but for our other table

SELECT id, COUNT(ID)
FROM us_household_income_statistics
GROUP BY id
HAVING COUNT(ID) > 1;

# Thankfully we do not have any duplicates in the other table!
/* Looking through the state name column in our us house income table, we can see that one of the Alabama's is lowecase
We'll try to standardize the state name column.*/


SELECT State_Name, COUNT(State_Name)
FROM us_household_income
GROUP BY State_Name;

/* After looking through the various states, the lowercase alabama is being added into the rest of the alabama's that
are properly capitalized. We'll fix this in a bit, but first we need to fix one of the rows that mispelled Georgia*/

SELECT DISTINCT state_name
FROM us_household_income;

UPDATE us_household_income
SET State_name = 'Georgia'
WHERE State_name = 'georia';

# Now that that one is fixed, let's fix the alabama capitalization

UPDATE us_household_income
SET State_name = 'Alabama'
WHERE State_name = 'alabama';

# Next I wanna quickly double check the abriviations

SELECT DISTINCT state_ab
FROM us_household_income;

# They appear to all be properly capitalized

# I noticed a blank space in the place column near the top of our data so let's search for all blank spaces in the data

SELECT *
FROM us_household_income
WHERE Place = ''
ORDER BY 1;

# Seems like there's only one row with a blank space, so let's search the specific county and figure out what to put

SELECT *
FROM us_household_income
WHERE County = 'Autauga County'
ORDER BY 1;

/*We  can see that Place is the same for 99.9% of our rows that share that county name, so we can reasonably assume
that the blank space should be the same as our other data*/

UPDATE us_household_income
SET Place = 'Autaugaville'
WHERE County = 'Autauga County'
AND City = 'Vinemont';

# Let's check to make sure the row was fixed

SELECT *
FROM us_household_income
WHERE County = 'Autauga County'
AND City = 'Vinemont';

# Next we can continue to look through the other columns for any incorrect data

SELECT Type, COUNT(Type)
FROM us_household_income
GROUP BY Type;

/*Seems like there is a few potential errors, but only one is 100% a mistake. And unless we have incredibly solid proof,
we shouldn't edit the rows that we're not very confident as to whether or not there are issues with them. There is one
Type called CDP and another called CPD. The CDP has 988 counts while CPD is only 2. This is a decent probability of
CDP supposing to be included in CDP but without knowledge of the data and what it represents, I can't say for certain.
Because of this, I will not touch it. However, I can confidently say that the Borough and Boroughs columns should 
belong as one column. The boroughs type only appears once while borough appears 128 times. So we'll change boroughs 
into borough*/

UPDATE us_household_income
SET TYPE = 'Borough'
WHERE type = 'Boroughs';

# Let's see if there's anything else that needs cleaning 

SELECT *
FROM us_household_income;

# A few of the rows in ALand and AWater have 0s in them. 

# Having 0's in ALand could mean that there's just water in that specific area

SELECT ALand, AWater
FROM us_household_income
WHERE ALand IN('', NULL, 0);

# Having 0's in AWater could mean that there's only land in that specific area

SELECT ALand, AWater
FROM us_household_income
WHERE AWater IN('', NULL, 0);

# Upon reviewing the data in the income table, there doesn't appear to be anything apparent that's in need of fixing

------------------------------------------------------------------------------------------------------

# US Household Income Exploratory Data Analysis

SELECT * 
FROM us_household_income;

SELECT *
FROM us_household_income_statistics; 

# I'll first check out the land and water columns and figure out which state has the most land

SELECT State_name, SUM(ALand), SUM(Awater)
FROM us_household_income
GROUP BY State_Name
ORDER BY 2 DESC;

# Now for the state with the most water

SELECT State_name, SUM(ALand), SUM(Awater)
FROM us_household_income
GROUP BY State_Name
ORDER BY 3 DESC;

# I'm going to look for the top 10 largest states according to their land 

SELECT  State_name,
			SUM(ALand) as Land, 
            ROW_NUMBER() OVER(ORDER BY SUM(ALand) desc) as row_num
FROM us_household_income
GROUP BY State_name
ORDER BY 2 desc
LIMIT 10;

# Now we can look at the states with the most amount of water

SELECT  State_name,
			SUM(AWater) as Water, 
            ROW_NUMBER() OVER(ORDER BY SUM(AWater) desc) as row_num
FROM us_household_income
GROUP BY State_name
ORDER BY 2 desc
LIMIT 10;

# I think it's time to start working with the income statistics table now 

SELECT * 
FROM us_household_income hi
INNER JOIN us_household_income_statistics his
	ON hi.id = his.id;

/*Upon looking at the data, we can see that there are 0s for qutie a few rows in the mean median stdev and sum_w columns
For now we'll just filter that out.*/

SELECT * 
FROM us_household_income hi
INNER JOIN us_household_income_statistics his
	ON hi.id = his.id
WHERE Mean <> 0;
    
    
# I think it could be interesting to look at the mean and median columns for various states
    
SELECT hi.State_Name, ROUND(AVG(Mean),1) avg_mean, ROUND(AVG(Median),1) avg_median
FROM us_household_income hi
INNER JOIN us_household_income_statistics his
	ON hi.id = his.id
WHERE Mean <> 0
GROUP BY 1;

# Let's look at the top 5 lowest mean income states

SELECT hi.State_Name, ROUND(AVG(Mean),1) avg_mean, ROUND(AVG(Median),1) avg_median
FROM us_household_income hi
INNER JOIN us_household_income_statistics his
	ON hi.id = his.id
WHERE Mean <> 0
GROUP BY 1
ORDER BY 2 
LIMIT 5;

# I'll also look at the states with the highest avg median income

SELECT hi.State_Name, ROUND(AVG(Mean),1) avg_mean, ROUND(AVG(Median),1) avg_median
FROM us_household_income hi
INNER JOIN us_household_income_statistics his
	ON hi.id = his.id
WHERE Mean <> 0
GROUP BY 1
ORDER BY 3 desc
LIMIT 10;

# We can also look at the avg mean and median incomes for the various types of area

SELECT  Type, 
        ROUND(AVG(Mean),1) avg_mean, 
        ROUND(AVG(Median),1) avg_median
FROM us_household_income hi
INNER JOIN us_household_income_statistics his
	ON hi.id = his.id
WHERE Mean <> 0
GROUP BY Type
ORDER BY 2 DESC
LIMIT 10;

/* We can gather from the above query that Municipality has  a much higher avg mean than the other types. But let's 
get a count of each type to see if that is influencing the data any*/

SELECT  Type, COUNT(Type),
        ROUND(AVG(Mean),1) avg_mean, 
        ROUND(AVG(Median),1) avg_median
FROM us_household_income hi
INNER JOIN us_household_income_statistics his
	ON hi.id = his.id
WHERE Mean <> 0
GROUP BY Type
ORDER BY 3 desc;

# We can see that there is only one municipality, which means that there's less data to lower the average by

# Let's look at the average median now

SELECT  Type, COUNT(Type),
        ROUND(AVG(Mean),1) avg_mean, 
        ROUND(AVG(Median),1) avg_median
FROM us_household_income hi
INNER JOIN us_household_income_statistics his
	ON hi.id = his.id
WHERE Mean <> 0
GROUP BY Type
ORDER BY 4 desc;

# We can see that CDP has a MUCH higher average median than the other types, with track being in 2nd. 

/* I'm curious about the types on the list with the smallest amounts, let's look up the lowest one, which is community
and find out which state that is in*/

SELECT *
FROM us_household_income
WHERE type = 'Community';

# It seems like the state is Puerto Rico which makes sense given the puerto rico has some of the smallest salaries

# Now that we've looked at the salaries at the state level, let's check it out on a city level

SELECT hi.State_Name, City, ROUND(AVG(mean),1) avg_mean
FROM us_household_income hi
INNER JOIN us_household_income_statistics his
	ON hi.id = his.id
GROUP BY hi.State_Name, City
ORDER BY 3 DESC;

# Now let's look at the highest medians 

SELECT hi.State_Name, City, ROUND(AVG(mean),1) avg_mean, ROUND(AVG(median),1) avg_median
FROM us_household_income hi
INNER JOIN us_household_income_statistics his
	ON hi.id = his.id
GROUP BY hi.State_Name, City
ORDER BY 4 DESC;

/* I've noticed something rather interesting from this, it seems like for a LOT of the cities, the avg median is
exactly at 300,000. Perhaps any salary above 300,00 is not being reported accurately and it caps at 300,000.
I'm curious how many of those avg medians have this cap of 300,000 so let's check that out really quick*/



SELECT COUNT(avg_median) as capped_income
FROM (
SELECT hi.State_Name, City, ROUND(AVG(median),1) avg_median
FROM us_household_income hi
INNER JOIN us_household_income_statistics his
	ON hi.id = his.id
GROUP BY hi.State_Name, City
HAVING avg_median = 300000.0
ORDER BY 3 DESC) highest_avg_median;

# Next we can see how many in each state has a capped income of 300,000

SELECT state_name, COUNT(avg_median) as capped_income
FROM (
SELECT hi.State_Name, City, ROUND(AVG(median),1) avg_median
FROM us_household_income hi
INNER JOIN us_household_income_statistics his
	ON hi.id = his.id
GROUP BY hi.State_Name, City
HAVING avg_median = 300000.0
ORDER BY 3 DESC) highest_avg_median
GROUP BY state_name;

# Lastly, I'm wondering what the top 5 states are in capped income

SELECT state_name, COUNT(avg_median) as capped_income
FROM (
	SELECT  hi.State_Name, 
			City, 
            ROUND(AVG(median),1) avg_median
	FROM us_household_income hi
	INNER JOIN us_household_income_statistics his
		ON hi.id = his.id
	GROUP BY hi.State_Name, City
	HAVING avg_median = 300000.0
	ORDER BY 3 DESC) highest_avg_median
GROUP BY state_name
ORDER BY 2 DESC
LIMIT 5;

