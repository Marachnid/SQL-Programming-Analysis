USE project2_games;
SET sql_safe_updates = 0;
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE Genre;

INSERT INTO Genre (Genre)
SELECT DISTINCT (SUBSTRING_INDEX(Genre, ',', 1))
FROM Staging
WHERE Genre IS NOT NULL;

INSERT IGNORE INTO Genre (Genre)
SELECT DISTINCT (
	CASE 
		WHEN CHAR_LENGTH(Genre) - CHAR_LENGTH(REPLACE(Genre, ',', '')) > 0
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Genre, ',', 2), ',', -1))
	END) AS Genre
FROM Staging;


INSERT IGNORE INTO Genre (Genre)
SELECT DISTINCT (
	CASE 
		WHEN CHAR_LENGTH(Publisher) - CHAR_LENGTH(REPLACE(Genre, ',', '')) > 1
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Genre, ',', 3), ',', -1))
	END) AS Genre
FROM Staging;

INSERT IGNORE INTO Genre (Genre)
SELECT DISTINCT (
	CASE 
		WHEN CHAR_LENGTH(Publisher) - CHAR_LENGTH(REPLACE(Genre, ',', '')) > 2
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Genre, ',', 4), ',', -1))
	END) AS Genre
FROM Staging;

INSERT IGNORE INTO Genre (Genre)
SELECT DISTINCT (
	CASE 
		WHEN CHAR_LENGTH(Publisher) - CHAR_LENGTH(REPLACE(Genre, ',', '')) > 3
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Genre, ',', 5), ',', -1))
	END) AS Genre
FROM Staging;

-- some annoying ******* artifacts end up as '' after inserting list items after the first

DELETE FROM Genre
WHERE Genre = '';