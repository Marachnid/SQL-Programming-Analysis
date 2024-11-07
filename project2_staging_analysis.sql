USE project2_games;

-- STEP 3.1
SELECT COUNT(Title) FROM Staging; 
-- count = 1906 (not including initial column header row)



-- STEP 3.2
SELECT DISTINCT Genre 
FROM Staging;
-- Action, Adventure, Indie, Strategy, Simulation, Sports, Massively Multiplayer, RPG, Racing, Casual
-- Gore, Violent, Design & Illustration, Web Publishing, Animation & Modeling, Video Production
-- 215 "unique" genre instances
-- will find individual instance count once delimited



-- STEP 3.3
-- not quite as sure how to handle this:
	-- some titles are repeated, Ironsight has 2 occurences (only case I could find)
    -- BUT some titles have NULL publishers and I don't think that would make sense to be included as a unique identifier
    -- if a title is repeated AND has a NULL publisher, it could cause problems
    -- other fields could be used to differentiate BUT there's a chance they would eventually hit the same problems above
		-- Owners/PositiveReviews/NegativeReviews are the only other NON-NULL values to combine Title with but feel wrong/too generic and could end up matching eventually
			-- if 2 titles match AND BOTH: publishers = null, owners = duplicate range, positive/negative reviews = duplicate
-- TL/DR, this works for this dataset but wouldn't in other scenarios
SELECT Title, Publisher, COUNT(*) AS `Row-Count`
FROM Staging
GROUP BY Title, Publisher
HAVING `Row-Count` > 1;
-- 0 rows returned

-- testing other combinations
SELECT Title, Owners, COUNT(*) AS `Row-Count`
FROM Staging
GROUP BY Title, Owners
HAVING `Row-Count` > 1;
-- 0 rows returned

SELECT Title, PositiveReviews, COUNT(*) AS `Row-Count`
FROM Staging
GROUP BY Title, PositiveReviews
HAVING `Row-Count` > 1;
-- 0 rows returned

SELECT Title, NegativeReviews, COUNT(*) AS `Row-Count`
FROM Staging
GROUP BY Title, NegativeReviews
HAVING `Row-Count` > 1;
-- 0 rows returned

-- testing for duplicates with just Title
SELECT Title, COUNT(*) AS `Row-Count`
FROM Staging
GROUP BY Title
HAVING `Row-Count` > 1;
-- Ironsight = 2



-- STEP 3.4
-- queries with counts are modified to see what that data looks like
SELECT COUNT(Title)
FROM Staging
WHERE Title LIKE NULL OR Title LIKE '';
-- 0 null/blank values

SELECT COUNT(Publisher), Publisher, Title
FROM Staging
WHERE Publisher LIKE NULL OR Publisher LIKE ''
GROUP BY Publisher, Title;
-- 4 null/blank values

SELECT COUNT(Genre), Title, Publisher
FROM Staging
WHERE Genre LIKE NULL OR Genre LIKE ''
GROUP BY Title, Publisher;
-- 4 null/blank values

SELECT COUNT(Owners)
FROM Staging
WHERE Owners LIKE NULL OR Owners LIKE '';
-- 0 null/blank values

SELECT COUNT(PositiveReviews)
FROM Staging
WHERE PositiveReviews LIKE NULL OR PositiveReviews LIKE '';
-- 0 null/blank values

SELECT COUNT(NegativeReviews)
FROM Staging
WHERE NegativeReviews LIKE NULL OR NegativeReviews LIKE '';
-- 0 null/blank values

SELECT COUNT(ReleaseDate), Title, Publisher
FROM Staging
WHERE ReleaseDate LIKE NULL OR ReleaseDate LIKE ''
GROUP BY Title, Publisher;
-- 17 null/blank values

SELECT COUNT(Website)
FROM Staging
WHERE Website LIKE NULL OR Website LIKE '';
-- 280 null/blank values



-- STEP 3.5
SELECT MAX(char_length(Genre) - char_length(replace(Genre, ',', '')) + 1) AS `Genre-List`, MAX(char_length(Publisher) - char_length(replace(Publisher, ',', '')) + 1) AS `Publisher-List`
FROM Staging;
-- 5 is the longest Genre list (4 +1)
-- 3 is the longest Publisher list (2 +1)









