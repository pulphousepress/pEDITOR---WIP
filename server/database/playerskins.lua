-- server/database/playerskins.lua
-- theme="1950s-cartoon-noir"
-- playerskins table helpers

if not la_peditor then la_peditor = {} end
la_peditor.Database = la_peditor.Database or require("la_peditor.server.database.database")
local Database = la_peditor.Database
Database.PlayerSkins = Database.PlayerSkins or {}

function Database.PlayerSkins.Add(citizenid, model, skin, active)
    Database.Execute([[
        INSERT INTO playerskins (citizenid, model, skin, active)
        VALUES (?, ?, ?, ?)
    ]], {
        citizenid,
        model,
        skin,
        active and 1 or 0
    })
end

function Database.PlayerSkins.DeleteByCitizenID(citizenid)
    Database.Execute([[
        DELETE FROM playerskins
        WHERE citizenid = ?
    ]], { citizenid })
end

function Database.PlayerSkins.GetAll()
    return Database.FetchAll("SELECT * FROM playerskins")
end

return Database.PlayerSkins
