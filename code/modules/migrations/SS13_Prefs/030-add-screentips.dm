/datum/migration/sqlite/ss13_prefs/_030
	id = 30
	name = "Add Screentips"

/datum/migration/sqlite/ss13_prefs/_030/up()
	. = TRUE
	if(!hasColumn("client","screentips"))
		. = . && execute("ALTER TABLE `client` ADD COLUMN screentips INTEGER DEFAULT 0")
	if(!hasColumn("client","screentip_color"))
		. = . && execute("ALTER TABLE `client` ADD COLUMN screentip_color TEXT DEFAULT '#ffd391'")
	if(!hasColumn("client","screentip_size"))
		. = . && execute("ALTER TABLE `client` ADD COLUMN screentip_size INTEGER DEFAULT 1")

/datum/migration/sqlite/ss13_prefs/_030/down()
	. = TRUE
	if(hasColumn("client","screentips"))
		. = . && execute("ALTER TABLE `client` DROP COLUMN screentips")
	if(hasColumn("client","screentip_color"))
		. = . && execute("ALTER TABLE `client` DROP COLUMN screentip_color")
	if(hasColumn("client","screentip_size"))
		. = . && execute("ALTER TABLE `client` DROP COLUMN screentip_size")
