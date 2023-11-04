/datum/migration/sqlite/ss13_prefs/_024
	id = 24
	name = "vgui_fancy"

/datum/migration/sqlite/ss13_prefs/_024/up()
	if(!hasColumn("client","vgui_fancy"))
		return execute("ALTER TABLE `client` ADD COLUMN vgui_fancy INTEGER DEFAULT 1")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_024/down()
	if(hasColumn("client","vgui_fancy"))
		return execute("ALTER TABLE `client` DROP COLUMN vgui_fancy")
	return TRUE
