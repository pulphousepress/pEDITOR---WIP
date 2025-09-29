-- client/management/qbx.lua
-- theme="1950s-cartoon-noir"
-- QB/QBox specific helpers for management UI (rank values, boss checks)
-- Hardened, namespaced.

if not la_peditor then la_peditor = {} end
local la = la_peditor
la.Framework = la.Framework or {}
local Framework = la.Framework

local QBCore = nil
pcall(function() if exports and exports['qb-core'] then QBCore = exports['qb-core']:GetCoreObject() end end)

function Framework.GetRankInputValues(typeStr)
    local out = {}
    -- default conservative range 0..10
    for i = 0, 10 do
        out[#out + 1] = { label = tostring(i), value = tostring(i) }
    end
    return out
end

function Framework.IsPlayerBoss()
    if not QBCore then return false end
    local pd = nil
    pcall(function() pd = QBCore.Functions.GetPlayerData() end)
    if not pd or not pd.job then return false end
    return pd.job.isboss == true
end

la.log('info', 'client/management/qbx.lua loaded — theme="1950s-cartoon-noir"')
