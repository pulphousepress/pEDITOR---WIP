-- la_peditor/sql/playerskins.sql
-- theme="1950s-cartoon-noir"
-- Stores primary player skin / appearance records.
CREATE TABLE IF NOT EXISTS `la_player_skins` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `citizenid` VARCHAR(64) NOT NULL,
  `model` VARCHAR(64) NOT NULL,
  `appearance` JSON NOT NULL,
  `is_default` TINYINT(1) DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX (`citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
