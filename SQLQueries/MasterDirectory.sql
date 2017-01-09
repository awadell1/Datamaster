/*
SQLite Statements to recreate the database used by Datamaster
*/

--Delete Database
DROP TABLE `masterDirectory`;
DROP TABLE `DetailLog`;
DROP TABLE `DetailName`;
DROP TABLE `ChannelLog`;
DROP TABLE `ChannelName`;


--Turn on Foreign Keys for database
PRAGMA foreign_keys = on;

--Create Tables for Database
CREATE TABLE `masterDirectory` (
	`id`	INTEGER,
	`ldId`	TEXT NOT NULL UNIQUE,
	`ldxId`	TEXT NOT NULL UNIQUE,
	`OriginHash`	TEXT NOT NULL UNIQUE,
	`FinalHash`	TEXT NOT NULL UNIQUE,
	`Datetime`	TEXT,
	PRIMARY KEY(`id`)
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
);

INSERT INTO `ChannelName`(`id`,`channelName`) VALUES (NULL,'Engine_RPM');
INSERT INTO `DetailName`(`id`,`fieldName`) VALUES (NULL,'TotalLaps');
