/datum/migration/sqlite/ss13_prefs/_015
	id = 15
	name = "Add Jingle Preference"

/datum/migration/sqlite/ss13_prefs/_015/up()
	if(!hasColumn("client","jingle"))
		return execute("ALTER TABLE `client` ADD COLUMN jingle TEXT DEFAULT 'Classics'")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_015/down()
	if(hasColumn("client","jingle"))
		return execute("ALTER TABLE `client` DROP COLUMN jingle")
	return TRUE
