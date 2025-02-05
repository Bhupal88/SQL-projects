SELECT * FROM database1.world_lifeexpectancy;

-- Finding Duplicates
SELECT * FROM(
	SELECT Row_ID, CONCAT(Country, Year), 
    ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
    FROM database1.world_lifeexpectancy) as Row_Table
    WHERE Row_Num > 1;

-- Removing Duplicates
DELETE FROM database1.world_lifeexpectancy
WHERE Row_ID in (
	SELECT Row_ID FROM (
		SELECT Row_ID, CONCAT(Country, Year), 
		ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) as Row_Num
		FROM database1.world_lifeexpectancy) as Row_Table
		WHERE Row_Num > 1
        );

-- Looking for null or blank records on Status column

SELECT DISTINCT(Status) 
FROM database1.world_lifeexpectancy;

SELECT Country, Status
FROM database1.world_lifeexpectancy
WHERE Status = '';

-- Populating the null values
UPDATE database1.world_lifeexpectancy t1
JOIN database1.world_lifeexpectancy t2
ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = '' AND t2.Status <> '' AND t2.Status='Developing';

-- Working with Life Expectancy Column
SELECT Country, Year, `Life Expectancy`
FROM database1.world_lifeexpectancy
WHERE `Life Expectancy` = '';

-- Populating the null values on Life Expectancy column with the average value of the year before & after
SELECT t1.Country, t1.Year, t1.`Life Expectancy`,
t2.Country, t2.Year, t2.`Life Expectancy`,
t3.Country, t3.Year, t3.`Life Expectancy`,
ROUND((t2.`Life Expectancy`+t3.`Life Expectancy`)/2,1)
FROM database1.world_lifeexpectancy t1
JOIN database1.world_lifeexpectancy t2
	ON t1.Country=t2.Country AND t1.Year=t2.Year-1
JOIN database1.world_lifeexpectancy t3
	ON t1.Country=t3.Country AND t1.Year=t3.Year+1
WHERE t1.`Life Expectancy` = '';

UPDATE database1.world_lifeexpectancy t1
JOIN database1.world_lifeexpectancy t2
	ON t1.Country=t2.Country AND t1.Year=t2.Year-1
JOIN database1.world_lifeexpectancy t3
	ON t1.Country=t3.Country AND t1.Year=t3.Year+1
SET t1.`Life Expectancy`=ROUND((t2.`Life Expectancy`+t3.`Life Expectancy`)/2,1)
WHERE t1.`Life Expectancy`='' ;

-- Exploratory data analysis

-- Life Expectancy increase over the years
SELECT Country, MIN(`Life Expectancy`),MAX(`Life Expectancy`),
ROUND(MAX(`Life Expectancy`)-MIN(`Life Expectancy`),1) AS Life_increase_15years
FROM database1.world_lifeexpectancy
GROUP BY Country
HAVING MIN(`Life Expectancy`)<>0 AND MAX(`Life Expectancy`)<>0
ORDER BY Life_increase_15years;

-- Average Life exectancy of each year
SELECT Year, ROUND(AVG(`Life Expectancy`),2)
FROM database1.world_lifeexpectancy
WHERE `Life Expectancy`<>0
GROUP BY Year
ORDER BY Year;

-- Correlation between life expectancy and other columns
SELECT Country, ROUND(AVG(`Life Expectancy`),2) AS life_expectancy,
AVG(GDP) as avg_gdp
FROM database1.world_lifeexpectancy
WHERE `Life Expectancy` <> 0 AND GDP <> 0
GROUP BY Country
ORDER BY avg_gdp;

SELECT 
SUM(CASE WHEN GDP>=1500 THEN 1 ELSE 0 END) High_gdp_count,
AVG(CASE WHEN GDP>=1500 THEN `Life Expectancy` ELSE NULL END) High_gdp_lifeexp,
SUM(CASE WHEN GDP<=1500 THEN 1 ELSE 0 END) Low_gdp_count,
AVG(CASE WHEN GDP<=1500 THEN `Life Expectancy` ELSE NULL END) Low_gdp_lifeexp
FROM database1.world_lifeexpectancy;

-- Correlation with Status column
SELECT Status, COUNT(DISTINCT Country), ROUND(AVG(`Life Expectancy`),2)
FROM database1.world_lifeexpectancy
GROUP BY Status;

-- Correlation with BMI column
SELECT Country, ROUND(AVG(`Life Expectancy`),2) AS life_exp, ROUND(AVG(BMI),1) AS avg_bmi
FROM database1.world_lifeexpectancy
GROUP BY Country
HAVING life_exp>0 AND avg_bmi>0
ORDER BY avg_bmi DESC;

-- Correlation with Adult Mortality column
SELECT Country, Year, `Life Expectancy`, `Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) as Rolling_Total
FROM database1.world_lifeexpectancy;