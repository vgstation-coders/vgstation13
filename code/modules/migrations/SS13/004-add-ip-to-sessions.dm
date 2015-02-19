/datum/migration/ss13/_004
	id = 4
	name = "Add IP to Sessions"

/datum/migration/ss13/_003/up()
	if(!hasColumn("admin_sessions","IP"))
		execute("ALTER TABLE admin_sessions ADD COLUMN `IP` VARCHAR(255) DEFAULT NULL;");
	else
		warning("IP column exists. Skipping addition.")

/datum/migration/ss13/_003/down()
	if(hasColumn("admin_sessions","IP"))
		execute("ALTER TABLE admin_sessions DROP COLUMN `IP`;");
	else
		warning("IP column does not exist. Skipping drop.")