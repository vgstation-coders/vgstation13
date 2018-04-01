/datum/migration/sqlite/ss13_prefs/_007
	id = 7
	name = "Remove flavor text"

/datum/migration/sqlite/ss13_prefs/_007/up()
//	DROP COLUMN doesn't actually exist in sqlite so this needs some fuckery to actually get functional
//	if(!hasColumn("client","flavor_text"))
//		return execute("ALTER TABLE `client` DROP COLUMN flavor_text")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_007/down()
	if(hasColumn("client","flavor_text"))
		return execute("ALTER TABLE `client` ADD COLUMN flavor_text TEXT")
	return TRUE
