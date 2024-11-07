-- fresh recreation of schema, drops, creates, uses
DROP SCHEMA IF EXISTS project2_games;
CREATE SCHEMA project2_games;
USE project2_games;

-- temporary staging table
CREATE TABLE Staging(
Title varchar(100),
Publisher varchar(100),
Genre varchar(100),
Owners varchar(100),
PositiveReviews integer,
NegativeReviews integer,
ReleaseDate varchar(100),
Website varchar(100));

SET GLOBAL local_infile = 1;
-- import data for Top Steam Games
LOAD DATA LOCAL INFILE
'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\Top Steam Games(Nov2022).csv'
INTO TABLE Staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '\"'
ESCAPED BY '\\'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;