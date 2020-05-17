/datum/migration/mysql/ss13/_013
	id = 13
	name = "Ckey creator in polls"

/datum/migration/mysql/ss13/_013/up()
	if(!hasColumn("erro_poll_question","createdby_ckey"))
		return execute("ALTER TABLE erro_poll_question ADD COLUMN `createdby_ckey` VARCHAR(32) NULL;");
	else
		warning("createdby_ckey column exists. Skipping addition.")

	return TRUE

/datum/migration/mysql/ss13/_013/down()
	if(hasColumn("erro_poll_question","createdby_ckey"))
		return execute("ALTER TABLE erro_poll_question DROP COLUMN `createdby_ckey` VARCHAR(32) NULL;");
	else
		warning("createdby_ckey column does not exist. Skipping drop.")

	return TRUE
