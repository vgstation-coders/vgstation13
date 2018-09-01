/datum/migration/sqlite/ss13_prefs/_012
	id = 12
	name = "Add Pull Preference"

/datum/migration/sqlite/ss13_prefs/_012/up()
	if(!hasColumn("players","pulltoggle"))
		return execute("ALTER TABLE `players` ADD COLUMN pulltoggle INTEGER DEFAULT 1")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_012/down()
	if(hasColumn("players","pulltoggle"))
		return execute("ALTER TABLE `players` DROP COLUMN pulltoggle")
	return TRUE
