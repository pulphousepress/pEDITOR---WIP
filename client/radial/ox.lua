-- client/radial/ox.lua
-- theme="1950s-cartoon-noir"
-- la_peditor: radial menu adapter for ox_lib (oxradial / ox_lib)
-- Hardened: defensive registration, idempotent

if not la_peditor then la_peditor = {} end
local la = la_peditor
local M = {}

-- defensive lib detection
local lib = la.lib or (type(_G)=='table' and rawget(_G, "lib")) or nil
if not lib then
    -- try exporting ox_lib directly if present
    if exports and exports['ox_lib'] then
        pcall(function() lib = exports['ox_lib'] end)
    end
end

local function safeRegister(ctx)
    if not lib or type(lib.registerRadial) ~= "function" then
        return false, "lib.registerRadial not available"
    end
    local ok, err = pcall(function() lib.registerRadial(ctx) end)
    if not ok then return false, err end
    return true
end

function M.RegisterRadialItems()
    if not lib then
        la.log('warn', 'radial/ox: lib not found, skipping radial registration')
        return false
    end

    local ctx = {
        id = "la_peditor_radial_menu",
        title = "Dresser — 1950s-cartoon-noir",
        options = {
            {
                title = "Open Wardrobe",
                icon = "fa-solid fa-shirt",
                onSelect = function() TriggerEvent("la_peditor:client:openClothingShop", false) end
            },
            {
                title = "Save Outfit",
                icon = "fa-solid fa-save",
                onSelect = function() TriggerEvent("la_peditor:client:saveOutfit") end
            },
            {
                title = "Clear Props",
                icon = "fa-solid fa-trash",
                onSelect = function() TriggerEvent("la_peditor:client:ClearStuckProps") end
            },
            {
                title = "Reload Skin",
                icon = "fa-solid fa-sync",
                onSelect = function() TriggerEvent("la_peditor:client:reloadSkin", false) end
            },
            {
                title = "Client Self-Test",
                icon = "fa-solid fa-check-circle",
                onSelect = function() ExecuteCommand("la_peditor_test") end
            }
        }
    }

    local ok, err = safeRegister(ctx)
    if ok then
        la.log('info', 'radial/ox: Registered radial menu via ox_lib')
    else
        la.log('warn', ('radial/ox: Failed registering radial: %s'):format(tostring(err)))
    end
    return ok
end

return M
