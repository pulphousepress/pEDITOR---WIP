-- server/database/playeroutfits.lua
-- theme="1950s-cartoon-noir"
-- Saved player outfits management

if not la_peditor then la_peditor = {} end
la_peditor.Database = la_peditor.Database or require("la_peditor.server.database.database")
local Database = la_peditor.Database
Database.PlayerOutfits = Database.PlayerOutfits or {}

function Database.PlayerOutfits.GetAll(citizenid)
    return Database.FetchAll([[
        SELECT * FROM player_outfits
        WHERE citizenid = ?
        ORDER BY created_at DESC
    ]], { citizenid })
end

function Database.PlayerOutfits.Upsert(id, citizenid, name, model, appearance, slot)
    Database.Execute([[
        REPLACE INTO player_outfits (id, citizenid, name, model, appearance, slot)
        VALUES (?, ?, ?, ?, ?, ?)
    ]], { id, citizenid, name, model, json.encode(appearance), slot })
end

function Database.PlayerOutfits.Delete(id)
    Database.Execute([[
        DELETE FROM player_outfits WHERE id = ?
    ]], { id })
end

function Database.PlayerOutfits.Rename(id, newName)
    Database.Execute([[
        UPDATE player_outfits
        SET name = ?
        WHERE id = ?
    ]], { newName, id })
end

return Database.PlayerOutfits
