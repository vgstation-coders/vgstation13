/datum/migration/sqlite/ss13_prefs/_026
	id = 26
	name = "Add FPS"

/datum/migration/sqlite/ss13_prefs/_026/up()
	if(!hasColumn("client","fps"))
		return execute("ALTER TABLE `client` ADD COLUMN fps INTEGER DEFAULT 0")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_026/down()
	if(hasColumn("client","fps"))
		return execute("ALTER TABLE `client` DROP COLUMN fps")
	return TRUE
