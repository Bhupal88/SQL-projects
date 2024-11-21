SELECT * 
FROM database1.world_lifeexpectancy;

SELECT Country, Year, CONCAT(Country, Year), COUNT(CONCAT(Country, Year))
FROM world_lifeexpectancy
GROUP BY Country, Year, CONCAT(Country, Year)
HAVING COUNT(CONCAT(Country, Year))>1;

SELECT *
FROM(
	SELECT Row_ID, 
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_lifeexpectancy
	) AS Row_Table
    WHERE Row_Num>1
    ;

DELETE FROM world_lifeexpectancy
WHERE Row_ID in (
	SELECT Row_ID
FROM(
	SELECT Row_ID, 
	CONCAT(Country, Year),
	ROW_NUMBER() OVER(PARTITION BY CONCAT(Country, Year) ORDER BY CONCAT(Country, Year)) AS Row_Num
	FROM world_lifeexpectancy
	) AS Row_Table
    WHERE Row_Num>1
);
SELECT * 
FROM database1.world_lifeexpectancy
WHERE Status='';

SELECT Country, Status 
FROM database1.world_lifeexpectancy
WHERE Status='';

SELECT DISTINCT(Status)
FROM world_lifeexpectancy;

UPDATE world_lifeexpectancy t1
JOIN world_lifeexpectancy t2
	ON t1.Country=t2.Country
SET t1.Status='Developing'
WHERE t1.Status=''
AND t2.Status<>''
AND t2.Status='Developing'
;

UPDATE world_lifeexpectancy t1
JOIN world_lifeexpectancy t2
	ON t1.Country=t2.Country
SET t1.Status='Developed'
WHERE t1.Status=''
AND t2.Status<>''
AND t2.Status='Developed'
;

SELECT * 
FROM database1.world_lifeexpectancy
WHERE `Life expectancy` = ''
;

SELECT t1.Country, t1.Year, t1.`Life expectancy`,
t2.Country, t2.Year, t2.`Life expectancy`,
t3.Country, t3.Year, t3.`Life expectancy`,
ROUND((t2.`Life expectancy`+t3.`Life expectancy`)/2,1)
FROM world_lifeexpectancy t1
JOIN world_lifeexpectancy t2
	ON t1.Country=t2.Country
    AND t1.Year=t2.Year+1
JOIN world_lifeexpectancy t3
	ON t1.Country=t3.Country
    AND t1.Year=t3.Year-1
WHERE t1.`Life expectancy`=''
;

UPDATE world_lifeexpectancy t1
JOIN world_lifeexpectancy t2
ON t1.Country=t2.Country
    AND t1.Year=t2.Year+1
JOIN world_lifeexpectancy t3
	ON t1.Country=t3.Country
    AND t1.Year=t3.Year-1
SET t1.`Life expectancy`=ROUND((t2.`Life expectancy`+t3.`Life expectancy`)/2,1)
WHERE t1.`Life expectancy`=''
;

SELECT Country, Min(`Life expectancy`),max(`Life expectancy`),
ROUND(max(`Life expectancy`)-min(`Life expectancy`),2) as Life_Increase_15_Years
FROM world_lifeexpectancy
GROUP BY Country
HAVING min(`Life expectancy`)<>0
AND max(`Life expectancy`)<>0
ORDER BY Life_Increase_15_Years DESC
;
SELECT Year, ROUND(AVG(`Life expectancy`),2) AS Avg_life_expectancy
FROM world_lifeexpectancy
WHERE `Life expectancy`<>0
GROUP BY Year
ORDER BY Year;

SELECT Status, ROUND(AVG(`Life expectancy`),1) AS avg_life, COUNT(DISTINCT Country)
FROM world_lifeexpectancy
GROUP BY Status;

SELECT Country, Year, `Life expectancy`, `Adult Mortality`,
SUM(`Adult Mortality`) OVER(PARTITION BY Country ORDER BY Year) Rolling_Total
FROM world_lifeexpectancy
WHERE Country LIKE 'Nep%us_household_income';