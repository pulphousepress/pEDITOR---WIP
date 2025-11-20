-- server/framework/qb/main.lua
-- theme="1950s-cartoon-noir"
-- QB-specific server glue: QBCore callbacks / helper events (defensive)

if not la_peditor then la_peditor = {} end
la_peditor.Framework = la_peditor.Framework or {}
local Framework = la_peditor.Framework
local QBCore = nil
local qbRegistered = false
local function safeLog(lvl, ...)
    if la_peditor and type(la_peditor.log) == "function" then
        la_peditor.log(lvl, ...)
    else
        print("[la_peditor] " .. table.concat({...}, " "))
    end
end

local function registerShims(core)
    if qbRegistered or not core then return end
    qbRegistered = true
    QBCore = core

    QBCore.Functions.CreateCallback("la_peditor:getAppearance", function(source, cb)
        local Database = la_peditor.Database
        if Database and Database.PlayerSkins and type(Database.PlayerSkins.GetAll) == "function" then
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
        cb({})
    end)

    RegisterNetEvent("la_peditor:qb:saveAppearance", function(data)
        local src = source
        if not data or type(data) ~= "table" then
            safeLog("warn", "la_peditor:qb:saveAppearance called with invalid data from " .. tostring(src))
            return
        end
        TriggerEvent("la_peditor:saveAppearance", data)
        safeLog("info", ("Saved appearance via qb shim for source=%s"):format(tostring(src)))
    end)

    safeLog("info", "server/framework/qb/main.lua loaded — QBCore-specific shims active")
end

local function init()
    if Framework and type(Framework.GetCoreObject) == 'function' then
        local ok, core = pcall(Framework.GetCoreObject)
        if ok and core then
            registerShims(core)
            return
        end
    end
    if Framework and type(Framework.WhenCoreReady) == 'function' then
        Framework.WhenCoreReady(function(core)
            registerShims(core)
        end)
    else
        local fallback = nil
        if exports and exports['qb-core'] and type(exports['qb-core'].GetCoreObject) == 'function' then
            fallback = exports['qb-core']:GetCoreObject()
        elseif exports and exports['qbx_core'] and type(exports['qbx_core'].GetCoreObject) == 'function' then
            fallback = exports['qbx_core']:GetCoreObject()
        elseif rawget(_G, 'QBCore') then
            fallback = rawget(_G, 'QBCore')
        end
        if fallback then
            registerShims(fallback)
        else
            safeLog("info", "QBCore not found — qb-framework shims will not register. This is OK if you use a different framework.")
        end
    end
end

init()
