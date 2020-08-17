/datum/migration/sqlite/ss13_prefs/_022
	id = 22
	name = "Toggle Typing Indicator"

/datum/migration/sqlite/ss13_prefs/_022/up()
	if(!hasColumn("client","typing_indicator"))
		return execute("ALTER TABLE `client` ADD COLUMN typing_indicator INTEGER DEFAULT 0")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_022/down()
	if(hasColumn("client","typing_indicator"))
		return execute("ALTER TABLE `client` DROP COLUMN typing_indicator")
	return TRUE
