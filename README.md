# SQL-Programming-Analysis

This is a backup for Project 2 of my Database Programming class

The project contains a number of Stored Procedures to initiate the project environment (schema, tables, relationships, etc.), load raw data into a staging table, cleanse data, and finally analyze data. The main bulk of this project was ensuring accurate data retrieval and parsing individual game titles, genres, publishers, and so forth for the Top Steam Games of 2022 (November). The database was then normalized to the design listed in "PROJECT2_GAMES ER Diagram.png". 

My own personal spin was to add a like-to-dislike ratio calculated through SQL. This also includes a column representing the average % difference from the average like-to-dislike ratio shared by all games present. You can see a completed version of my games table in GamesTable.csv (I'd recommend opening it outside of vs code so it displays with an Excel table format)

The order of operations would be:
staging_create
table_creation
table_population
data_validation


These scripts are not necessary - they were used to test data population and validation separate from the rest of the program
Genre_Temp_Population
Publisher_Temp_Population
staging_analysis


**There have been some issues with LOAD DATA LOCAL INFILE that have come up since looking back at the program and switching to a root account vs. school account. I've been trying to resolve the solution but it's a bit of a mess with access restrictions and editing configuration files. 