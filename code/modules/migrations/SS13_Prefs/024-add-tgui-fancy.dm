/datum/migration/sqlite/ss13_prefs/_024
	id = 24
	name = "tgui_fancy"

/datum/migration/sqlite/ss13_prefs/_024/up()
	if(!hasColumn("client","tgui_fancy"))
		return execute("ALTER TABLE `client` ADD COLUMN tgui_fancy INTEGER DEFAULT 1")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_024/down()
	if(hasColumn("client","tgui_fancy"))
		return execute("ALTER TABLE `client` DROP COLUMN tgui_fancy")
	return TRUE
