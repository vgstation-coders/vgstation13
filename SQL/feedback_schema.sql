-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Generation Time: Jun 07, 2025 at 04:52 PM
-- Server version: 9.1.0
-- PHP Version: 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `feedback`
--
CREATE DATABASE IF NOT EXISTS `feedback` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE `feedback`;

-- --------------------------------------------------------

--
-- Table structure for table `admin_sessions`
--

CREATE TABLE IF NOT EXISTS `admin_sessions` (
  `sessID` char(36) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `ckey` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `expires` datetime DEFAULT NULL,
  `IP` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  PRIMARY KEY (`sessID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `customitems`
--

CREATE TABLE IF NOT EXISTS `customitems` (
  `cuiCKey` varchar(36) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `cuiRealName` varchar(60) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `cuiPath` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `cuiDescription` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `cuiReason` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `cuiPropAdjust` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `cuiJobMask` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  PRIMARY KEY (`cuiCKey`,`cuiRealName`,`cuiPath`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `erro_admin`
--

CREATE TABLE IF NOT EXISTS `erro_admin` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `rank` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT 'Administrator',
  `level` int NOT NULL DEFAULT '0',
  `flags` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `erro_admin_log`
--

CREATE TABLE IF NOT EXISTS `erro_admin_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `adminckey` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `adminip` varchar(18) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `log` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `erro_ban`
--

CREATE TABLE IF NOT EXISTS `erro_ban` (
  `id` int NOT NULL AUTO_INCREMENT,
  `bantime` datetime NOT NULL,
  `serverip` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `bantype` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `reason` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `job` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `duration` int NOT NULL,
  `rounds` int DEFAULT NULL,
  `expiration_time` datetime NOT NULL,
  `ckey` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `computerid` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `ip` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `a_ckey` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `a_computerid` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `a_ip` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `who` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `adminwho` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `edits` text CHARACTER SET latin1 COLLATE latin1_swedish_ci,
  `unbanned` tinyint(1) DEFAULT NULL,
  `unbanned_datetime` datetime DEFAULT NULL,
  `unbanned_ckey` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `unbanned_computerid` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `unbanned_ip` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `unbanned_notification` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `erro_connection_log`
--

CREATE TABLE IF NOT EXISTS `erro_connection_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `datetime` datetime DEFAULT NULL,
  `serverip` varchar(45) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `ckey` varchar(45) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `ip` varchar(18) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `computerid` varchar(45) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `erro_feedback`
--

CREATE TABLE IF NOT EXISTS `erro_feedback` (
  `id` int NOT NULL AUTO_INCREMENT,
  `time` datetime NOT NULL,
  `round_id` int NOT NULL,
  `var_name` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `var_value` int DEFAULT NULL,
  `details` text CHARACTER SET latin1 COLLATE latin1_swedish_ci,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `erro_player`
--

CREATE TABLE IF NOT EXISTS `erro_player` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ckey` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `firstseen` datetime NOT NULL,
  `lastseen` datetime NOT NULL,
  `ip` varchar(18) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `computerid` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `lastadminrank` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT 'Player',
  `accountjoined` date DEFAULT NULL,
  `fingerprint` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ckey` (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `erro_poll_option`
--

CREATE TABLE IF NOT EXISTS `erro_poll_option` (
  `id` int NOT NULL AUTO_INCREMENT,
  `pollid` int NOT NULL,
  `text` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `percentagecalc` tinyint(1) NOT NULL DEFAULT '1',
  `minval` int DEFAULT NULL,
  `maxval` int DEFAULT NULL,
  `descmin` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `descmid` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `descmax` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `erro_poll_question`
--

CREATE TABLE IF NOT EXISTS `erro_poll_question` (
  `id` int NOT NULL AUTO_INCREMENT,
  `polltype` varchar(16) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT 'OPTION',
  `starttime` datetime NOT NULL,
  `endtime` datetime NOT NULL,
  `question` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `adminonly` tinyint(1) DEFAULT '0',
  `multiplechoiceoptions` int DEFAULT NULL,
  `createdby_ckey` varchar(45) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `createdby_ip` varchar(45) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `hidden` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `erro_poll_textreply`
--

CREATE TABLE IF NOT EXISTS `erro_poll_textreply` (
  `id` int NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `pollid` int NOT NULL,
  `ckey` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `ip` varchar(18) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `replytext` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `adminrank` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT 'Player',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `erro_poll_vote`
--

CREATE TABLE IF NOT EXISTS `erro_poll_vote` (
  `id` int NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `pollid` int NOT NULL,
  `optionid` int NOT NULL,
  `ckey` varchar(255) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `ip` varchar(16) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `adminrank` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `rating` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `erro_privacy`
--

CREATE TABLE IF NOT EXISTS `erro_privacy` (
  `id` int NOT NULL AUTO_INCREMENT,
  `datetime` datetime NOT NULL,
  `ckey` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `option` varchar(128) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `karma`
--

CREATE TABLE IF NOT EXISTS `karma` (
  `id` int NOT NULL AUTO_INCREMENT,
  `spendername` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `spenderkey` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `receivername` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `receiverkey` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `receiverrole` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `receiverspecial` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `isnegative` tinyint(1) NOT NULL,
  `spenderip` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `time` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `karmatotals`
--

CREATE TABLE IF NOT EXISTS `karmatotals` (
  `id` int NOT NULL AUTO_INCREMENT,
  `byondkey` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `karma` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `library`
--

CREATE TABLE IF NOT EXISTS `library` (
  `id` int NOT NULL AUTO_INCREMENT,
  `author` mediumtext NOT NULL,
  `title` mediumtext NOT NULL,
  `content` mediumtext NOT NULL,
  `category` mediumtext NOT NULL,
  `description` mediumtext NOT NULL,
  `ckey` varchar(32) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Table structure for table `painting_db`
--

CREATE TABLE IF NOT EXISTS `painting_db` (
  `id` int NOT NULL AUTO_INCREMENT,
  `author` text CHARACTER SET latin1 COLLATE latin1_swedish_ci,
  `title` text CHARACTER SET latin1 COLLATE latin1_swedish_ci,
  `content` text CHARACTER SET latin1 COLLATE latin1_swedish_ci,
  `category` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `description` text CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `ckey` text CHARACTER SET latin1 COLLATE latin1_swedish_ci,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `population`
--

CREATE TABLE IF NOT EXISTS `population` (
  `id` int NOT NULL AUTO_INCREMENT,
  `playercount` int DEFAULT NULL,
  `admincount` int DEFAULT NULL,
  `time` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `testdb`
--

CREATE TABLE IF NOT EXISTS `testdb` (
  `id` int NOT NULL,
  `text` text CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;

-- --------------------------------------------------------

--
-- Table structure for table `_migrations`
--

CREATE TABLE IF NOT EXISTS `_migrations` (
  `pkgID` varchar(15) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `version` int NOT NULL,
  PRIMARY KEY (`pkgID`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_520_ci;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
