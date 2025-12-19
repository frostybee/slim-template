-- phpMyAdmin configuration storage database and tables
-- Enables all advanced features: bookmarks, history, tracking, etc.
CREATE DATABASE IF NOT EXISTS phpmyadmin;

USE phpmyadmin;

-- Bookmark table
CREATE TABLE IF NOT EXISTS `pma__bookmark` (
    `id` int(10) unsigned NOT NULL auto_increment,
    `dbase` varchar(255) NOT NULL default '',
    `user` varchar(255) NOT NULL default '',
    `label` varchar(255) COLLATE utf8_general_ci NOT NULL default '',
    `query` text NOT NULL,
    PRIMARY KEY (`id`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;

-- Relation table
CREATE TABLE IF NOT EXISTS `pma__relation` (
    `master_db` varchar(64) NOT NULL default '',
    `master_table` varchar(64) NOT NULL default '',
    `master_field` varchar(64) NOT NULL default '',
    `foreign_db` varchar(64) NOT NULL default '',
    `foreign_table` varchar(64) NOT NULL default '',
    `foreign_field` varchar(64) NOT NULL default '',
    PRIMARY KEY (`master_db`, `master_table`, `master_field`),
    KEY `foreign_field` (`foreign_db`, `foreign_table`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;

-- Table info (display field)
CREATE TABLE IF NOT EXISTS `pma__table_info` (
    `db_name` varchar(64) NOT NULL default '',
    `table_name` varchar(64) NOT NULL default '',
    `display_field` varchar(64) NOT NULL default '',
    PRIMARY KEY (`db_name`, `table_name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;

-- Table coordinates for PDF
CREATE TABLE IF NOT EXISTS `pma__table_coords` (
    `db_name` varchar(64) NOT NULL default '',
    `table_name` varchar(64) NOT NULL default '',
    `pdf_page_number` int(11) NOT NULL default '0',
    `x` float unsigned NOT NULL default '0',
    `y` float unsigned NOT NULL default '0',
    PRIMARY KEY (`db_name`, `table_name`, `pdf_page_number`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;

-- PDF pages
CREATE TABLE IF NOT EXISTS `pma__pdf_pages` (
    `db_name` varchar(64) NOT NULL default '',
    `page_nr` int(10) unsigned NOT NULL auto_increment,
    `page_descr` varchar(50) COLLATE utf8_general_ci NOT NULL default '',
    PRIMARY KEY (`page_nr`),
    KEY `db_name` (`db_name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;

-- Column info
CREATE TABLE IF NOT EXISTS `pma__column_info` (
    `id` int(5) unsigned NOT NULL auto_increment,
    `db_name` varchar(64) NOT NULL default '',
    `table_name` varchar(64) NOT NULL default '',
    `column_name` varchar(64) NOT NULL default '',
    `comment` varchar(255) COLLATE utf8_general_ci NOT NULL default '',
    `mimetype` varchar(255) COLLATE utf8_general_ci NOT NULL default '',
    `transformation` varchar(255) NOT NULL default '',
    `transformation_options` varchar(255) NOT NULL default '',
    `input_transformation` varchar(255) NOT NULL default '',
    `input_transformation_options` varchar(255) NOT NULL default '',
    PRIMARY KEY (`id`),
    UNIQUE KEY `db_name` (`db_name`, `table_name`, `column_name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;

-- SQL history
CREATE TABLE IF NOT EXISTS `pma__history` (
    `id` bigint(20) unsigned NOT NULL auto_increment,
    `username` varchar(64) NOT NULL default '',
    `db` varchar(64) NOT NULL default '',
    `table` varchar(64) NOT NULL default '',
    `timevalue` timestamp NOT NULL default CURRENT_TIMESTAMP,
    `sqlquery` text NOT NULL,
    PRIMARY KEY (`id`),
    KEY `username` (`username`, `db`, `table`, `timevalue`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;

-- Table UI preferences
CREATE TABLE IF NOT EXISTS `pma__table_uiprefs` (
    `username` varchar(64) NOT NULL,
    `db_name` varchar(64) NOT NULL,
    `table_name` varchar(64) NOT NULL,
    `prefs` text NOT NULL,
    `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`username`, `db_name`, `table_name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;

-- Tracking
CREATE TABLE IF NOT EXISTS `pma__tracking` (
    `db_name` varchar(64) NOT NULL,
    `table_name` varchar(64) NOT NULL,
    `version` int(10) unsigned NOT NULL,
    `date_created` datetime NOT NULL,
    `date_updated` datetime NOT NULL,
    `schema_snapshot` text NOT NULL,
    `schema_sql` text,
    `data_sql` longtext,
    `tracking`
    set
(
        'UPDATE',
        'REPLACE',
        'INSERT',
        'DELETE',
        'TRUNCATE',
        'CREATE DATABASE',
        'ALTER DATABASE',
        'DROP DATABASE',
        'CREATE TABLE',
        'ALTER TABLE',
        'RENAME TABLE',
        'DROP TABLE',
        'CREATE INDEX',
        'DROP INDEX',
        'CREATE VIEW',
        'ALTER VIEW',
        'DROP VIEW'
    ) default NULL,
    `tracking_active` int(1) unsigned NOT NULL default '1',
    PRIMARY KEY (`db_name`, `table_name`, `version`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;

-- User config
CREATE TABLE IF NOT EXISTS `pma__userconfig` (
    `username` varchar(64) NOT NULL,
    `timevalue` timestamp NOT NULL default CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    `config_data` text NOT NULL,
    PRIMARY KEY (`username`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;

-- Recent tables
CREATE TABLE IF NOT EXISTS `pma__recent` (
    `username` varchar(64) NOT NULL,
    `tables` text NOT NULL,
    PRIMARY KEY (`username`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;

-- Favorite tables
CREATE TABLE IF NOT EXISTS `pma__favorite` (
    `username` varchar(64) NOT NULL,
    `tables` text NOT NULL,
    PRIMARY KEY (`username`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;

-- Users
CREATE TABLE IF NOT EXISTS `pma__users` (
    `username` varchar(64) NOT NULL,
    `usergroup` varchar(64) NOT NULL,
    PRIMARY KEY (`username`, `usergroup`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;

-- User groups
CREATE TABLE IF NOT EXISTS `pma__usergroups` (
    `usergroup` varchar(64) NOT NULL,
    `tab` varchar(64) NOT NULL,
    `allowed` enum('Y', 'N') NOT NULL DEFAULT 'N',
    PRIMARY KEY (`usergroup`, `tab`, `allowed`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;

-- Navigation hiding
CREATE TABLE IF NOT EXISTS `pma__navigationhiding` (
    `username` varchar(64) NOT NULL,
    `item_name` varchar(64) NOT NULL,
    `item_type` varchar(64) NOT NULL,
    `db_name` varchar(64) NOT NULL,
    `table_name` varchar(64) NOT NULL,
    PRIMARY KEY (
        `username`,
        `item_name`,
        `item_type`,
        `db_name`,
        `table_name`
    )
) ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;

-- Saved searches
CREATE TABLE IF NOT EXISTS `pma__savedsearches` (
    `id` int(5) unsigned NOT NULL auto_increment,
    `username` varchar(64) NOT NULL default '',
    `db_name` varchar(64) NOT NULL default '',
    `search_name` varchar(64) NOT NULL default '',
    `search_data` text NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `u_savedsearches_username_dbname` (`username`, `db_name`, `search_name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;

-- Central columns
CREATE TABLE IF NOT EXISTS `pma__central_columns` (
    `db_name` varchar(64) NOT NULL,
    `col_name` varchar(64) NOT NULL,
    `col_type` varchar(64) NOT NULL,
    `col_length` text,
    `col_collation` varchar(64) NOT NULL,
    `col_isNull` boolean NOT NULL,
    `col_extra` varchar(255) default '',
    `col_default` text,
    PRIMARY KEY (`db_name`, `col_name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;

-- Designer settings
CREATE TABLE IF NOT EXISTS `pma__designer_settings` (
    `username` varchar(64) NOT NULL,
    `settings_data` text NOT NULL,
    PRIMARY KEY (`username`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;

-- Export templates
CREATE TABLE IF NOT EXISTS `pma__export_templates` (
    `id` int(5) unsigned NOT NULL AUTO_INCREMENT,
    `username` varchar(64) NOT NULL,
    `export_type` varchar(10) NOT NULL,
    `template_name` varchar(64) NOT NULL,
    `template_data` text NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `u_user_type_template` (`username`, `export_type`, `template_name`)
) ENGINE = InnoDB DEFAULT CHARSET = utf8 COLLATE = utf8_bin;
