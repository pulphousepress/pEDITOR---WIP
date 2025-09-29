-- server/database/playeroutfitcodes.lua
-- theme="1950s-cartoon-noir"
-- Player outfit codes persisted per citizenid

if not la_peditor then la_peditor = {} end
la_peditor.Database = la_peditor.Database or require("la_peditor.server.database.database")
local Database = la_peditor.Database
Database.PlayerOutfitCodes = Database.PlayerOutfitCodes or {}

function Database.PlayerOutfitCodes.GetAll(citizenid)
    return Database.FetchAll([[
        SELECT * FROM player_outfit_codes
        WHERE citizenid = ?
        ORDER BY code ASC
    ]], { citizenid })
end

function Database.PlayerOutfitCodes.Upsert(citizenid, code, label, model, appearance)
    Database.Execute([[
        REPLACE INTO player_outfit_codes (citizenid, code, label, model, appearance)
        VALUES (?, ?, ?, ?, ?)
    ]], { citizenid, code, label, model, json.encode(appearance) })
end

function Database.PlayerOutfitCodes.Delete(citizenid, code)
    Database.Execute([[
        DELETE FROM player_outfit_codes
        WHERE citizenid = ? AND code = ?
    ]], { citizenid, code })
end

return Database.PlayerOutfitCodes
