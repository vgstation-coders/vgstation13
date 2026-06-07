/datum/migration/sqlite/ss13_prefs/_031
	id = 31
	name = "Add Corpse Re-entry Preference"

/datum/migration/sqlite/ss13_prefs/_031/up()
	if(!hasColumn("client","reentercorpse"))
		return execute("ALTER TABLE `client` ADD COLUMN reentercorpse INTEGER DEFAULT 1")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_031/down()
	if(hasColumn("client","reentercorpse"))
		return execute("ALTER TABLE `client` DROP COLUMN reentercorpse")
	return TRUE
