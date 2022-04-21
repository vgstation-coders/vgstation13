/datum/migration/sqlite/ss13_prefs/_028
	id = 28
	name = "Headset Sounds"

/datum/migration/sqlite/ss13_prefs/_028/up()
	if(!hasColumn("client","headset_sounds"))
		return execute("ALTER TABLE `headset_sound` ADD COLUMN headset_sound")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_028/down()
	if(hasColumn("client","headset_sounds"))
		return execute("ALTER TABLE `headset_sound` DROP COLUMN headset_sound")
	return TRUE