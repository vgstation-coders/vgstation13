/datum/migration/sqlite/ss13_prefs/_025
	id = 25
	name = "Warning notification"

/datum/migration/sqlite/ss13_prefs/_025/up()
	var/sql1 = TRUE
	var/sql2 = TRUE
	var/sql3 = TRUE
	if(!hasColumn("client","show_warning_next_time"))
		sql1 = execute("ALTER TABLE `client` ADD COLUMN show_warning_next_time INTEGER DEFAULT 0")
	if(!hasColumn("client","last_warned_message"))
		sql2 = execute("ALTER TABLE `client` ADD COLUMN last_warned_message TEXT DEFAULT ''")
	if(!hasColumn("client","warning_admin"))
		sql3 = execute("ALTER TABLE `client` ADD COLUMN warning_admin TEXT DEFAULT ''")
	return sql1 && sql2 && sql3

/datum/migration/sqlite/ss13_prefs/_025/down()
	var/sql1 = TRUE
	var/sql2 = TRUE
	var/sql3 = TRUE
	if(hasColumn("client","show_warning_next_time"))
		sql1 = execute("ALTER TABLE `client` DROP COLUMN show_warning_next_time")
	if(hasColumn("client","last_warned_message"))
		sql2 = execute("ALTER TABLE `client` DROP COLUMN last_warned_message")
	if(hasColumn("client","warning_admin"))
		sql3 = execute("ALTER TABLE `client` DROP COLUMN warning_admin")
	return sql1 && sql2 && sql3
