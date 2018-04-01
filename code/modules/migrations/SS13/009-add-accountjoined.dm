/datum/migration/mysql/ss13/_009
	id = 9
	name = "Secret Fingerprints"

/datum/migration/mysql/ss13/_009/up()
	if(!hasColumn("erro_player","accountjoined"))
		return execute("ALTER TABLE erro_player ADD COLUMN `accountjoined` date NULL;");
	else
		warning("accountjoined column exists. Skipping addition.")

	return TRUE

/datum/migration/mysql/ss13/_009/down()
	if(hasColumn("erro_player","accountjoined"))
		return execute("ALTER TABLE erro_player DROP COLUMN `accountjoined`;");
	else
		warning("accountjoined column does not exist. Skipping drop.")

	return TRUE
