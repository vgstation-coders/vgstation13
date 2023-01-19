/datum/migration/sqlite/ss13_prefs/_030
	name = "Alternate player names"

/datum/migration/sqlite/ss13_prefs/_30/up()
	if(!hasColumn("players", "clown_name"))
		return execute("ALTER TABLE `players` ADD COLUMN clown_name")
	if(!hasColumn("players", "mime_name"))
		return execute("ALTER TABLE `players` ADD COLUMN mime_name")
	if(!hasColumn("players", "ai_name"))
		return execute("ALTER TABLE `players` ADD COLUMN ai_name")
	if(!hasColumn("players", "cyborg_name"))
		return execute("ALTER TABLE `players` ADD COLUMN cyborg_name")
	if(!hasColumn("players", "mommi_name"))
		return execute("ALTER TABLE `players` ADD COLUMN mommi_name")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_030/down()
	if(hasColumn("players", "clown_name"))
		return execute("ALTER TABLE `players` DROP COLUMN clown_name")
	if(hasColumn("players", "mime_name"))
		return execute("ALTER TABLE `players` DROP COLUMN mime_name")
	if(hasColumn("players", "ai_name"))
		return execute("ALTER TABLE `players` DROP COLUMN ai_name")
	if(hasColumn("players", "cyborg_name"))
		return execute("ALTER TABLE `players` DROP COLUMN cyborg_name")
	if(hasColumn("players", "mommi_name"))
		return execute("ALTER TABLE `players` DROP COLUMN mommi_name")
	return TRUE
