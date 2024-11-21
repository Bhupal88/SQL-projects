SELECT * FROM us_project.us_household_income;

SELECT * FROM us_project.us_household_income_statistics;
ALTER TABLE us_project.us_household_income_statistics
RENAME COLUMN `ï»¿id` TO `id`;

SELECT COUNT(id) FROM us_project.us_household_income;
SELECT COUNT(id) FROM us_project.us_household_income_statistics;

SELECT id, COUNT(id)
FROM us_project.us_household_income
GROUP BY id
HAVING COUNT(id)>1;

SELECT * FROM
(SELECT row_id, id,
ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
FROM us_project.us_household_income) duplicates
WHERE row_num>1;

DELETE FROM us_project.us_household_income
WHERE row_id IN (
	SELECT row_id FROM
(SELECT row_id, id,
ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) row_num
FROM us_project.us_household_income) duplicates
WHERE row_num>1
);

SELECT *
FROM us_project.us_household_income_statistics;

UPDATE us_project.us_household_income
SET State_Name='Georgia'
WHERE State_Name='georia';

SELECT DISTINCT(State_Name)
FROM us_project.us_household_income
;
SELECT * FROM us_project.us_household_income
WHERE Place='';

UPDATE us_project.us_household_income
SET Place='Autaugaville'
WHERE County='Autauga County'
and City = 'Vinemont';

SELECT Type, COUNT(Type)
FROM us_project.us_household_income
GROUP BY Type;

UPDATE us_project.us_household_income
SET Type='Borough'
WHERE Type='Boroughs';

SELECT ALand, AWater
FROM us_project.us_household_income
WHERE AWater =0 OR AWater='' OR AWater IS NULL;

SELECT State_Name, SUM(ALand), SUM(AWater)
FROM us_project.us_household_income
GROUP BY State_Name
ORDER BY 2 DESC;

SELECT * FROM 
us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
	on u.id=us.id
WHERE Mean <> 0;

SELECT u.State_Name, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM 
us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
	on u.id=us.id
WHERE Mean <> 0
GROUP BY u.State_Name
ORDER BY 2 DESC
LIMIT 10;

SELECT Type,COUNT(Type), ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM 
us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
	on u.id=us.id
WHERE Mean <> 0
GROUP BY Type
ORDER BY 4 DESC
LIMIT 10;

SELECT u.State_Name, City, ROUND(AVG(Mean),1), ROUND(AVG(Median),1)
FROM 
us_project.us_household_income u
JOIN us_project.us_household_income_statistics us
	on u.id=us.id
WHERE Mean <> 0
GROUP BY u.State_Name, City
ORDER BY 3 DESC
LIMIT 20;
