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