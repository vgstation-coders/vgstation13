/datum/migration/mysql/ss13/_014
	id = 14
	name = "IP creator in polls"

/datum/migration/mysql/ss13/_014/up()
	if(!hasColumn("erro_poll_question","createdby_ip"))
		return execute("ALTER TABLE erro_poll_question ADD COLUMN `createdby_ip` VARCHAR(32) NULL;");
	else
		warning("createdby_ip column exists. Skipping addition.")

	return TRUE

/datum/migration/mysql/ss13/_014/down()
	if(hasColumn("erro_poll_question","createdby_ip"))
		return execute("ALTER TABLE erro_poll_question DROP COLUMN `createdby_ip` VARCHAR(32) NULL;");
	else
		warning("createdby_ip column does not exist. Skipping drop.")

	return TRUE
