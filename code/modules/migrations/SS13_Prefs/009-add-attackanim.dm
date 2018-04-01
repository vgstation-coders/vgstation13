/datum/migration/sqlite/ss13_prefs/_009
	id = 9
	name = "Add Attack Animations"

/datum/migration/sqlite/ss13_prefs/_009/up()
	if(!hasColumn("client","attack_animation"))
		return execute("ALTER TABLE `client` ADD COLUMN attack_animation INTEGER DEFAULT 0")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_009/down()
	if(hasColumn("client","attack_animation"))
		return execute("ALTER TABLE `client` DROP COLUMN attack_animation")
	return TRUE
