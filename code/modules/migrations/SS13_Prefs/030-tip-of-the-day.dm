/datum/migration/sqlite/ss13_prefs/_030
	id = 30
	name = "Tip of the day"

/datum/migration/sqlite/ss13_prefs/_030/up()
	if(!hasColumn("players", "tip_of_the_day"))
		return execute("ALTER TABLE `players` ADD COLUMN tip_of_the_day INTEGER DEFAULT 1")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_030/down()
	if(hasColumn("players", "tip_of_the_day"))
		return execute("ALTER TABLE `players` DROP COLUMN tip_of_the_day")
	return TRUE
