BEGIN TRANSACTION;
DROP TABLE IF EXISTS "data";
CREATE TABLE "data" (
	"id"	INTEGER NOT NULL,
	"question"	TEXT NOT NULL,
	"source"	TEXT NOT NULL,
	"used"	NUMERIC NOT NULL,
	"when"	TEXT,
	PRIMARY KEY("id" AUTOINCREMENT)
);
COMMIT;
