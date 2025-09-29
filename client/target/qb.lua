-- client/target/qb.lua
-- theme="1950s-cartoon-noir"
-- la_peditor: qtarget adapter for target interactions (qb-target / q-target compatible)
-- Hardened and namespaced.

if not la_peditor then la_peditor = {} end
local la = la_peditor
local M = {}
local created = {}

local function tryExportAdd(exportObj, methodList, ...)
    if not exportObj then return nil, "no-export" end
    for _, name in ipairs(methodList) do
        local fn = exportObj[name]
        if type(fn) == "function" then
            local ok, res = pcall(fn, ...)
            if ok then return res end
            return nil, res
        end
    end
    return nil, "no-method"
end

local function registerBoxZone(store)
    local qtarget = exports['qtarget'] or exports['qb-target'] or exports['qb_target']
    if not qtarget then return nil, "no-qtarget" end

    local name = ("la_peditor_store_%s_%s"):format(store.type or "unknown", tostring(store.id or "0"))
    local coords = store.coords or {}
    local size = vec3(store.width or 2.0, store.length or 2.0, store.height or 2.0)
    local heading = store.heading or 0.0

    local options = {
        {
            id = "la_peditor_open_" .. tostring(store.id or ""),
            label = store.label or ("Open " .. tostring(store.type or "Store")),
            icon = store.icon or "fas fa-tshirt",
            event = "la_peditor:client:openClothingShopMenu",
            canInteract = function(entity, distance, coords)
                if store.job and store.job ~= "" then
                    local pd = nil
                    pcall(function() pd = exports['qb-core']:GetCoreObject().Functions.GetPlayerData() end)
                    if not (pd and pd.job and pd.job.name == store.job) then return false end
                end
                if store.gang and store.gang ~= "" then
                    local pd = nil
                    pcall(function() pd = exports['qb-core']:GetCoreObject().Functions.GetPlayerData() end)
                    if not (pd and pd.gang and pd.gang.name == store.gang) then return false end
                end
                return true
            end
        }
    }

    local ok, res = pcall(function()
        return tryExportAdd(qtarget, { "AddBoxZone", "AddCircleZone", "AddTargetCircle", "AddTarget", "AddTargetModel" },
            name, vector3(coords.x or 0.0, coords.y or 0.0, coords.z or 0.0), size.x, size.y, {
                heading = heading,
                minZ = (coords.z or 0.0) - (store.minZ or 1.0),
                maxZ = (coords.z or 0.0) + (store.maxZ or 1.0),
                options = options
            })
    end)

    if ok and res ~= nil then
        created[name] = res or true
        return true
    end

    local ok2, res2 = pcall(function()
        return tryExportAdd(qtarget, { "AddBoxZone" }, vector3(coords.x or 0.0, coords.y or 0.0, coords.z or 0.0), size.x, size.y, {
            name = name, heading = heading, debugPoly = store.debug or false,
            minZ = (coords.z or 0.0) - (store.minZ or 1.0),
            maxZ = (coords.z or 0.0) + (store.maxZ or 1.0),
            options = options
        })
    end)

    if ok2 and res2 ~= nil then
        created[name] = res2 or true
        return true
    end

    return nil, "failed-register"
end

function M.RegisterTargets(stores)
    if type(stores) ~= "table" then return end
    for _, store in ipairs(stores) do
        if store and not store.disableTarget then
            local name = ("la_peditor_store_%s_%s"):format(store.type or "unknown", tostring(store.id or "0"))
            if created[name] then
                -- keep existing registration (many qtarget variants lack remove)
            else
                local ok, err = registerBoxZone(store)
                if ok then
                    la.log('info', ("[qtarget] Registered zone %s"):format(name))
                else
                    la.log('warn', ("[qtarget] Failed to register zone %s: %s"):format(name, tostring(err)))
                end
            end
        end
    end
end

function M.RemoveAll()
    created = {}
    return true
end

return M
