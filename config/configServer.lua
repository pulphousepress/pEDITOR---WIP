-- la_peditor/config/server/configServer.lua
ConfigServer = ConfigServer or {}

-- Number of threads PEDitor uses to load tiles faster.
-- Keep at or below your server CPU thread count.
-- PEDitor itself reads this global.
ConfigServer.TileLoadingThreads = 4

-- You can tweak this later:

-- Low end
-- ConfigServer.TileLoadingThreads = 2

-- High end
-- ConfigServer.TileLoadingThreads = 6
