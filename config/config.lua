-- la_peditor/config/config.lua
Config = Config or {}

Config.Debug = false

-- Default gender fallback for new characters without stored gender
-- Accepts 'm' or 'f'
Config.DefaultGender = 'm'

-- Whether to auto open PEDitor when a brand new character spawns
Config.AutoOpenOnFirstSpawn = false

-- Which appearance backend to use at runtime:
--   'peditor'   - direct use of PEDitor
--   'illenium'  - drive from illenium-appearance where possible
Config.AppearanceBackend = 'peditor'
