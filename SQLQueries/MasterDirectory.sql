/*
SQLite Statements to recreate the database used by Datamaster
*/


--Turn on Foreign Keys for database
PRAGMA foreign_keys = on;

--Create Tables for Database
CREATE TABLE masterDirectory(
	id 				INTEGER 		PRIMARY KEY,
	ldId			TEXT			NOT NULL,
	ldxId			TEXT			NOT NULL,
	OriginHash		TEXT			NOT NULL,
	FinalHash		TEXT			NOT NULL
);

CREATE TABLE DetailLog(
	id 				INTEGER 		PRIMARY KEY,
	entryId			INTEGER 		NOT NULL,
	fieldId			INTEGER 		NOT NULL,
	value			BLOB	 		NOT NULL,
	unit			TEXT,
	FOREIGN KEY(fieldId) REFERENCES DetailName(id)
	FOREIGN KEY(entryId) REFERENCES MasterDirectory(id)
);

CREATE TABLE DetailName(
	id 				INTEGER 		PRIMARY KEY,
	fieldName 		TEXT			NOT NULL
);

CREATE TABLE ChannelLog(
	id 				INTEGER 		PRIMARY KEY,
	entryId			INTEGER 		NOT NULL,
	channelId		INTEGER 		NOT NULL,
	FOREIGN KEY(entryId) REFERENCES MasterDirectory(id)
	FOREIGN KEY(channelId) REFERENCES ChannelName(id)
);

CREATE TABLE ChannelName(
	id 				INTEGER 		PRIMARY KEY,
	channelName		TEXT			NOT NULL
)