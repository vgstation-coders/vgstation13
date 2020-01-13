/datum/migration/sqlite/ss13_prefs/_021
	id = 21
	name = "Toggle Solo Antag Objectives"

/datum/migration/sqlite/ss13_prefs/_021/up()
	if(!hasColumn("client","antag_objectives"))
		return execute("ALTER TABLE `client` ADD COLUMN antag_objectives INTEGER DEFAULT 0")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_021/down()
	if(hasColumn("client","antag_objectives"))
		return execute("ALTER TABLE `client` DROP COLUMN antag_objectives")
	return TRUE