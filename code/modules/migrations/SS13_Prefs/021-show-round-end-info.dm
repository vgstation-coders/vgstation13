/datum/migration/sqlite/ss13_prefs/_021
	id = 21
	name = "Toggle showing round end information"

/datum/migration/sqlite/ss13_prefs/_021/up()
	if(!hasColumn("client","show_round_end_info"))
		return execute("ALTER TABLE `client` ADD COLUMN show_round_end_info INTEGER DEFAULT 1")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_021/down()
	if(hasColumn("client","show_round_end_info"))
		return execute("ALTER TABLE `client` DROP COLUMN show_round_end_info")
	return TRUE