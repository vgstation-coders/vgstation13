/datum/migration/sqlite/ss13_prefs/_028
	id = 28
	name = "Lighting post-processing"


/datum/migration/sqlite/ss13_prefs/_028/up()
	if(!hasColumn("client","blur_size"))
		return execute("ALTER TABLE `client` ADD COLUMN blur_size INTEGER DEFAULT 0")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_028/down()
	if(hasColumn("client","blur_size"))
		return execute("ALTER TABLE `client` DROP COLUMN blur_size")
	return TRUE
