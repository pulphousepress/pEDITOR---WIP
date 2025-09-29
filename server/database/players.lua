-- server/database/players.lua
-- theme="1950s-cartoon-noir"
-- Players table helpers (for migration / audits)

if not la_peditor then la_peditor = {} end
la_peditor.Database = la_peditor.Database or require("la_peditor.server.database.database")
local Database = la_peditor.Database
Database.Players = Database.Players or {}

function Database.Players.GetAll()
    return Database.FetchAll([[
        SELECT citizenid, skin FROM players
        WHERE skin IS NOT NULL
    ]])
end

function Database.Players.GetByCitizenID(citizenid)
    return Database.FetchAll([[
        SELECT * FROM players
        WHERE citizenid = ?
    ]], { citizenid })
end

return Database.Players
