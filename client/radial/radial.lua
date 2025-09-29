-- client/radial/radial.lua
-- theme="1950s-cartoon-noir"
-- la_peditor: radial registration orchestrator (chooses best adapter available)
-- Hardened: tries adapters non-blocking & registers fallback

if not la_peditor then la_peditor = {} end
local la = la_peditor
local M = {}

local function tryRequire(path)
    local ok, mod = pcall(function() return require(path) end)
    if ok and type(mod) == "table" then return mod end
    return nil
end

local function loadAdapter()
    local ok, oxAdapter = pcall(function() return tryRequire("client.radial.ox") end)
    if oxAdapter and type(oxAdapter.RegisterRadialItems) == "function" then
        local success, _ = pcall(function() return oxAdapter.RegisterRadialItems() end)
        if success then return true end
    end

    local ok2, qbAdapter = pcall(function() return tryRequire("client.radial.qb") end)
    if qbAdapter and type(qbAdapter.RegisterRadialItems) == "function" then
        local success2, _ = pcall(function() return qbAdapter.RegisterRadialItems() end)
        if success2 then return true end
    end

    if la.lib and type(la.lib.registerRadial) == "function" then
        pcall(function()
            la.lib.registerRadial({
                id = "la_peditor_radial_fallback",
                title = "Dresser — 1950s-cartoon-noir",
                options = {
                    { title = "Open Wardrobe", icon = "fa-solid fa-shirt", onSelect = function() TriggerEvent("la_peditor:client:openClothingShop", false) end }
                }
            })
        end)
        la.log('info', 'radial: Used lib.registerRadial fallback')
        return true
    end

    RegisterCommand("la_peditor_radial_help", function()
        TriggerEvent("chat:addMessage", { color = {200,180,80}, args = { "la_peditor", "No radial system found. Use /la_peditor_radial to open fallback." } })
    end, false)

    return false
end

function M.Init()
    CreateThread(function()
        Wait(1000)
        local ok = loadAdapter()
        if not ok then la.log('warn', 'radial: No radial adapter available; fallback registered') end
    end)
end

M.Init()
return M
