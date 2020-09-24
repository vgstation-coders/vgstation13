/datum/migration/mysql/ss13/_015
	id = 15
	name = "Add unbanned notification for players"

/datum/migration/mysql/ss13/_015/up()
	if(!hasColumn("erro_ban","unbanned_notification"))
		var/sql1 = execute("ALTER TABLE erro_ban ADD COLUMN `unbanned_notification` int(2) NOT NULL DEFAULT '0';");
		var/sql2 = execute("UPDATE erro_ban SET `unbanned_notification` = 1;") // Every previous ban gets an unban notification
		return (sql1 && sql2)
	else
		warning("unbanned_notification column exists. Skipping addition.")

	return TRUE

/datum/migration/mysql/ss13/_015/down()
	if(hasColumn("erro_ban","unbanned_notification"))
		return execute("ALTER TABLE erro_ban DROP COLUMN `unbanned_notification` NOT NULL DEFAULT '0';");
	else
		warning("unbanned_notification column does not exist. Skipping drop.")

	return TRUE
