-- client/stats.lua
-- theme="1950s-cartoon-noir"
-- la_peditor: safe player stats backup & restore

if not la_peditor then la_peditor = {} end
local la = la_peditor
local Config = la.Config or {}

local stats = nil

local function getPed()
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) then return nil end
    return ped
end

local function getPlayer()
    return PlayerId()
end

local function ResetRechargeMultipliers()
    local player = getPlayer()
    if not player then return end
    pcall(function() SetPlayerHealthRechargeMultiplier(player, 0.0) end)
    pcall(function() SetPlayerHealthRechargeLimit(player, 0.0) end)
end

local function BackupPlayerStats()
    local ped = getPed()
    if not ped then
        la.log('warn', 'BackupPlayerStats: no valid ped found')
        return
    end

    stats = {
        health = GetEntityHealth(ped),
        armour = GetPedArmour(ped)
    }

    if Config and Config.Debug then
        la.log('debug', ("Backed up stats — health=%s armour=%s"):format(tostring(stats.health), tostring(stats.armour)))
    end
end

local function RestorePlayerStats()
    local ped = getPed()
    if stats and ped then
        pcall(function() SetEntityMaxHealth(ped, 200) end)
        CreateThread(function()
            Wait(1000)
            if not DoesEntityExist(ped) then return end
            pcall(function() SetEntityHealth(ped, tonumber(stats.health) or 200) end)
            pcall(function() SetPedArmour(ped, tonumber(stats.armour) or 0) end)
            ResetRechargeMultipliers()
            if Config and Config.Debug then
                la.log('debug', ("Restored stats — health=%s armour=%s"):format(tostring(stats.health), tostring(stats.armour)))
            end
            stats = nil
        end)
        return
    end

    if type(la.Framework) == "table" and type(la.Framework.RestorePlayerArmour) == "function" then
        pcall(la.Framework.RestorePlayerArmour)
        if Config and Config.Debug then la.log('debug', 'RestorePlayerStats: delegated to Framework.RestorePlayerArmour()') end
        return
    end

    ResetRechargeMultipliers()
    if Config and Config.Debug then la.log('debug', 'RestorePlayerStats: applied safe defaults') end
end

exports('BackupPlayerStats', BackupPlayerStats)
exports('RestorePlayerStats', RestorePlayerStats)
exports('ResetRechargeMultipliers', ResetRechargeMultipliers)

RegisterNetEvent('la_peditor:client:BackupPlayerStats', BackupPlayerStats)
RegisterNetEvent('la_peditor:client:RestorePlayerStats', RestorePlayerStats)

la.log('info', 'client/stats.lua loaded')
