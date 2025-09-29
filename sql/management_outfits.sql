-- la_peditor/sql/management_outfits.sql
-- theme="1950s-cartoon-noir"
-- Stores job/gang management outfits (Boss-managed uniforms)
CREATE TABLE IF NOT EXISTS `la_management_outfits` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `type` VARCHAR(16) NOT NULL, -- 'Job' or 'Gang'
  `job_name` VARCHAR(64),
  `gender` VARCHAR(8),
  `rank_min` INT DEFAULT 0,
  `name` VARCHAR(128) NOT NULL,
  `model` VARCHAR(64),
  `components` JSON,
  `props` JSON,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  INDEX (`job_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
