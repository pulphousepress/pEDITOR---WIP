-- server/database/users.lua
-- theme="1950s-cartoon-noir"
-- Users / players utility helpers (renamed to Database.Users to avoid clobbering Database.Players)

if not la_peditor then la_peditor = {} end
la_peditor.Database = la_peditor.Database or require("la_peditor.server.database.database")
local Database = la_peditor.Database
Database.Users = Database.Users or {}

function Database.Users.GetAll()
    return Database.FetchAll("SELECT * FROM players")
end

function Database.Users.GetSkin(citizenid)
    local result = Database.FetchAll("SELECT skin FROM players WHERE citizenid = ?", { citizenid })
    return result[1] and result[1].skin or nil
end

function Database.Users.UpdateSkin(citizenid, skin)
    Database.Execute("UPDATE players SET skin = ? WHERE citizenid = ?", { skin, citizenid })
end

return Database.Users
