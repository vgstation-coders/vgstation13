/datum/migration/sqlite/ss13_prefs/_027
	id = 27
	name = "Refactor jobs"

/datum/migration/sqlite/ss13_prefs/_027/up()
	if(!hasColumn("jobs", "jobs"))
		return execute("ALTER TABLE `jobs` ADD COLUMN jobs TEXT")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_027/down()
	if(hasColumn("jobs", "jobs"))
		return execute("ALTER TABLE `jobs` DROP COLUMN jobs")
	return TRUE
