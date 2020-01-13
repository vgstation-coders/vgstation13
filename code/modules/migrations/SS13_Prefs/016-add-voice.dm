/datum/migration/sqlite/ss13_prefs/_016
	id = 16
	name = "Add Voice Sounds"

/datum/migration/sqlite/ss13_prefs/_016/up()
	if(!hasColumn("client","hear_voicesound"))
		return execute("ALTER TABLE `client` ADD COLUMN hear_voicesound INTEGER DEFAULT 0")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_016/down()
	if(hasColumn("client","hear_voicesound"))
		return execute("ALTER TABLE `client` DROP COLUMN hear_voicesound")
	return TRUE
