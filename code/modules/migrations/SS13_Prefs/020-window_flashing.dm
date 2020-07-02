/datum/migration/sqlite/ss13_prefs/_020
	id = 20
	name = "Toggle Window Flashing"

/datum/migration/sqlite/ss13_prefs/_020/up()
	if(!hasColumn("client","window_flashing"))
		return execute("ALTER TABLE `client` ADD COLUMN window_flashing INTEGER DEFAULT 1")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_020/down()
	if(hasColumn("client","window_flashing"))
		return execute("ALTER TABLE `client` DROP COLUMN window_flashing")
	return TRUE