/datum/migration/sqlite/ss13_prefs/_011
	id = 11
	name = "Add Flavor Text"

/datum/migration/sqlite/ss13_prefs/_011/up()
	if(!hasColumn("players","flavor_text"))
		return execute("ALTER TABLE `players` ADD COLUMN flavor_text TEXT DEFAULT ''")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_011/down()
	if(hasColumn("players","flavor_text"))
		return execute("ALTER TABLE `players` DROP COLUMN flavor_text")
	return TRUE
