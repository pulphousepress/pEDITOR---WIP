-- client/target/ox.lua
-- theme="1950s-cartoon-noir"
-- la_peditor: ox_target adapter for target zone interactions
-- Hardened: defensive exports, idempotent registration

if not la_peditor then la_peditor = {} end
local la = la_peditor
local M = {}
local createdZones = {}

local function export_call(exportObj, methodNames, ...)
    if not exportObj then return nil, "no export" end
    for _, name in ipairs(methodNames) do
        local fn = exportObj[name]
        if type(fn) == "function" then
            local ok, res = pcall(fn, ...)
            if ok then return res end
            return nil, res
        end
    end
    return nil, "no-matching-method"
end

local function addBoxZone(store)
    local target = exports and exports['ox_target']
    if not target then return nil, "no-ox-target" end

    local coords = store.coords or {}
    local size = vector3(store.width or 2.0, store.length or 2.0, store.height or 2.0)
    local rotation = store.heading or 0.0

    local options = {
        name = ("la_peditor_store_%s_%s"):format(store.type or "unknown", tostring(store.id or "0")),
        debugPoly = store.debug or false,
        useZ = true,
        onEnter = function(entity, distance) TriggerEvent("la_peditor:client:onTargetEnter", store) end,
        onExit = function(entity, distance) TriggerEvent("la_peditor:client:onTargetExit", store) end,
        options = {
            {
                name = "la_peditor_open_store_" .. tostring(store.id or ""),
                label = store.label or ("Open " .. tostring(store.type or "store")),
                icon = store.icon or "fa-solid fa-shirtsinbulk",
                onSelect = function(data) TriggerEvent("la_peditor:client:openClothingShopMenu", false) end,
                canInteract = function(entity, distance, coords, name)
                    if store.job and store.job ~= nil then
                        local pd = nil
                        pcall(function() pd = exports['qb-core']:GetCoreObject().Functions.GetPlayerData() end)
                        if not (pd and pd.job and pd.job.name == store.job) then return false end
                    end
                    if store.gang and store.gang ~= nil then
                        local pd = nil
                        pcall(function() pd = exports['qb-core']:GetCoreObject().Functions.GetPlayerData() end)
                        if not (pd and pd.gang and pd.gang.name == store.gang) then return false end
                    end
                    return true
                end
            }
        }
    }

    local ok, token = pcall(function()
        return export_call(target, { "addBoxZone", "AddBoxZone", "addBox", "AddBox", "AddBoxZone" }, coords, size, rotation, options)
    end)

    if ok and token then
        createdZones[options.name] = token
        return token
    end

    local ok2, token2 = pcall(function()
        return export_call(target, { "addBox" }, {
            coords = coords, size = size, rotation = rotation, debug = store.debug, options = options
        })
    end)

    if ok2 and token2 then
        createdZones[options.name] = token2
        return token2
    end

    return nil, "failed-register"
end

local function removeZoneByName(name)
    if not createdZones[name] then return false end
    local target = exports and exports['ox_target']
    if not target then
        createdZones[name] = nil
        return true
    end
    pcall(function()
        export_call(target, { "removeZone", "remove", "RemoveZone", "removeBoxZone" }, createdZones[name])
    end)
    createdZones[name] = nil
    return true
end

function M.RegisterTargets(stores)
    if type(stores) ~= "table" then return end
    for _, store in ipairs(stores) do
        if store and not store.disableTarget then
            local name = ("la_peditor_store_%s_%s"):format(store.type or "unknown", tostring(store.id or "0"))
            if createdZones[name] then
                removeZoneByName(name)
            end
            local token, err = addBoxZone(store)
            if token then
                la.log('info', ("[ox_target] Registered zone: %s"):format(name))
            else
                la.log('warn', ("[ox_target] Failed to register zone %s: %s"):format(name, tostring(err)))
            end
        end
    end
end

function M.RemoveAll()
    for name, _ in pairs(createdZones) do
        pcall(function() removeZoneByName(name) end)
    end
    createdZones = {}
end

return M
