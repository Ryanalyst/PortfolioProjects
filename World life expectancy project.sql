# World Life Expectancy Project (Data Cleaning)

SELECT *
FROM world_life_expectancy;

# Identifying duplicates

/* As we're looking at the table, there is no one unique column to each row that we can base our search off of, so we can use
CONCAT to create our own.*/

SELECT country, year, CONCAT(country, Year), COUNT(CONCAT(country, Year))
FROM world_life_expectancy
GROUP BY country, year, CONCAT(country, Year)
HAVING COUNT(CONCAT(country, Year)) > 1;

SELECT *
FROM(
	SELECT  Row_ID,
		CONCAT(country, Year),
        ROW_NUMBER() OVER(PARTITION BY CONCAT(country, Year) ORDER BY CONCAT(country, Year)) as row_num
	FROM world_life_expectancy) as row_table
WHERE row_num > 1;

# Now that we've found the duplicates, we can delete them

DELETE FROM world_life_expectancy
WHERE 
	Row_ID IN (
    SELECT Row_ID
FROM(
	SELECT  Row_ID,
		CONCAT(country, Year),
        ROW_NUMBER() OVER(PARTITION BY CONCAT(country, Year) ORDER BY CONCAT(country, Year)) as row_num
	FROM world_life_expectancy) as row_table
WHERE row_num > 1);

SELECT *
FROM world_life_expectancy;

/* Looking at the data, we can see that there are blanks in the status and life expectancy columns. So we should see
if we can populate those blanks with something if possible*/

SELECT *
FROM world_life_expectancy
WHERE STATUS = '';

/* First let's get the data for countries that aren't blank. We'll see that the only other values that would be in the 
column is either Developing or Developed.*/

SELECT DISTINCT(Status)
FROM world_life_expectancy
WHERE STATUS <> ''
;

# We can then use these values to update the status'  of countries that are listed as Developed or developing in previous years

SELECT DISTINCT(Country)
FROM world_life_expectancy
WHERE status = 'Developing';

/* You would expect the following query to work but it won't. This is because we can't update a table using a subqry by 
using the same table in the from statement of our subqry*/

UPDATE world_life_expectancy 
SET status = 'Developing'
WHERE country IN(
		SELECT DISTINCT(Country)
		FROM world_life_expectancy
		WHERE status = 'Developing');

/* We can get around this by joining to itself and then filter off of the 2nd copy of the same table!*/

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing'
;

# Now let's look at the data again and see if there's any rows that didn't get populated

SELECT *
FROM world_life_expectancy
WHERE STATUS = '';

/* We see that united states of america didnt get populated and that is becasue it is a developed country, so we can do the 
same thing we did in the earlier query about developing, but change it to developed instead*/

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed'
;

SELECT *
FROM world_life_expectancy;

# Now we need to go about populating the Life expectancy column, if possible.

SELECT *
FROM world_life_expectancy
WHERE `Life expectancy` = ''
;

/* The best way to populate the data in this case is to take the average of the year before and after the year that 
contains the blank spaces and put in the average there in it's place. Becasue the life expectancy is slowly going up 
over the years, so it should be mostly accurate to the rest of the data*/


SELECT Country, Year, `Life expectancy`
FROM world_life_expectancy
#WHERE `Life expectancy` = ''
;

/* It's kind of tricky how we need to go about this. We'll need to do a self join 2 times. One to get the data from the
previous year, and one for the following year and then compare it to the year where the Life expectancy is blank.*/

SELECT  t1.Country, t1.Year, t1.`Life expectancy`,
		t2.Country, t2.Year, t2.`Life expectancy`,
        t3.Country, t3.Year, t3.`Life expectancy`
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country 
    AND t1.YEAR = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.country = t3.country 
    AND t1.YEAR = t3.Year + 1
WHERE t1.`Life expectancy` = ''
;

# Now that we have the data we need, we need to obtain the average of the before and after years to populate the blank spaces

SELECT  t1.Country, t1.Year, t1.`Life expectancy`,
		t2.Country, t2.Year, t2.`Life expectancy`,
        t3.Country, t3.Year, t3.`Life expectancy`,
        ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1) # This is the line of code that we can use to get the avg
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country 
    AND t1.YEAR = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.country = t3.country 
    AND t1.YEAR = t3.Year + 1
WHERE t1.`Life expectancy` = ''
;

# Now that we've found the average of the before and after years, we need to update the rows with blank space

UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.country = t2.country 
    AND t1.YEAR = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.country = t3.country 
    AND t1.YEAR = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy` + t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy` = ''
;

# There we go, the two rows that had blanks have now been populated!

SELECT Country, Year, `Life expectancy`
FROM world_life_expectancy
;

SELECT *
FROM world_life_expectancy;

-------------------------------------------------------------------------------------------------------------------

# Exploratory Data Analysis

SELECT *
FROM world_life_expectancy;

/* First let's start with looking at how well each country has done with improving it's life expectancy over the years*/

SELECT country, `Life expectancy`, MIN(`Life expectancy`), MAX(`Life expectancy`)
FROM world_life_expectancy
GROUP BY country
ORDER BY country DESC;

# I'm getting an error code of 1055, because I didn't include the Life expectancy in the group by statement.
# I can fix this with the following code

SET sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));

# Now I'll try the query again

SELECT  country, `Life expectancy`, 
		MIN(`Life expectancy`) as Min_Life_Expectancy, 
        MAX(`Life expectancy`) as Max_Life_Expectancy
