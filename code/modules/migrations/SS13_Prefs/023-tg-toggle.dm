/datum/migration/sqlite/ss13_prefs/_023
	id = 23
	name = "Toggle TG Redirection"

/datum/migration/sqlite/ss13_prefs/_023/up()
	if(!hasColumn("client","tg_redirect"))
		return execute("ALTER TABLE `client` ADD COLUMN tg_redirection INTEGER DEFAULT 0")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_023/down()
	if(hasColumn("client","tg_redirect"))
		return execute("ALTER TABLE `client` DROP COLUMN tg_redirection")
	return TRUE
