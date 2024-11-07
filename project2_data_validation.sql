USE project2_games;

-- There is a slight fault in the data that I haven't quite been able to get right:
	-- some companies have ', Limited' or ', LLC' that trails the Publisher's name and the queries view that as a separate publisher
    -- with how the data is presented, you wouldn't be able to tell as the concatenation mirrors how the staging list already looks
    -- but there are separate Publishers named LLC and Limited in table Publisher.
    -- I've tried adding cases in inserts and updates in data cleanses that would trim the ',' to make the publisher name whole, but have been unsuccesful in doing so

-- Validate data, LEFT OUTER JOINS used for Publisher/Genre where null values exist
SELECT
    Title,
    GROUP_CONCAT(DISTINCT ' ', PublisherName) AS `Publisher`, 	-- weird results in these categories without DISTINCT, they
    GROUP_CONCAT(DISTINCT ' ', GenreName) AS `Genre`,			-- seem to duplicate based on how many genres/publishers per title exist
    `Range`,													-- verified that duplicate entries don't actually exist below
    PositiveReviews,
    NegativeReviews,
    ReleaseDate,
    Website
FROM Game
INNER JOIN OwnerRange USING (RangeId)
LEFT OUTER JOIN (
	Game_Publisher
    INNER JOIN Publisher
		ON (Game_Publisher.PublisherId = Publisher.PublisherId)
) ON (Game.GameId = Game_Publisher.GameId)
LEFT OUTER JOIN (
	Game_Genre
    INNER JOIN Genre
		ON (Game_Genre.GenreId = Genre.GenreId)
) ON (Game.GameId = Game_Genre.GameId)
GROUP BY Game.GameId
ORDER BY Game.GameId ASC -- matches order of CSV file (and staging)
LIMIT 2000;


-- Verify all games are present
-- 1906 counted = Staging count
SELECT COUNT(*) FROM Game;

-- Extra verification that duplicate keys don't exist in Game_Genre
SELECT * FROM Game_Genre
WHERE GameId IN (1, 100, 200, 300, 1111)
ORDER BY GameId;

-- Extra verification that duplicate keys don't exist in Game_Publisher
SELECT * FROM Game_Publisher
WHERE GameId IN (201, 304, 777, 1083, 1900)
ORDER BY GameId;


