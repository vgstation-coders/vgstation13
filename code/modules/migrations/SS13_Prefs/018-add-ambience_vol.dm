/datum/migration/sqlite/ss13_prefs/_018
	id = 18
	name = "Add ambience volume"

/datum/migration/sqlite/ss13_prefs/_018/up()
	if(!hasColumn("client","ambience_volume"))
		return execute("ALTER TABLE `client` ADD COLUMN ambience_volume INTEGER DEFAULT 25")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_018/down()
	if(hasColumn("client","ambience_volume"))
		return execute("ALTER TABLE `client` DROP COLUMN ambience_volume")
	return TRUE
