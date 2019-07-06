/datum/migration/sqlite/ss13_prefs/_017
	id = 17
	name = "Add Instrument hearing"

/datum/migration/sqlite/ss13_prefs/_017/up()
	if(!hasColumn("client","hear_instruments"))
		return execute("ALTER TABLE `client` ADD COLUMN hear_instruments INTEGER DEFAULT 1")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_017/down()
	if(hasColumn("client","hear_instruments"))
		return execute("ALTER TABLE `client` DROP COLUMN hear_instruments")
	return TRUE
