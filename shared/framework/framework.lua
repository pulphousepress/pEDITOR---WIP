-- resources/la_peditor/shared/framework/framework.lua
-- theme="1950s-cartoon-noir"
-- QBox/QB bridge (namespaced). Defensive: will not error if QBCore not present.

if not la_peditor then la_peditor = {} end
la_peditor.Framework = la_peditor.Framework or {}
local Framework = la_peditor.Framework
local isServer = IsDuplicityVersion and IsDuplicityVersion() or false

-- Try to acquire QBCore (supports qb-core and qbx_core). Do not force global.
local function getQBCore()
    if la_peditor and la_peditor.QBCore then return la_peditor.QBCore end
    if exports then
        if exports['qb-core'] and type(exports['qb-core'].GetCoreObject) == "function" then
            return exports['qb-core']:GetCoreObject()
        end
        if exports['qbx_core'] and type(exports['qbx_core'].GetCoreObject) == "function" then
            return exports['qbx_core']:GetCoreObject()
        end
        if exports['qbx-core'] and type(exports['qbx-core'].GetCoreObject) == "function" then
            return exports['qbx-core']:GetCoreObject()
        end
    end
    if rawget(_G, 'QBCore') then
        return rawget(_G, 'QBCore')
    end
    return nil
end

Framework._coreCallbacks = Framework._coreCallbacks or {}

local function onCoreBound(core)
    if not core then return end
    la_peditor.QBCore = core
    Framework.qb = core
    if Framework._coreCallbacks then
        for _, cb in ipairs(Framework._coreCallbacks) do
            pcall(cb, core)
        end
        Framework._coreCallbacks = {}
    end
end

Framework.qb = getQBCore()
if not Framework.qb then
    CreateThread(function()
        local tries = 0
        while not Framework.qb and tries < 25 do
            Framework.qb = getQBCore()
            tries = tries + 1
            Wait(200)
        end
        if not Framework.qb then
            print("[la_peditor/framework] QBCore not bound — some features will be limited.")
        else
            print("[la_peditor/framework] QBCore bound (deferred).")
            onCoreBound(Framework.qb)
        end
    end)
else
    print("[la_peditor/framework] QBCore bound.")
    onCoreBound(Framework.qb)
end

function Framework.GetCoreObject()
    if Framework.qb then return Framework.qb end
    Framework.qb = getQBCore()
    if Framework.qb then
        onCoreBound(Framework.qb)
    end
    return Framework.qb
end

function Framework.WhenCoreReady(cb)
    if type(cb) ~= 'function' then return end
    if Framework.qb then
        cb(Framework.qb)
        return
    end
    Framework._coreCallbacks = Framework._coreCallbacks or {}
    Framework._coreCallbacks[#Framework._coreCallbacks + 1] = cb
end

-- Protected function wrappers
function Framework.GetPlayer(source)
    local qb = Framework.GetCoreObject()
    if not qb or type(qb.Functions.GetPlayer) ~= "function" then return nil end
    local ok, player = pcall(qb.Functions.GetPlayer, source)
    if ok then return player end
    return nil
end

function Framework.HasTracker(source)
    if isServer then
        local player = Framework.GetPlayer(source)
        if not player or not player.PlayerData or not player.PlayerData.metadata then return false end
        return player.PlayerData.metadata["tracker"] == true
    end
    if type(Framework.GetPlayerData) == 'function' then
        local ok, pdata = pcall(Framework.GetPlayerData)
        if ok and pdata and pdata.metadata then
            return pdata.metadata['tracker'] == true
        end
    end
    return false
end

function Framework.GetIdentifier(source)
    local player = Framework.GetPlayer(source)
    if not player or not player.PlayerData then return nil end
    return player.PlayerData.citizenid
end

function Framework.GetName(source)
    local player = Framework.GetPlayer(source)
    if not player or not player.PlayerData or not player.PlayerData.charinfo then return "Unknown" end
    return ("%s %s"):format(player.PlayerData.charinfo.firstname or "?", player.PlayerData.charinfo.lastname or "?")
end

function Framework.IsBoss(source)
    local player = Framework.GetPlayer(source)
    if not player or not player.PlayerData or not player.PlayerData.job then return false end
    return player.PlayerData.job.isboss == true
end

function Framework.GetJob(source)
    local player = Framework.GetPlayer(source)
    if not player or not player.PlayerData or not player.PlayerData.job then return nil end
    return player.PlayerData.job.name
end

function Framework.GetGang(source)
    local player = Framework.GetPlayer(source)
    if not player or not player.PlayerData or not player.PlayerData.gang then return nil end
    return player.PlayerData.gang.name
end

function Framework.Notify(src, msg, typ)
    -- Use QBCore notify if available, else fallback to chat message.
    local qb = Framework.GetCoreObject()
    if qb and type(qb.Functions.Notify) == "function" then
        pcall(function() qb.Functions.Notify(src, msg, typ) end)
        return
    end
    -- fallback: trigger the legacy event
    pcall(function() TriggerClientEvent('QBCore:Notify', src, msg, typ or 'primary') end)
end

if not isServer then
    function Framework.GetPlayerData()
        local qb = Framework.GetCoreObject()
        if qb and qb.Functions and type(qb.Functions.GetPlayerData) == 'function' then
            local ok, data = pcall(qb.Functions.GetPlayerData)
            if ok then return data end
        end
        return nil
    end
end

-- Explicit compatibility shim for older code that expects Framework global.
-- This is an intentional, visible shim; remove it when migrating other code.
_G.la_peditor_Framework = la_peditor.Framework

print('[la_peditor/shared/framework/framework.lua] QBox bridge initialized — theme="1950s-cartoon-noir"')
return la_peditor.Framework
