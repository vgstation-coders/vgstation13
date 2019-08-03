/datum/migration/sqlite/ss13_prefs/_013
	id = 13
	name = "Add Bank Security Preference"

/datum/migration/sqlite/ss13_prefs/_013/up()
	if(!hasColumn("players","bank_security"))
		return execute("ALTER TABLE `players` ADD COLUMN bank_security INTEGER DEFAULT 1")
	return TRUE

/datum/migration/sqlite/ss13_prefs/_013/down()
	if(hasColumn("players","bank_security"))
		return execute("ALTER TABLE `players` DROP COLUMN bank_security")
	return TRUE
