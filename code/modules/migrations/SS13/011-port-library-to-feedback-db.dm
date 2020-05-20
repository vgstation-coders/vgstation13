/datum/migration/mysql/ss13/_011
	id = 11
	name = "Library in feedback DB"

/datum/migration/mysql/ss13/_011/up()
	if(!hasTable("library"))
		return execute({"CREATE TABLE IF NOT EXISTS `library` (
 			`id` INT(11) NOT NULL AUTO_INCREMENT ,
  			`author` TEXT NOT NULL ,
 			`title` TEXT NOT NULL ,
  			`content` TEXT NOT NULL ,
  			`category` TEXT NOT NULL ,
			`ckey` VARCHAR(32) NULL ,
  			PRIMARY KEY (`id`) )
			ENGINE = MyISAM
			AUTO_INCREMENT = 184
			DEFAULT CHARACTER SET = latin1;
		"});
	else
		warning("library table exists. Skipping addition.")

	return TRUE

/datum/migration/mysql/ss13/_011/down()
	if(hasTable("library"))
		return execute("DROP TABLE library");
	else
		warning("library table doesn't exist. Skipping drop.")

	return TRUE
