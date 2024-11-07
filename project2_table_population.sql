USE project2_games;

-- Disable safety/foreign checks for table data alterations/population
SET sql_safe_updates = 0;
SET FOREIGN_KEY_CHECKS = 0;

-- Remove existing table data for repeated procedures
TRUNCATE TABLE OwnerRange;
TRUNCATE TABLE Game;
TRUNCATE TABLE Genre;
TRUNCATE TABLE Publisher;
TRUNCATE TABLE Game_Genre;
TRUNCATE TABLE Game_Publisher;


-- COMMENCE CLEANSE OF THY STAGING DATA IN THOU'S HOLY QUERIES AND POPULATE THEE LANDS OF PROJECT2_GAMES

-- UPDATE BLANK VALUES TO NULL
-- Publisher NULL values
-- 4 EXPECTED altered null/blank values (5 actual, it turns out)
UPDATE Staging
SET Publisher = NULL
WHERE Publisher = '' 
	OR Publisher = ' ' 					-- ' ' don't exist but added for assurance
	OR Publisher = '(none)'; 			-- '(none)' was a one-off tag I found used by Steam to denote no publisher, only used twice in all of Steam

-- Genre NULL values
-- 4 EXPECTED altered null/blank values
UPDATE Staging
SET Genre = NULL
WHERE Genre = '' OR Genre = ' ';

-- ReleaseDate NULL values
-- 17 EXPECTED altered null/blank values
UPDATE Staging
SET ReleaseDate = NULL
WHERE ReleaseDate = '' OR ReleaseDate = ' ';

-- Website NULL values
-- 280 EXPECTED altered null/blank values
UPDATE Staging
SET Website = NULL
WHERE Website = '' OR Website = ' ';

-- PROTOTYPED SOLUTION
	-- Some Publishers have a trailing ', LLC' or ', LIMITED' after their name, the query below is an attempt to solve that problem by trimming/inserting them
    -- as their own PublisherName with the LLC/LIMITED included, but ended up causing a lot of complications and couldn't quite get it to work right without a lot of static modifications that felt like it ruined maintainability
		-- there could also be PublisherNames that have a ',' separating a joint name for whatever reason (like 'Example X, Productions') that would require specific rules everytime they occur
    -- this query is also assuming it's targeting the second item (not including the ,) in the list where %, LLC (or limited) exists
    -- while the data isn't 100% accurate for PublisherName, the visual representation in validation is identical despite an extra LLC/LIMITED publisher being added where ', LLC(/LIMITED)' exists
    
-- SELECT DISTINCT (
-- 	CASE 
-- 		WHEN CHAR_LENGTH(Publisher) - CHAR_LENGTH(REPLACE(Publisher, ',', '')) > 0 AND CHAR_LENGTH(Publisher) - CHAR_LENGTH(REPLACE(Publisher, ',', '')) < 2
--         THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Publisher, ',', 2), ',', -2))
-- 	END) AS Publisher
-- FROM Staging
-- WHERE Publisher LIKE '%, LIMITED%' OR Publisher LIKE '%, llc%';
-- ;


-- TABLE DATA POPULATION

-- MAIN TABLES
-- POPULATE OwnerRange
INSERT INTO OwnerRange (`Range`)
SELECT DISTINCT Owners
FROM Staging;

-- POPULATE Game
INSERT INTO Game (
	Title,
    PositiveReviews,
    NegativeReviews,
    ReleaseDate,
    Website,
    RangeId
)
SELECT 
	Title,
    PositiveReviews,
    NegativeReviews,
    STR_TO_DATE(ReleaseDate, '%m/%d/%Y'),
    Website,
    RangeId
FROM Staging
INNER JOIN OwnerRange 
	ON (Staging.Owners = OwnerRange.`Range`);   

-- POPULATE Publisher from staging string list
-- First publisher
INSERT INTO Publisher (PublisherName)
SELECT DISTINCT (SUBSTRING_INDEX(Publisher, ',', 1))
FROM Staging
WHERE Publisher IS NOT NULL;

-- Second Publisher
INSERT IGNORE INTO Publisher (PublisherName)
SELECT DISTINCT (
	CASE 
		WHEN CHAR_LENGTH(Publisher) - CHAR_LENGTH(REPLACE(Publisher, ',', '')) > 0
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Publisher, ',', 2), ',', -1))
	END) AS Publisher
FROM Staging;

-- Third publisher
INSERT IGNORE INTO Publisher (PublisherName)
SELECT DISTINCT (
	CASE 
		WHEN CHAR_LENGTH(Publisher) - CHAR_LENGTH(REPLACE(Publisher, ',', '')) > 1
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Publisher, ',', 3), ',', -1))
	END) AS Publisher
FROM Staging;

-- POPULATE Genre from Staging string list
-- First Genre
INSERT INTO Genre (GenreName)
SELECT DISTINCT (SUBSTRING_INDEX(Genre, ',', 1))
FROM Staging
WHERE Genre IS NOT NULL;

-- Second Genre
INSERT IGNORE INTO Genre (GenreName)
SELECT DISTINCT (
	CASE 
		WHEN CHAR_LENGTH(Genre) - CHAR_LENGTH(REPLACE(Genre, ',', '')) > 0
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Genre, ',', 2), ',', -1))
	END) AS GenreName
FROM Staging;

