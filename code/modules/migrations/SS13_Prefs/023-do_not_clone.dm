/datum/migration/sqlite/ss13_prefs/_023
	id = 23
	name = "Toggle Do Not Clone"

/datum/migration/sqlite/ss13_prefs/_023/up()
	if(!hasColumn("client","do_not_clone"))
		return execute("ALTER TABLE `client` ADD COLUMN do_not_clone INTEGER DEFAULT 0")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_023/down()
	if(hasColumn("client","do_not_clone"))
		return execute("ALTER TABLE `client` DROP COLUMN do_not_clone")
	return TRUE
