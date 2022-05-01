/datum/migration/sqlite/ss13_prefs/_028
	id = 28
	name = "Headset Sounds"

/datum/migration/sqlite/ss13_prefs/_028/up()
	if(!hasColumn("client", "headset_sound"))
		return execute("ALTER TABLE `client` ADD COLUMN headset_sound")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_028/down()
	if(hasColumn("client", "headset_sound"))
		return execute("ALTER TABLE `client` DROP COLUMN headset_sound")
	return TRUE
