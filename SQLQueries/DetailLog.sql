CREATE TABLE DetailLog(
	id 				INTEGER 		PRIMARY KEY,
	entryId			INTEGER 		NOT NULL,
	fieldId			INTEGER 		NOT NULL,
	value			NUMERIC 		NOT NULL,
	unit			TEXT,
	FOREIGN KEY(fieldId) REFERENCES DetailName(id)
	FOREIGN KEY(entryId) REFERENCES MasterDirectory(id)
)