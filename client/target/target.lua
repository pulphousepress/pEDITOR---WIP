-- client/target/target.lua
-- theme="1950s-cartoon-noir"
-- la_peditor: orchestrator for available target adapters (ox_target / qtarget / qb-target)
-- Hardened, namespaced orchestrator.

if not la_peditor then la_peditor = {} end
local la = la_peditor
local adapter = nil
local adapterName = nil

local function tryRequire(path)
    local ok, mod = pcall(function() return require(path) end)
    if ok and type(mod) == "table" then return mod end
    return nil
end

local oxAdapter = tryRequire("client.target.ox")
local qbAdapter = tryRequire("client.target.qb")

local function detectAdapter()
    if exports and exports['ox_target'] then
        if oxAdapter and type(oxAdapter.RegisterTargets) == "function" then
            adapter = oxAdapter; adapterName = "ox_target"; return
        end
    end
    if exports and (exports['qtarget'] or exports['qb-target'] or exports['qb_target']) then
        if qbAdapter and type(qbAdapter.RegisterTargets) == "function" then
            adapter = qbAdapter; adapterName = "qtarget"; return
        end
    end
    if oxAdapter then adapter = oxAdapter; adapterName = "ox_adapter_fallback"; return end
    if qbAdapter then adapter = qbAdapter; adapterName = "qb_adapter_fallback"; return end
    adapter = nil; adapterName = nil
end

local function registerStores()
    if type(la.Config) ~= "table" or type(la.Config.Stores) ~= "table" then
        la.log('info', '[target] No Config.Stores defined; skipping target registration')
        return
    end
    detectAdapter()
    if not adapter or type(adapter.RegisterTargets) ~= "function" then
        la.log('info', '[target] No target adapter available (ox_target/qtarget). Skipping.')
        return
    end
    local ok, err = pcall(function() adapter.RegisterTargets(la.Config.Stores) end)
    if not ok then
        la.log('warn', ("[target] Adapter '%s' failed to register targets: %s"):format(tostring(adapterName), tostring(err)))
    else
        la.log('info', ("[target] Registered targets via adapter: %s"):format(tostring(adapterName)))
    end
end

function RefreshTargets()
    if adapter and type(adapter.RemoveAll) == "function" then pcall(function() adapter.RemoveAll() end) end
    registerStores()
end

CreateThread(function()
    Wait(1000)
    registerStores()
end)

RegisterNetEvent("la_peditor:client:refreshTargets", function() RefreshTargets() end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    if adapter and type(adapter.RemoveAll) == "function" then pcall(function() adapter.RemoveAll() end) end
end)

exports('RefreshTargets', RefreshTargets)
la.log('info', 'client/target module loaded — theme="1950s-cartoon-noir"')
