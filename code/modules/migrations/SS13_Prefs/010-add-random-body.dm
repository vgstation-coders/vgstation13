/datum/migration/sqlite/ss13_prefs/_010
	id = 10
	name = "Add Always Random Body"

/datum/migration/sqlite/ss13_prefs/_010/up()
	if(!hasColumn("players","random_body"))
		return execute("ALTER TABLE `players` ADD COLUMN random_body INTEGER DEFAULT 0")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_010/down()
	if(hasColumn("players","random_body"))
		return execute("ALTER TABLE `players` DROP COLUMN random_body")
	return TRUE
