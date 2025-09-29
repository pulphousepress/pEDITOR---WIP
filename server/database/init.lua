-- server/database/init.lua
-- theme="1950s-cartoon-noir"
-- Minimal Database stub for la_peditor.
-- Purpose: satisfy server-side code that expects Database.* APIs so migrations and other logic can run
-- safely when a production DB adapter is not yet installed.
-- TODO: Replace this stub with a real DB adapter (oxmysql / ghmattimysql / mysql-async) and implement
--       the functions below to read/write real rows (see the commented sample further down).

-- Do not leak secrets. This file intentionally performs no SQL operations by default.

local Database = {}
Database.__version = "stub-0.1"

-- Players API (used by migration)
Database.Players = {}
function Database.Players.GetAll()
    -- Return an empty list if no real DB adapter is installed.
    -- If you want to integrate with a database, replace this function with a real query that returns:
    -- { { citizenid = "CHAR123", skin = '{"model":"mp_m_freemode_01", ... }' }, ... }
    print('[la_peditor][Database] Players.GetAll called (stub) — returning empty table. theme="1950s-cartoon-noir"')
    return {}
end

-- PlayerSkins API (minimal used by migration)
Database.PlayerSkins = {}
function Database.PlayerSkins.Add(citizenID, model, appearance_json, is_default)
    print(('[la_peditor][Database] PlayerSkins.Add called (stub) citizenID=%s model=%s is_default=%s theme="1950s-cartoon-noir"'):format(
        tostring(citizenID), tostring(model), tostring(is_default)
    ))
    -- No-op in stub
    return true
end

function Database.PlayerSkins.GetAll()
    print('[la_peditor][Database] PlayerSkins.GetAll called (stub) — returning empty table. theme="1950s-cartoon-noir"')
    return {}
end

function Database.PlayerSkins.DeleteByCitizenID(citizenID)
    print(('[la_peditor][Database] PlayerSkins.DeleteByCitizenID called (stub) citizenID=%s theme="1950s-cartoon-noir"'):format(tostring(citizenID)))
    return true
end

-- PlayerOutfits API (minimal)
Database.PlayerOutfits = {}
function Database.PlayerOutfits.GetByCitizenID(citizenID)
    print(('[la_peditor][Database] PlayerOutfits.GetByCitizenID called (stub) citizenID=%s theme="1950s-cartoon-noir"'):format(tostring(citizenID)))
    return {}
end

function Database.PlayerOutfits.Add(citizenID, name, gender, model, components_json, props_json)
    print(('[la_peditor][Database] PlayerOutfits.Add called (stub) citizenID=%s name=%s theme="1950s-cartoon-noir"'):format(tostring(citizenID), tostring(name)))
    return true
end

-- ManagementOutfits API (minimal)
Database.ManagementOutfits = {}
function Database.ManagementOutfits.GetFor(typeName, jobOrGang)
    print(('[la_peditor][Database] ManagementOutfits.GetFor called (stub) type=%s jobOrGang=%s theme="1950s-cartoon-noir"'):format(tostring(typeName), tostring(jobOrGang)))
    return {}
end

function Database.ManagementOutfits.Add(data)
    print('[la_peditor][Database] ManagementOutfits.Add called (stub) theme="1950s-cartoon-noir"')
    return true
end

-- Expose globally (server-side)
_G.Database = Database

print('[la_peditor] Database stub loaded — no real DB adapter attached. Replace server/database/init.lua with a real adapter when ready. theme="1950s-cartoon-noir"')

--[[
SAMPLE (commented) — Example replacement using oxmysql (only use after verifying your server has oxmysql and
table names match your schema). This is a guide for implementing the real adapter.

-- Example using oxmysql (uncomment and adapt to your environment):
local MySQL = MySQL -- provided by @oxmysql/lib/MySQL.lua
Database.Players.GetAll = function()
    if not MySQL or not MySQL.query then
        print('[la_peditor][Database] oxmysql not available')
        return {}
    end
    local rows = MySQL.query.await('SELECT citizenid, skin FROM la_player_skins') -- adapt table name
    if not rows then return {} end
    return rows
end

Database.PlayerSkins.Add = function(citizenID, model, appearance_json, is_default)
    MySQL.update.await('INSERT INTO la_player_skins (citizenid, model, appearance, is_default) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE appearance = VALUES(appearance), model = VALUES(model)', { citizenID, model, appearance_json, tonumber(is_default) })
    return true
end

-- Remember to `require` or use MySQL only if oxmysql is loaded via fxmanifest and the server has it installed.
-- Also test queries against your actual schema and tune indexes.
--]]

