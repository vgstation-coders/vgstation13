/datum/migration/mysql/ss13/_010
	id = 10
	name = "Admin-only polls"

/datum/migration/mysql/ss13/_010/up()
	if(!hasColumn("erro_poll_question","hidden"))
		return execute("ALTER TABLE erro_poll_question ADD COLUMN `hidden` BOOLEAN NULL;");
	else
		warning("hidden column exists. Skipping addition.")

	return TRUE

/datum/migration/mysql/ss13/_010/down()
	if(hasColumn("erro_poll_question","hidden"))
		return execute("ALTER TABLE erro_poll_question DROP COLUMN `hidden` BOOLEAN NULL;");
	else
		warning("hidden column does not exist. Skipping drop.")

	return TRUE
