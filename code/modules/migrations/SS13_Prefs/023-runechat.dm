/datum/migration/sqlite/ss13_prefs/_023
	id = 23
	name = "Runechat"

/datum/migration/sqlite/ss13_prefs/_023/up()
	var/mig1
	var/mig2
	var/mig3
	if(!hasColumn("client","chat_on_map"))
		mig1 = execute("ALTER TABLE `client` ADD COLUMN chat_on_map INTEGER DEFAULT 0")
	if(!hasColumn("client","max_chat_length"))
		mig2 = execute("ALTER TABLE `client` ADD COLUMN max_chat_length INTEGER DEFAULT [CHAT_MESSAGE_MAX_LENGTH]")
	if(!hasColumn("client","see_chat_non_mob"))
		mig3 = execute("ALTER TABLE `client` ADD COLUMN see_chat_non_mob INTEGER DEFAULT 0")
	return mig1 && mig2 && mig3

/datum/migration/sqlite/ss13_prefs/_023/down()
	var/mig1
	var/mig2
	var/mig3
	if(hasColumn("client","chat_on_map"))
		mig1 = execute("ALTER TABLE `client` DROP COLUMN chat_on_map")
	if(hasColumn("client","max_chat_length"))
		mig2 = execute("ALTER TABLE `client` DROP COLUMN max_chat_length")
	if(hasColumn("client","see_chat_non_mob"))
		mig3 = execute("ALTER TABLE `client` DROP COLUMN see_chat_non_mob")
	return mig1 && mig2 && mig3
