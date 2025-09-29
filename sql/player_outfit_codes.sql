-- la_peditor/sql/player_outfit_codes.sql
-- theme="1950s-cartoon-noir"
-- Stores exported outfit codes (for share/import)
CREATE TABLE IF NOT EXISTS `la_outfit_codes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `code` VARCHAR(64) NOT NULL UNIQUE,
  `owner` VARCHAR(64),
  `payload` JSON NOT NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
