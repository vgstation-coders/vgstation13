/datum/migration/mysql/ss13/_016
	id = 16
	name = "Creating painting database"

/datum/migration/mysql/ss13/_016/up()
	var/sql1 = {"
CREATE TABLE IF NOT EXISTS `interdimensional_bank` (
  `ckey` text,
  `balance` int(11),

  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;"}
	if (!execute(sql1))
		return
	return TRUE
