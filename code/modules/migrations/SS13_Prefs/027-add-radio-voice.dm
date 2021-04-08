/datum/migration/sqlite/ss13_prefs/_027
	id = 27
	name = "Add Radio Voice Preference"

/datum/migration/sqlite/ss13_prefs/_014/up()
	if(!hasColumn("client","hear_radiosound"))
		return execute("ALTER TABLE `client` ADD COLUMN hear_radiosound TEXT DEFAULT 'Always'")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_014/down()
	if(hasColumn("client","hear_radiosound"))
		return execute("ALTER TABLE `client` DROP COLUMN hear_radiosound")
	return TRUE