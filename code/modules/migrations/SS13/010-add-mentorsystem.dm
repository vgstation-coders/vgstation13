/datum/migration/mysql/ss13/_010
	id = 10
	name = "Mentor System"

/datum/migration/mysql/ss13/_010/up()
	var/sql={"
CREATE TABLE IF NOT EXISTS mentors (
	`ckey` VARCHAR(255) PRIMARY KEY,
);
	"}
	return execute(sql)

/datum/migration/mysql/ss13/_010/down()
	return execute("DROP TABLE IF EXISTS mentors;");