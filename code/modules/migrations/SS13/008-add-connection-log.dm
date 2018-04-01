/datum/migration/mysql/ss13/_008
	id = 8
	name = "Add connection log table."

/datum/migration/mysql/ss13/_008/up()
	var/sql={"
CREATE TABLE IF NOT EXISTS erro_connection_log (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`datetime` datetime DEFAULT NULL,
	`serverip` varchar(45) DEFAULT NULL,
	`ckey` varchar(45) DEFAULT NULL,
	`ip` varchar(18) DEFAULT NULL,
	`computerid` varchar(45) DEFAULT NULL,
	PRIMARY KEY (`id`)
);"}
	return execute(sql)

/datum/migration/mysql/ss13/_008/down()
	return execute("DROP TABLE IF EXISTS erro_connection_log;");
