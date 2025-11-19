-- server/framework/qb/main.lua
-- theme="1950s-cartoon-noir"
-- QB-specific server glue: QBCore callbacks / helper events (defensive)

if not la_peditor then la_peditor = {} end
la_peditor.Framework = la_peditor.Framework or {}
local Framework = la_peditor.Framework

-- Defensive QBCore detection (supports qb-core and qbx_core)
local function getQBCore()
    if la_peditor and la_peditor.GetCoreObject then
        return la_peditor.GetCoreObject()
    end
    return nil
end

local QBCore = getQBCore()
local function safeLog(lvl, ...)
    if la_peditor and type(la_peditor.log) == "function" then
        la_peditor.log(lvl, ...)
    else
        print("[la_peditor] " .. table.concat({...}, " "))
    end
end

if not QBCore then
    safeLog("info", "QBCore not found — qb-framework shims will not register. This is OK if you use a different framework.")
    return
end

-- Example QBCore-based save handler.
-- NOTE: server/server.lua already defines la_peditor:saveAppearance which persists to DB.
-- We expose a QB callback to fetch appearance if other QB scripts expect it.
QBCore.Functions.CreateCallback("la_peditor:getAppearance", function(source, cb)
    -- Try to fetch from our DB (Database.PlayerSkins / player outfits) if available
    local Database = la_peditor.Database
    if Database and Database.PlayerSkins and type(Database.PlayerSkins.GetAll) == "function" then
        -- Attempt to find by player's citizenid (QBCore player data)
        local Player = QBCore.Functions.GetPlayer(source)
        if Player and Player.PlayerData and Player.PlayerData.citizenid then
            local citizenid = Player.PlayerData.citizenid
            local skins = Database.PlayerSkins.GetAll() or {}
            for _, s in ipairs(skins) do
                if tostring(s.citizenid) == tostring(citizenid) and s.active == 1 then
                    local ok, decoded = pcall(function() return json.decode(s.skin) end)
                    if ok and type(decoded) == "table" then
                        cb(decoded)
                        return
                    end
                end
            end
        end
    end
    -- fallback empty
    cb({})
end)

-- If additional QB handlers are required, add them here (defensive pcall wrappers)
RegisterNetEvent("la_peditor:qb:saveAppearance", function(data)
    local src = source
    if not data or type(data) ~= "table" then
        safeLog("warn", "la_peditor:qb:saveAppearance called with invalid data from " .. tostring(src))
        return
    end
    -- prefer the primary server-side save path
    TriggerEvent("la_peditor:saveAppearance", data)
    safeLog("info", ("Saved appearance via qb shim for source=%s"):format(tostring(src)))
end)

safeLog("info", "server/framework/qb/main.lua loaded — QBCore-specific shims active")
