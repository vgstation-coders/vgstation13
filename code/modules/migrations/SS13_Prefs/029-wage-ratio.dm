/datum/migration/sqlite/ss13_prefs/_029
	id = 29
	name = "Wage Ratio"

/datum/migration/sqlite/ss13_prefs/_029/up()
	if(!hasColumn("players", "wage_ratio"))
		return execute("ALTER TABLE `players` ADD COLUMN wage_ratio")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_029/down()
	if(hasColumn("players", "wage_ratio"))
		return execute("ALTER TABLE `players` DROP COLUMN wage_ratio")
	return TRUE
