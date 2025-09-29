-- server/database/managementoutfits.lua
-- theme="1950s-cartoon-noir"
-- Management outfit DB helpers

if not la_peditor then la_peditor = {} end
la_peditor.Database = la_peditor.Database or require("la_peditor.server.database.database")
local Database = la_peditor.Database
Database.ManagementOutfits = Database.ManagementOutfits or {}

function Database.ManagementOutfits.GetAll(type_, name)
    return Database.FetchAll([[
        SELECT * FROM management_outfits
        WHERE type = ? AND name = ?
        ORDER BY label ASC
    ]], { type_, name })
end

function Database.ManagementOutfits.Add(type_, name, label, model, data)
    Database.Execute([[
        INSERT INTO management_outfits (type, name, label, model, data)
        VALUES (?, ?, ?, ?, ?)
    ]], { type_, name, label, model, json.encode(data) })
end

function Database.ManagementOutfits.Delete(id)
    Database.Execute([[
        DELETE FROM management_outfits WHERE id = ?
    ]], { id })
end

return Database.ManagementOutfits
