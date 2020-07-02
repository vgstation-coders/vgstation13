/datum/migration/sqlite/ss13_prefs/_019
	id = 19
	name = "Add Credits Volume"

/datum/migration/sqlite/ss13_prefs/_019/up()
	if(!hasColumn("client","credits_volume"))
		return execute("ALTER TABLE `client` ADD COLUMN credits_volume INTEGER DEFAULT 75")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_019/down()
	if(hasColumn("client","credits_volume"))
		return execute("ALTER TABLE `client` DROP COLUMN credits_volume")
	return TRUE
