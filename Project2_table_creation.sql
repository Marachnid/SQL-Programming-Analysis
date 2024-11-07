USE project2_games;

-- Drop all tables to recreate after alterations
DROP TABLE IF EXISTS OwnerRange;
DROP TABLE IF EXISTS Game;
DROP TABLE IF EXISTS Genre;
DROP TABLE IF EXISTS Publisher;
DROP TABLE IF EXISTS Game_Genre;
DROP TABLE IF EXISTS Game_Publisher;


-- TABLE CREATION & NAMED FOREIGN KEY ASSIGNMENT
	-- Tables are created with named foreign keys added during creation
	-- Create ordered based on foreign key dependence

-- OwnerRange, ranges of owners
CREATE TABLE OwnerRange (
	RangeID int AUTO_INCREMENT PRIMARY KEY,
    `Range` varchar(30) NOT NULL COMMENT 'kept as a string to represent min/max range clearly in one column'
);

-- Game, main table, one-to-many OwnerRange -> Game, many-to-many Game/Genre & Game/Publisher
CREATE TABLE Game (
	GameId int AUTO_INCREMENT PRIMARY KEY,
    Title varchar(100) NOT NULL,
    PositiveReviews int NOT NULL,
    NegativeReviews int NOT NULL,
    ReleaseDate date NULL,
    Website varchar(100) NULL,
    RangeId int NOT NULL,
	CONSTRAINT FK_Game_Range FOREIGN KEY (RangeId)
		REFERENCES OwnerRange(RangeId)
);

-- Publisher, some games have many publishers, some games have null publisher(s)
CREATE TABLE Publisher (
	PublisherId int AUTO_INCREMENT PRIMARY KEY,
    PublisherName varchar(50) NOT NULL
);

-- Genre, most games have many genres, some games have null genre(s)
CREATE TABLE Genre (
	GenreId int AUTO_INCREMENT PRIMARY KEY,
    GenreName varchar(30) NOT NULL COMMENT 'there are some pretty long multi-word genre names'
);

-- Game_Publisher, junction between games and publishers if exists
CREATE TABLE Game_Publisher (
	PublisherId int NOT NULL,
    GameId int NOT NULL,
    CONSTRAINT PK_Game_Publisher PRIMARY KEY (PublisherId, GameId),
    CONSTRAINT FK_Game_Publishers FOREIGN KEY (GameId)
		REFERENCES Game(GameId),
	CONSTRAINT FK_Publisher_Publishers FOREIGN KEY (PublisherId)
		REFERENCES Publisher(PublisherId)
);

-- Game_Genre, junction between games and genres if exists
CREATE TABLE Game_Genre (
	GenreId int NOT NULL,
    GameId int NOT NULL,
	CONSTRAINT PK_Game_Genre PRIMARY KEY (GenreId, GameId),
    CONSTRAINT FK_Game_Genres FOREIGN KEY (GameId)
		REFERENCES Game(GameId),
    CONSTRAINT FK_Genre_Genres FOREIGN KEY (GenreId)
		REFERENCES Genre(GenreId)
);


-- INDEX CREATION

-- Game Title
CREATE INDEX Title_IX	-- cannot be unique, some unrelated titles are identical (different publishers)
	ON Game(Title);
    
-- Genre Genre
CREATE UNIQUE INDEX Genre_IX
	ON Genre(GenreName);
    
-- OwnerRange Range
CREATE UNIQUE INDEX Range_IX
	ON OwnerRange(`Range`);
    
-- Publisher PublisherName
CREATE UNIQUE INDEX PublisherName_IX
	ON Publisher(PublisherName);
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  