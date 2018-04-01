/datum/migration/sqlite/ss13_prefs/_008
	id = 8
	name = "Add Stumble"

/datum/migration/sqlite/ss13_prefs/_008/up()
	if(!hasColumn("client","stumble"))
		return execute("ALTER TABLE `client` ADD COLUMN stumble INTEGER DEFAULT 0")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_008/down()
	if(hasColumn("client","stumble"))
		return execute("ALTER TABLE `client` DROP COLUMN stumble")
	return TRUE
