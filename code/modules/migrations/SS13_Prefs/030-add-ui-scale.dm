/datum/migration/sqlite/ss13_prefs/_030
	id = 30
	name = "Add UI Scale"

/datum/migration/sqlite/ss13_prefs/_030/up()
	if (!hasColumn("client","ui_scale"))
		return execute("ALTER TABLE `client` ADD COLUMN ui_scale REAL DEFAULT 1")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_030/down()
	if (hasColumn("client","ui_scale"))
		return execute("ALTER TABLE `client` DROP COLUMN ui_scale")
	return TRUE
