SELECT * FROM 
us_project.us_household_income;
SELECT * FROM 
us_project.us_household_income_statistics;

-- Checking duplicates
SELECT id, COUNT(id)
FROM us_project.us_household_income
GROUP BY id
HAVING COUNT(id)>1;

-- Checking duplicates using row_num
SELECT * FROM(
	SELECT row_id, id, ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
	FROM us_project.us_household_income) AS duplicates
	WHERE row_num>1;

-- Dropping the duplicates
DELETE FROM us_project.us_household_income
WHERE row_id in (
	SELECT row_id FROM (
		SELECT row_id, id, ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
		FROM us_project.us_household_income) AS duplicates
		WHERE row_num>1);

-- Data issue with State_Name. 
-- State_Name column: Some records show that state name 'Georgia' is spelled as 'Georgina'
UPDATE us_project.us_household_income
SET State_Name = 'Georgia'
WHERE State_Name = 'Georgina';

-- Place column
SELECT * FROM 
us_project.us_household_income
WHERE Place= ' ';

-- Type column
SELECT DISTINCT(Type), COUNT(Type)
FROM
us_project.us_household_income
GROUP BY Type;

	-- some records are spelled 'borough' or 'boroughs' for the same type. 
UPDATE us_project.us_household_income
SET Type = 'Borough'
WHERE Type = 'Boroughs';

-- ALand, AWater columns
	-- Checking for null, ' ' or '0' values
SELECT ALand, AWater
FROM us_project.us_household_income
WHERE (AWater = 0 OR AWater = ' ' OR AWater IS NULL)
AND (ALand = 0 OR ALand = ' ' OR ALand IS NULL);

-- EXPLORATORY DATA ANALYSIS
SELECT State_Name, County, City, AWater, ALand
FROM us_project.us_household_income;

-- Top 10 Highest States in terms of land mass and water mass.
SELECT State_Name, SUM(AWater), SUM(ALand)
FROM us_project.us_household_income
GROUP BY State_Name
ORDER BY 2 DESC;

-- joining tables together on 'id'
SELECT * FROM 
us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
ON u.id = us.id
WHERE Mean<>0;

-- selecting relevant columns
SELECT u.State_Name, County, `Type`, `Primary`, Mean, Median
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	ON u.id = us.id 
WHERE Mean<>0;

-- Working with state_name, mean & median columns
SELECT u.State_Name, ROUND(AVG(Mean),2) , ROUND(AVG(Median),2)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	ON u.id = us.id 
WHERE Mean<>0
GROUP BY u.State_Name
ORDER BY 2 DESC;

-- Working with Type, mean & median columns
SELECT Type, ROUND(AVG(Mean),2), ROUND(AVG(Median),2), COUNT(Type)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	ON u.id = us.id 
WHERE Mean<>0
GROUP BY Type
ORDER BY 2 DESC;

-- Working with State_name, City, mean &  median columns
SELECT u.State_Name, City, ROUND(AVG(Mean),2), ROUND(AVG(Median),2)
FROM us_project.us_household_income u
INNER JOIN us_project.us_household_income_statistics us
	ON u.id = us.id 
WHERE Mean<>0
GROUP BY u.State_Name, City
ORDER BY 3 DESC;
