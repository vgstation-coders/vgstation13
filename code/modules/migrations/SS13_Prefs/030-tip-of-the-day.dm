/datum/migration/sqlite/ss13_prefs/_030
	id = 30
	name = "Tip of the day"

/datum/migration/sqlite/ss13_prefs/_030/up()
	if(!hasColumn("client", "tip_of_the_day"))
		return execute("ALTER TABLE `client` ADD COLUMN tip_of_the_day INTEGER DEFAULT 1")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_030/down()
	if(hasColumn("client", "tip_of_the_day"))
		return execute("ALTER TABLE `client` DROP COLUMN tip_of_the_day")
	return TRUE