-- Third Genre
INSERT IGNORE INTO Genre (GenreName)
SELECT DISTINCT (
	CASE 
		WHEN CHAR_LENGTH(Genre) - CHAR_LENGTH(REPLACE(Genre, ',', '')) > 1
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Genre, ',', 3), ',', -1))
	END) AS GenreName
FROM Staging;

-- Fourth Genre
INSERT IGNORE INTO Genre (GenreName)
SELECT DISTINCT (
	CASE 
		WHEN CHAR_LENGTH(Genre) - CHAR_LENGTH(REPLACE(Genre, ',', '')) > 2
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Genre, ',', 4), ',', -1))
	END) AS GenreName
FROM Staging;

-- Fifth Genre
INSERT IGNORE INTO Genre (GenreName)
SELECT DISTINCT (
	CASE 
		WHEN CHAR_LENGTH(Genre) - CHAR_LENGTH(REPLACE(Genre, ',', '')) > 3
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Genre, ',', 5), ',', -1))
	END) AS GenreName
FROM Staging; 

-- CLEANSE '' artifacts from Publisher's/Genre's added after first round inserts (on 2nd, 3rd+...), not sure why
-- Unique Indexes limited these to only one each per Publisher and Genre
DELETE FROM Publisher
WHERE PublisherName = '';

DELETE FROM Genre
WHERE GenreName = '';
  
  
-- POPULATE JUNCTION TABLES

-- POPULATE/CONNECT Game_Publisher via Staging string list
-- First Publisher
INSERT IGNORE INTO Game_Publisher (PublisherId, GameId)
SELECT PublisherId, GameId
FROM Staging
INNER JOIN Publisher ON PublisherName 
	IN (
		SELECT DISTINCT SUBSTRING_INDEX(Publisher, ',', 1)
	)
INNER JOIN Game ON Game.Title = Staging.Title;

-- Second Publisher
INSERT IGNORE INTO Game_Publisher (PublisherId, GameId)
SELECT PublisherId, GameId
FROM Staging
INNER JOIN Publisher ON PublisherName 
	IN (
		SELECT DISTINCT (
			CASE 
				WHEN CHAR_LENGTH(Publisher) - CHAR_LENGTH(REPLACE(Publisher, ',', '')) > 0
				THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Publisher, ',', 2), ',', -1))
			END) AS Publisher
	)
INNER JOIN Game ON Game.Title = Staging.Title;

-- Third Publisher
INSERT IGNORE INTO Game_Publisher (PublisherId, GameId)
SELECT PublisherId, GameId
FROM Staging
INNER JOIN Publisher ON PublisherName 
	IN (
		SELECT DISTINCT (
			CASE 
				WHEN CHAR_LENGTH(Publisher) - CHAR_LENGTH(REPLACE(Publisher, ',', '')) > 1
				THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Publisher, ',', 3), ',', -1))
			END) AS Publisher
	)
INNER JOIN Game ON Game.Title = Staging.Title;


-- POPULATE/CONNECT Game_Genre via Staging string list
-- First Genre
INSERT IGNORE INTO Game_Genre (GenreId, GameId) -- need to include ignore, two titles with same genre exist
SELECT GenreId, GameId
FROM Staging
INNER JOIN Genre ON GenreName 
	IN (
		SELECT DISTINCT SUBSTRING_INDEX(Genre, ',', 1)
	)
INNER JOIN Game ON Game.Title = Staging.Title;

-- Second Genre
INSERT IGNORE INTO Game_Genre (GenreId, GameId)
SELECT GenreId, GameId
FROM Staging
INNER JOIN Genre ON GenreName 
	IN (
		SELECT DISTINCT(
			CASE 
				WHEN CHAR_LENGTH(Genre) - CHAR_LENGTH(REPLACE(Genre, ',', '')) > 0
				THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Genre, ',', 2), ',', -1))
			END) AS GenreName
	)
INNER JOIN Game ON Game.Title = Staging.Title;

-- Third Genre
INSERT IGNORE INTO Game_Genre (GenreId, GameId)
SELECT GenreId, GameId
FROM Staging
INNER JOIN Genre ON GenreName 
	IN (
		SELECT DISTINCT (
			CASE 
				WHEN CHAR_LENGTH(Genre) - CHAR_LENGTH(REPLACE(Genre, ',', '')) > 1
				THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Genre, ',', 3), ',', -1))
			END) AS GenreName
	)
INNER JOIN Game ON Game.Title = Staging.Title;

-- Fourth Genre
INSERT IGNORE INTO Game_Genre (GenreId, GameId)
SELECT GenreId, GameId
FROM Staging
INNER JOIN Genre ON GenreName 
	IN (
		SELECT DISTINCT (
			CASE 
				WHEN CHAR_LENGTH(Genre) - CHAR_LENGTH(REPLACE(Genre, ',', '')) > 2
				THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Genre, ',', 4), ',', -1))
			END) AS GenreName
	)
INNER JOIN Game ON Game.Title = Staging.Title;

-- Fifth Genre
INSERT IGNORE INTO Game_Genre (GenreId, GameId)
SELECT GenreId, GameId
FROM Staging
INNER JOIN Genre ON GenreName 
	IN (
		SELECT DISTINCT (
			CASE 
				WHEN CHAR_LENGTH(Genre) - CHAR_LENGTH(REPLACE(Genre, ',', '')) > 3
				THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Genre, ',', 5), ',', -1))
			END) AS GenreName
	)
INNER JOIN Game ON Game.Title = Staging.Title;