FROM world_life_expectancy
GROUP BY country
ORDER BY country DESC;

# After looking through some of the data, there are 0s throughout it which of course do not make sense.

SELECT  country, `Life expectancy`, 
		MIN(`Life expectancy`) as Min_Life_Expectancy, 
        MAX(`Life expectancy`) as Max_Life_Expectancy
FROM world_life_expectancy
GROUP BY country
HAVING `Life expectancy` <> 0 #We'll remove any 0s there are present
ORDER BY country DESC;

# I feel like the next step would be to determine which countries have the highest increase in Life expectancy

SELECT  country, `Life expectancy`, 
		MIN(`Life expectancy`) as Min_Life_Expectancy, 
        MAX(`Life expectancy`) as Max_Life_Expectancy,
        ROUND(MAX(`Life expectancy`) - MIN(`Life expectancy`),1) as increased_Life_expectancy
FROM world_life_expectancy
GROUP BY country
HAVING `Life expectancy` <> 0 
ORDER BY increased_Life_expectancy desc;

# Here we'll be looking at the average life expectancy by year for the whole world

SELECT YEAR, ROUND(AVG(`Life expectancy`),2) as Avg_Life_Expectancy
FROM world_life_expectancy
WHERE `Life expectancy` <> 0 # There were some rows that contained a 0 in this column which would bring down the average
GROUP BY Year				 # Which is why we need to include this in here
ORDER BY Year;

SELECT *
FROM world_life_expectancy;

# I'm also interested in seeing if life expectancy has any correlation to GDP, so let's look into that

SELECT country, ROUND(AVG(`Life expectancy`),1) as Life_Exp, ROUND(AVG(GDP),1) as GDP
FROM world_life_expectancy
GROUP BY country;

# As I'm going through the data, I'm seeing rows in the life_exp and GDP columns that have 0, let's exclude those for now

SELECT country, ROUND(AVG(`Life expectancy`),1) as Life_Exp, ROUND(AVG(GDP),1) as GDP
FROM world_life_expectancy
GROUP BY country
HAVING Life_Exp > 0 AND GDP > 0
ORDER BY GDP DESC;

# A countries GDP does seem to have a positive correlation on the life expectancy

/* We can use Case statements to apply a category to countries with high or low life exp/gdp and filter off those to see 
who has high life exp AND high gdp or mix and match it*/

# Looking at the data, 1500 seems to be around the halfway point if ordering by gdp, so we'll use that as our category indicator
# First we'll use the case statment to get the total amount of countries that make more than the avg gdp in 2022

SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count
FROM world_life_expectancy
WHERE Year = 2022;

# Now we can take our case statement and use it to determine the avg life expectancy of those High income contries

SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
AVG(CASE WHEN GDP >= 1500 THEN `Life Expectancy` ELSE NULL END) High_GDP_Life_Expectancy
FROM world_life_expectancy
WHERE Year = 2022;

# I'm now going to include the number of coutnries that make under the avg and take their life expectancy

SELECT 
SUM(CASE WHEN GDP >= 1500 THEN 1 ELSE 0 END) High_GDP_Count,
AVG(CASE WHEN GDP >= 1500 THEN `Life Expectancy` ELSE NULL END) High_GDP_Life_Expectancy,
SUM(CASE WHEN GDP <= 1500 THEN 1 ELSE 0 END) Low_GDP_Count,
AVG(CASE WHEN GDP <= 1500 THEN `Life Expectancy` ELSE NULL END) Low_GDP_Life_Expectancy
FROM world_life_expectancy
WHERE Year = 2022;

# The above query is showing a high correlation of gdp to life expectancy

SELECT *
FROM world_life_expectancy;

# One other correlation that I'd be interested in seeing is how the life expectancy changes depending on status

SELECT Status, ROUND(AVG(`Life Expectancy`),1) as Avg_Life_Expectancy
FROM world_life_expectancy
GROUP BY Status;

/* We're seeing that the avg life exp of developing countries is at 66.8, while developed countries are at 79.2. Now it's
possible that we're not getting the whole picture just from this. For example, there could only be one developed country and
hundreds of developing countries which of course would bring down the average*/

SELECT Status, COUNT(DISTINCT Country), ROUND(AVG(`Life Expectancy`),1) as Avg_Life_Expectancy
FROM world_life_expectancy
GROUP BY Status;

# We're able to see that there's only 32 developed countries vs 161 developing countries which has a huge impact on the averages

# I'm also curious on if the BMI of a country has any correlation to it's life expectancy

SELECT country, ROUND(AVG(`Life expectancy`),1) as Life_Exp, ROUND(AVG(BMI),1) as BMI
FROM world_life_expectancy
GROUP BY country
HAVING Life_Exp > 0 AND BMI > 0
ORDER BY BMI desc;

# Based on the data, it appears that countries with higher BMI are also countries with higher life expectancy

/* There is a column called Adult mortality, and I want to look at that total deaths that each country had from year to year.
I'll be using a Rolling total to do this*/

SELECT  Country,
Year,
`Life expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) over(PARTITION BY Country ORDER BY Year) as Rolling_Total
FROM world_life_expectancy;

# I'm curious about how this data would look for the United States so I'll filter for that

SELECT  Country,
Year,
`Life expectancy`,
`Adult Mortality`,
SUM(`Adult Mortality`) over(PARTITION BY Country ORDER BY Year) as Rolling_Total
FROM world_life_expectancy
WHERE Country LIKE '%United States%';




