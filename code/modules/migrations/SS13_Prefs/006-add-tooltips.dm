/datum/migration/sqlite/ss13_prefs/_006
	id = 6
	name = "Add Tooltips"

/datum/migration/sqlite/ss13_prefs/_006/up()
	if(!hasColumn("client","tooltips"))
		return execute("ALTER TABLE `client` ADD COLUMN tooltips INTEGER DEFAULT 1")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_006/down()
	if(hasColumn("client","tooltips"))
		return execute("ALTER TABLE `client` DROP COLUMN tooltips")
	return TRUE
	