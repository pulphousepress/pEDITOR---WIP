-- la_peditor/sql/player_outfits.sql
-- theme="1950s-cartoon-noir"
-- Stores player-saved outfits (named presets)
CREATE TABLE IF NOT EXISTS `la_player_outfits` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `citizenid` VARCHAR(64) NOT NULL,
  `name` VARCHAR(128) NOT NULL,
  `gender` VARCHAR(16),
  `model` VARCHAR(64),
  `components` JSON,
  `props` JSON,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX (`citizenid`),
  UNIQUE (`citizenid`, `name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
