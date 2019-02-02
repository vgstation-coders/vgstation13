/datum/migration/sqlite/ss13_prefs/_014
	id = 14
	name = "Add Credits Preference"

/datum/migration/sqlite/ss13_prefs/_014/up()
	if(!hasColumn("client","credits"))
		return execute("ALTER TABLE `client` ADD COLUMN credits TEXT DEFAULT 'Always'")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_014/down()
	if(hasColumn("client","credits"))
		return execute("ALTER TABLE `client` DROP COLUMN credits")
	return TRUE
