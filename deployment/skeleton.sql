/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

CREATE TABLE IF NOT EXISTS `calcs` (
  `metric` varchar(50) NOT NULL DEFAULT '',
  `luxid` int(11) NOT NULL DEFAULT 0,
  `luxwsid` varchar(100) NOT NULL DEFAULT '',
  `description` varchar(50) NOT NULL DEFAULT '',
  `mqtt` enum('Y','N') NOT NULL DEFAULT 'N',
  `history` enum('Y','N') NOT NULL DEFAULT 'N',
  `history_interval` int(11) NOT NULL DEFAULT 0,
  `formatid` int(11) NOT NULL DEFAULT 0,
  `mapid` int(11) DEFAULT 0,
  PRIMARY KEY (`metric`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Calculations from the heatpump \r\nMeasurement values, etc.\r\nGroup 3004';

CREATE TABLE IF NOT EXISTS `calcvals` (
  `metric` varchar(50) NOT NULL,
  `value` double DEFAULT NULL,
  `text` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`metric`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Last read values from the headpump.';

CREATE TABLE IF NOT EXISTS `calcvals_history` (
  `ts` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `metric` varchar(50) NOT NULL,
  `value` double DEFAULT NULL,
  PRIMARY KEY (`ts`,`metric`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Calculations history';

CREATE TABLE IF NOT EXISTS `calcvals_unkown` (
  `luxid` int(11) NOT NULL,
  `value` double NOT NULL DEFAULT 0,
  PRIMARY KEY (`luxid`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Unkown calculations values.';

CREATE TABLE IF NOT EXISTS `errorlog` (
  `ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `value` double DEFAULT 0,
  `text` varchar(50) DEFAULT '',
  PRIMARY KEY (`ts`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Historie der Fehlermeldungen';

CREATE TABLE IF NOT EXISTS `params` (
  `metric` varchar(50) NOT NULL DEFAULT '',
  `luxid` int(11) NOT NULL DEFAULT 0,
  `luxwsid` varchar(100) NOT NULL DEFAULT '',
  `description` varchar(50) NOT NULL DEFAULT '',
  `mqtt` enum('Y','N') NOT NULL DEFAULT 'N',
  PRIMARY KEY (`metric`) USING BTREE,
  KEY `luxid` (`luxid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Parameters from the heatpump\r\nGroup 3003';

CREATE TABLE IF NOT EXISTS `paramset` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `changeat` timestamp NOT NULL DEFAULT current_timestamp(),
  `metric` varchar(50) NOT NULL DEFAULT '',
  `value` double NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `changeat` (`changeat`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Sets a parameter at a specific ts\r\nGroup 3002';

CREATE TABLE IF NOT EXISTS `paramvals` (
  `metric` varchar(50) NOT NULL DEFAULT '',
  `value` double NOT NULL DEFAULT 0,
  `text` varchar(100) NOT NULL DEFAULT '',
  PRIMARY KEY (`metric`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Last read values from the headpump.';

CREATE TABLE IF NOT EXISTS `paramvals_unkown` (
  `luxid` int(11) NOT NULL,
  `value` double NOT NULL DEFAULT 0,
  PRIMARY KEY (`luxid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Unkown parameter values.';

CREATE TABLE IF NOT EXISTS `switchoff` (
  `ts` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `value` double NOT NULL DEFAULT 0,
  `text` varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (`ts`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='Historie der Abschaltungen';

CREATE TABLE IF NOT EXISTS `valueformat` (
  `id` int(11) NOT NULL,
  `formatstring` varchar(50) DEFAULT NULL,
  `divisor` double DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `valuemap` (
  `id` int(11) NOT NULL,
  `value` int(11) NOT NULL,
  `text` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`,`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `wscontent` (
  `id` varchar(200) NOT NULL DEFAULT '',
  `pageid` varchar(200) NOT NULL DEFAULT '',
  `value` varchar(50) DEFAULT NULL,
  `rawdata` text DEFAULT NULL,
  PRIMARY KEY (`pageid`,`id`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE IF NOT EXISTS `wspages` (
  `id` varchar(200) NOT NULL DEFAULT '',
  `rawdata` text NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `calcs_grafana` (
	`ts` TIMESTAMP(0) NOT NULL,
	`metric` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
	`description` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
	`value` DOUBLE(22,0) NULL
) ENGINE=MyISAM;

CREATE TABLE `history_grafana` (
	`ts` TIMESTAMP(0) NOT NULL,
	`metric` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
	`description` VARCHAR(50) NOT NULL COLLATE 'utf8_general_ci',
	`value` DOUBLE(22,0) NULL
) ENGINE=MyISAM;

DROP TABLE IF EXISTS `calcs_grafana`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `calcs_grafana` AS select `a`.`ts` AS `ts`,`a`.`metric` AS `metric`,`b`.`description` AS `description`,`a`.`value` AS `value` from (`calcvals_history` `a` join `calcs` `b` on(`a`.`metric` = `b`.`metric`)) ;

DROP TABLE IF EXISTS `history_grafana`;
CREATE ALGORITHM=UNDEFINED SQL SECURITY DEFINER VIEW `history_grafana` AS SELECT a.ts, a.metric, b.description, a.value FROM calcvals_history AS a INNER JOIN calcs b ON a.metric=b.metric ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
