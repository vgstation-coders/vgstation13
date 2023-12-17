/datum/migration/mysql/ss13/_016
	id = 16
	name = "Creating painting database"

/datum/migration/mysql/ss13/_016/up()
	var/sql1 = {"
CREATE TABLE IF NOT EXISTS `painting_db` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author` text,
  `title` text,
  `category` text,
  `content` text,
  `description` text,
  `ckey` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;"}
	if (!execute(sql1))
		return
	if(!hasColumn("library", "description"))
		var/sql2 = "ALTER TABLE `library` ADD `description` TEXT NOT NULL AFTER `category`;"
		if (!execute(sql2))
			return
	return TRUE
