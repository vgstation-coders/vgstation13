/datum/migration/sqlite/ss13_prefs/_023
	id = 23
	name = "Runechat"

/datum/migration/sqlite/ss13_prefs/_023/up()
	var/mig1
	var/mig2
	var/mig3
	var/mig4
	if(!hasColumn("client","mob_chat_on_map"))
		mig1 = execute("ALTER TABLE `client` ADD COLUMN mob_chat_on_map INTEGER DEFAULT 0")
	if(!hasColumn("client","max_chat_length"))
		mig2 = execute("ALTER TABLE `client` ADD COLUMN max_chat_length INTEGER DEFAULT [CHAT_MESSAGE_MAX_LENGTH]")
	if(!hasColumn("client","obj_chat_on_map"))
		mig3 = execute("ALTER TABLE `client` ADD COLUMN obj_chat_on_map INTEGER DEFAULT 0")
	if(!hasColumn("client","no_goonchat_for_obj"))
		mig4 = execute("ALTER TABLE `client` ADD COLUMN no_goonchat_for_obj INTEGER DEFAULT 0")
	return mig1 && mig2 && mig3 && mig4

/datum/migration/sqlite/ss13_prefs/_023/down()
	var/mig1
	var/mig2
	var/mig3
	var/mig4
	if(hasColumn("client","mob_chat_on_map"))
		mig1 = execute("ALTER TABLE `client` DROP COLUMN mob_chat_on_map")
	if(hasColumn("client","obj_chat_on_map"))
		mig2 = execute("ALTER TABLE `client` DROP COLUMN obj_chat_on_map")
	if(hasColumn("client","max_chat_length"))
		mig3 = execute("ALTER TABLE `client` DROP COLUMN max_chat_length")
	if(hasColumn("client","no_goonchat_for_obj"))
		mig4 = execute("ALTER TABLE `client` DROP COLUMN no_goonchat_for_obj")
	return mig1 && mig2 && mig3 && mig4
