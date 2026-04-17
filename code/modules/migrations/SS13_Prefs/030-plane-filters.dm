/datum/migration/sqlite/ss13_prefs/_030
	id = 30
	name = "Plane Filters"

/datum/migration/sqlite/ss13_prefs/_030/up()
	if(!hasColumn("client","plane_filters"))
		return execute("ALTER TABLE `client` ADD COLUMN plane_filters INTEGER DEFAULT 1")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_030/down()
	if(hasColumn("client","plane_filters"))
		return execute("ALTER TABLE `client` DROP COLUMN plane_filters")
	return TRUE
