USE project2_games;
SET sql_safe_updates = 0;
SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE Publisher;

INSERT INTO Publisher (PublisherName)
SELECT DISTINCT (SUBSTRING_INDEX(Publisher, ',', 1))
FROM Staging
WHERE Publisher IS NOT NULL;

INSERT IGNORE INTO Publisher (PublisherName)
SELECT DISTINCT (
	CASE 
		WHEN CHAR_LENGTH(Publisher) - CHAR_LENGTH(REPLACE(Publisher, ',', '')) > 0
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Publisher, ',', 2), ',', -1))
	END) AS Publisher
FROM Staging;


INSERT IGNORE INTO Publisher (PublisherName)
SELECT DISTINCT (
	CASE 
		WHEN CHAR_LENGTH(Publisher) - CHAR_LENGTH(REPLACE(Publisher, ',', '')) > 1
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(Publisher, ',', 3), ',', -1))
	END) AS Publisher
FROM Staging;

-- some annoying artifacts end up as '' after inserting 2nd and 3rd list items
-- should be 926 unique publishers (-1 '' entry that keeps coming back (4 of them in total, 3 cut out because of UNIQUE Index)
	-- might create a rule to trim LLC off of Publishers or trim the ',' out of the publisher name
DELETE FROM Publisher
WHERE PublisherName = '';
