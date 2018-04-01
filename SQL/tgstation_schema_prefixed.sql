/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `SS13_admin`
--

DROP TABLE IF EXISTS `SS13_admin`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SS13_admin` (
  `ckey` varchar(32) NOT NULL,
  `rank` varchar(32) NOT NULL,
  PRIMARY KEY (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SS13_admin_log`
--

DROP TABLE IF EXISTS `SS13_admin_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SS13_admin_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `adminip` int(10) unsigned NOT NULL,
  `operation` enum('add admin','remove admin','change admin rank','add rank','remove rank','change rank flags') NOT NULL,
  `log` varchar(1000) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SS13_admin_ranks`
--

DROP TABLE IF EXISTS `SS13_admin_ranks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SS13_admin_ranks` (
  `rank` varchar(32) NOT NULL,
  `flags` smallint(5) unsigned NOT NULL,
  `exclude_flags` smallint(5) unsigned NOT NULL,
  `can_edit_flags` smallint(5) unsigned NOT NULL,
  PRIMARY KEY (`rank`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SS13_ban`
--

DROP TABLE IF EXISTS `SS13_ban`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SS13_ban` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `bantime` datetime NOT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) NOT NULL,
  `bantype` enum('PERMABAN','TEMPBAN','JOB_PERMABAN','JOB_TEMPBAN','ADMIN_PERMABAN','ADMIN_TEMPBAN') NOT NULL,
  `reason` varchar(2048) NOT NULL,
  `job` varchar(32) DEFAULT NULL,
  `duration` int(11) NOT NULL,
  `expiration_time` datetime NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `computerid` varchar(32) NOT NULL,
  `ip` int(10) unsigned NOT NULL,
  `a_ckey` varchar(32) NOT NULL,
  `a_computerid` varchar(32) NOT NULL,
  `a_ip` int(10) unsigned NOT NULL,
  `who` varchar(2048) NOT NULL,
  `adminwho` varchar(2048) NOT NULL,
  `edits` text,
  `unbanned` tinyint(3) unsigned DEFAULT NULL,
  `unbanned_datetime` datetime DEFAULT NULL,
  `unbanned_ckey` varchar(32) DEFAULT NULL,
  `unbanned_computerid` varchar(32) DEFAULT NULL,
  `unbanned_ip` int(10) unsigned DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ban_checkban` (`ckey`,`bantype`,`expiration_time`,`unbanned`,`job`),
  KEY `idx_ban_isbanned` (`ckey`,`ip`,`computerid`,`bantype`,`expiration_time`,`unbanned`),
  KEY `idx_ban_count` (`id`,`a_ckey`,`bantype`,`expiration_time`,`unbanned`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SS13_connection_log`
--

DROP TABLE IF EXISTS `SS13_connection_log`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SS13_connection_log` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime DEFAULT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  `ckey` varchar(45) DEFAULT NULL,
  `ip` int(10) unsigned NOT NULL,
  `computerid` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SS13_death`
--

DROP TABLE IF EXISTS `SS13_death`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SS13_death` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pod` varchar(50) NOT NULL,
  `x_coord` smallint(5) unsigned NOT NULL,
  `y_coord` smallint(5) unsigned NOT NULL,
  `z_coord` smallint(5) unsigned NOT NULL,
  `mapname` varchar(32) NOT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) NOT NULL,
  `tod` datetime NOT NULL COMMENT 'Time of death',
  `job` varchar(32) NOT NULL,
  `special` varchar(32) DEFAULT NULL,
  `name` varchar(96) NOT NULL,
  `byondkey` varchar(32) NOT NULL,
  `laname` varchar(96) DEFAULT NULL,
  `lakey` varchar(32) DEFAULT NULL,
  `bruteloss` smallint(5) unsigned NOT NULL,
  `brainloss` smallint(5) unsigned NOT NULL,
  `fireloss` smallint(5) unsigned NOT NULL,
  `oxyloss` smallint(5) unsigned NOT NULL,
  `toxloss` smallint(5) unsigned NOT NULL,
  `cloneloss` smallint(5) unsigned NOT NULL,
  `staminaloss` smallint(5) unsigned NOT NULL,
  `last_words` varchar(255) DEFAULT NULL,
  `suicide` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SS13_feedback`
--

DROP TABLE IF EXISTS `SS13_feedback`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SS13_feedback` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  `key_name` varchar(32) NOT NULL,
  `version` tinyint(3) unsigned NOT NULL,
  `key_type` enum('text', 'amount', 'tally', 'nested tally', 'associative') NOT NULL,
  `json` json NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SS13_ipintel`
--

DROP TABLE IF EXISTS `SS13_ipintel`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SS13_ipintel` (
  `ip` int(10) unsigned NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `intel` double NOT NULL DEFAULT '0',
  PRIMARY KEY (`ip`),
  KEY `idx_ipintel` (`ip`,`intel`,`date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SS13_legacy_population`
--

DROP TABLE IF EXISTS `SS13_legacy_population`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SS13_legacy_population` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playercount` int(11) DEFAULT NULL,
  `admincount` int(11) DEFAULT NULL,
  `time` datetime NOT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SS13_library`
--

DROP TABLE IF EXISTS `SS13_library`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SS13_library` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `author` varchar(45) NOT NULL,
  `title` varchar(45) NOT NULL,
  `content` text NOT NULL,
  `category` enum('Any','Fiction','Non-Fiction','Adult','Reference','Religion') NOT NULL,
  `ckey` varchar(32) NOT NULL DEFAULT 'LEGACY',
  `datetime` datetime NOT NULL,
  `deleted` tinyint(1) unsigned DEFAULT NULL,
  `round_id_created` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `deleted_idx` (`deleted`),
  KEY `idx_lib_id_del` (`id`,`deleted`),
  KEY `idx_lib_del_title` (`deleted`,`title`),
  KEY `idx_lib_search` (`deleted`,`author`,`title`,`category`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SS13_messages`
--

DROP TABLE IF EXISTS `SS13_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SS13_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` enum('memo','message','message sent','note','watchlist entry') NOT NULL,
  `targetckey` varchar(32) NOT NULL,
  `adminckey` varchar(32) NOT NULL,
  `text` varchar(2048) NOT NULL,
  `timestamp` datetime NOT NULL,
  `server` varchar(32) DEFAULT NULL,
  `server_ip` int(10) unsigned NOT NULL,
  `server_port` smallint(5) unsigned NOT NULL,
  `round_id` int(11) unsigned NOT NULL,
  `secret` tinyint(1) unsigned NOT NULL,
  `lasteditor` varchar(32) DEFAULT NULL,
  `edits` text,
  `deleted` tinyint(1) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `idx_msg_ckey_time` (`targetckey`,`timestamp`, `deleted`),
  KEY `idx_msg_type_ckeys_time` (`type`,`targetckey`,`adminckey`,`timestamp`, `deleted`),
  KEY `idx_msg_type_ckey_time_odr` (`type`,`targetckey`,`timestamp`, `deleted`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SS13_role_time`
--

DROP TABLE IF EXISTS `SS13_role_time`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;

CREATE TABLE `SS13_role_time`
( `ckey` VARCHAR(32) NOT NULL ,
 `job` VARCHAR(32) NOT NULL ,
 `minutes` INT UNSIGNED NOT NULL,
 PRIMARY KEY (`ckey`, `job`)
 ) ENGINE = InnoDB;

--
-- Table structure for table `SS13_player`
--

DROP TABLE IF EXISTS `SS13_player`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SS13_player` (
  `ckey` varchar(32) NOT NULL,
  `firstseen` datetime NOT NULL,
  `firstseen_round_id` int(11) unsigned NOT NULL,
  `lastseen` datetime NOT NULL,
  `lastseen_round_id` int(11) unsigned NOT NULL,
  `ip` int(10) unsigned NOT NULL,
  `computerid` varchar(32) NOT NULL,
  `lastadminrank` varchar(32) NOT NULL DEFAULT 'Player',
  `accountjoindate` DATE DEFAULT NULL,
  `flags` smallint(5) unsigned DEFAULT '0' NOT NULL,
  PRIMARY KEY (`ckey`),
  KEY `idx_player_cid_ckey` (`computerid`,`ckey`),
  KEY `idx_player_ip_ckey` (`ip`,`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SS13_poll_option`
--

DROP TABLE IF EXISTS `SS13_poll_option`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SS13_poll_option` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `pollid` int(11) NOT NULL,
  `text` varchar(255) NOT NULL,
  `minval` int(3) DEFAULT NULL,
  `maxval` int(3) DEFAULT NULL,
  `descmin` varchar(32) DEFAULT NULL,
  `descmid` varchar(32) DEFAULT NULL,
  `descmax` varchar(32) DEFAULT NULL,
  `default_percentage_calc` tinyint(1) unsigned NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `idx_pop_pollid` (`pollid`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SS13_poll_question`
--

DROP TABLE IF EXISTS `SS13_poll_question`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SS13_poll_question` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `polltype` enum('OPTION','TEXT','NUMVAL','MULTICHOICE','IRV') NOT NULL,
  `starttime` datetime NOT NULL,
  `endtime` datetime NOT NULL,
  `question` varchar(255) NOT NULL,
  `adminonly` tinyint(1) unsigned NOT NULL,
  `multiplechoiceoptions` int(2) DEFAULT NULL,
  `createdby_ckey` varchar(32) DEFAULT NULL,
  `createdby_ip` int(10) unsigned NOT NULL,
  `dontshow` tinyint(1) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_pquest_question_time_ckey` (`question`,`starttime`,`endtime`,`createdby_ckey`,`createdby_ip`),
  KEY `idx_pquest_time_admin` (`starttime`,`endtime`,`adminonly`),
  KEY `idx_pquest_id_time_type_admin` (`id`,`starttime`,`endtime`,`polltype`,`adminonly`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SS13_poll_textreply`
--

DROP TABLE IF EXISTS `SS13_poll_textreply`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SS13_poll_textreply` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `pollid` int(11) NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `ip` int(10) unsigned NOT NULL,
  `replytext` varchar(2048) NOT NULL,
  `adminrank` varchar(32) NOT NULL DEFAULT 'Player',
  PRIMARY KEY (`id`),
  KEY `idx_ptext_pollid_ckey` (`pollid`,`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SS13_poll_vote`
--

DROP TABLE IF EXISTS `SS13_poll_vote`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SS13_poll_vote` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `pollid` int(11) NOT NULL,
  `optionid` int(11) NOT NULL,
  `ckey` varchar(32) NOT NULL,
  `ip` int(10) unsigned NOT NULL,
  `adminrank` varchar(32) NOT NULL,
  `rating` int(2) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_pvote_pollid_ckey` (`pollid`,`ckey`),
  KEY `idx_pvote_optionid_ckey` (`optionid`,`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `SS13_round`
--
DROP TABLE IF EXISTS `SS13_round`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `SS13_round` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `start_datetime` DATETIME NOT NULL,
  `end_datetime` DATETIME NULL,
  `server_ip` INT(10) UNSIGNED NOT NULL,
  `server_port` SMALLINT(5) UNSIGNED NOT NULL,
  `commit_hash` CHAR(40) NULL,
  `game_mode` VARCHAR(32) NULL,
  `game_mode_result` VARCHAR(64) NULL,
  `end_state` VARCHAR(64) NULL,
  `shuttle_name` VARCHAR(64) NULL,
  `map_name` VARCHAR(32) NULL,
  `station_name` VARCHAR(80) NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

--
-- Table structure for table `SS13_schema_revision`
--
DROP TABLE IF EXISTS `SS13_schema_revision`;
CREATE TABLE `SS13_schema_revision` (
  `major` TINYINT(3) unsigned NOT NULL,
  `minor` TINYINT(3) unsigned NOT NULL,
  `date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`major`,`minor`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
