/datum/migration/mysql/ss13/_012
	id = 12
	name = "Customitems in feedback DB"

/datum/migration/mysql/ss13/_012/up()
	if(!hasTable("customitems"))
		return execute({"CREATE TABLE IF NOT EXISTS `customitems` (
	 		cuiCKey VARCHAR(36) NOT NULL,
	 		cuiRealName VARCHAR(60) NOT NULL,
	 		cuiPath VARCHAR(255) NOT NULL,
	 		cuiDescription TEXT NOT NULL,
	 		cuiReason TEXT NOT NULL,
	 		cuiPropAdjust TEXT NOT NULL,
	 		cuiJobMask TEXT NOT NULL,
	 		PRIMARY KEY(cuiCkey,cuiRealName,cuiPath)
			)
		"});
	else
		warning("customitems table exists. Skipping addition.")

	return TRUE

/datum/migration/mysql/ss13/_012/down()
	if(hasTable("customitems"))
		return execute("DROP TABLE customitems");
	else
		warning("customitems table doesn't exist. Skipping drop.")

	return TRUE
