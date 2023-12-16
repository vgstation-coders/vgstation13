/datum/migration/mysql/ss13/_017
	id = 17
	name = "Creating player_whitelist table."

/datum/migration/mysql/ss13/_017/up()
	var/sql={"
CREATE TABLE IF NOT EXISTS `player_whitelist` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ckey` varchar(255) DEFAULT NULL,
  `invitedby` int(11) DEFAULT 0,
  `dateinvited` date DEFAULT curdate(),
  `verified` tinyint(4) DEFAULT 0,
  `description` tinytext DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ckey` (`ckey`)
);"}
	return execute(sql)

/datum/migration/mysql/ss13/_017/down()
	return execute("DROP TABLE IF EXISTS player_whitelist;");
