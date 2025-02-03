SELECT * FROM 
bakery.us_household_income;

SELECT * FROM 
bakery.us_household_income_cleaned;

DELIMITER $$
DROP PROCEDURE IF EXISTS Copy_and_Clean_Data;
CREATE PROCEDURE Copy_and_Clean_Data()
BEGIN
	CREATE TABLE `us_household_income_cleaned` (
	  `row_id` int DEFAULT NULL,
	  `id` int DEFAULT NULL,
	  `State_Code` int DEFAULT NULL,
	  `State_Name` text,
	  `State_ab` text,
	  `County` text,
	  `City` text,
	  `Place` text,
	  `Type` text,
	  `Primary` text,
	  `Zip_Code` int DEFAULT NULL,
	  `Area_Code` int DEFAULT NULL,
	  `ALand` int DEFAULT NULL,
	  `AWater` int DEFAULT NULL,
	  `Lat` double DEFAULT NULL,
	  `Lon` double DEFAULT NULL,
	  `TimeStamp` TIMESTAMP DEFAULT NULL
	) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

	INSERT INTO us_household_income_cleaned
    SELECT *, CURRENT_TIMESTAMP
    FROM bakery.us_household_income;
    
    -- Removing duplicates
	DELETE FROM bakery.us_household_income_cleaned
	WHERE
		row_id IN(
		SELECT row_id
	FROM (
		SELECT 	row_id, id, 
		ROW_NUMBER() OVER (PARTITION BY id, `TimeStamp` ORDER BY id, `TimeStamp`) AS row_num
		FROM
			bakery.us_household_income_cleaned
	) duplicates
	WHERE row_num > 1
	);

	-- Standardization
	UPDATE bakery.us_household_income_cleaned
	SET State_Name = 'Georgia'
	WHERE State_Name = 'GEORIA';

	UPDATE bakery.us_household_income_cleaned
	SET County = UPPER(County);

	UPDATE bakery.us_household_income_cleaned
	SET City = UPPER(City);

	UPDATE bakery.us_household_income_cleaned
	SET Place = UPPER(Place);

	UPDATE bakery.us_household_income_cleaned
	SET State_Name = UPPER(State_Name);

	UPDATE bakery.us_household_income_cleaned
	SET `Type` = 'CDP'
	WHERE `Type` = 'CPD';

	UPDATE bakery.us_household_income_cleaned
	SET `Type` = 'Borough'
	WHERE `Type` = 'Boroughs';    
    
END $$
DELIMITER ;

CALL Copy_and_Clean_Data();

-- DEBUGGING
SELECT row_id, id, row_num
FROM (
	SELECT row_id, id, ROW_NUMBER() OVER(PARTITION BY id ORDER BY id) AS row_num
    FROM 
    bakery.us_household_income_cleaned
    ) duplicates
    WHERE row_num > 1;
    
SELECT COUNT(row_id) FROM bakery.us_household_income_cleaned;

SELECT State_Name, COUNT(State_Name) FROM 
bakery.us_household_income_cleaned
GROUP BY State_Name;

-- CREATE EVENT
DROP EVENT run_data_cleaning;
CREATE EVENT run_data_cleaning
	ON SCHEDULE EVERY 2 minute
    DO CALL Copy_and_Clean_Data();