-- client/radial/qb.lua
-- theme="1950s-cartoon-noir"
-- la_peditor: radial adapter for QB-style radial menus (qb-radial or qb-menu fallbacks)
-- Hardened, namespaced

if not la_peditor then la_peditor = {} end
local la = la_peditor
local M = {}

local function tryExport(name)
    if exports and exports[name] then return exports[name] end
    return nil
end

local function buildMenu()
    local menu = {
        {
            id = "la_peditor_open",
            label = "Open Wardrobe",
            icon = "shirt",
            action = function() TriggerEvent("la_peditor:client:openClothingShop", false) end
        },
        {
            id = "la_peditor_save",
            label = "Save Outfit",
            icon = "save",
            action = function() TriggerEvent("la_peditor:client:saveOutfit") end
        },
        {
            id = "la_peditor_clearprops",
            label = "Clear Props",
            icon = "trash",
            action = function() TriggerEvent("la_peditor:client:ClearStuckProps") end
        },
        {
            id = "la_peditor_reloadskin",
            label = "Reload Skin",
            icon = "sync",
            action = function() TriggerEvent("la_peditor:client:reloadSkin", false) end
        },
        {
            id = "la_peditor_selftest",
            label = "Client Self-Test",
            icon = "check-circle",
            action = function() ExecuteCommand("la_peditor_test") end
        }
    }
    return menu
end

function M.RegisterRadialItems()
    local qb_radial = tryExport("qb-radial") or tryExport("qb_radial") or tryExport("qb-menu")
    if qb_radial then
        local ok, err = pcall(function()
            if qb_radial.AddOption then
                local menu = buildMenu()
                for _, m in ipairs(menu) do qb_radial.AddOption(m.id, m.label, m.icon, m.action) end
            elseif qb_radial.RegisterRadial then
                qb_radial.RegisterRadial("la_peditor_radial", buildMenu())
            elseif qb_radial.OpenMenu then
                local menu = buildMenu()
                RegisterCommand("la_peditor_radial_open", function()
                    for _, item in ipairs(menu) do
                        qb_radial.OpenMenu({ title = item.label })
                    end
                end, false)
            end
        end)
        if ok then
            la.log('info', 'radial/qb: Registered radial via QB-style export')
            return true
        else
            la.log('warn', ('radial/qb: Error registering radial: %s'):format(tostring(err)))
        end
    end

    -- fallback: command-based menu
    RegisterCommand("la_peditor_radial", function()
        local menu = buildMenu()
        TriggerEvent("chat:addMessage", { color = {200,180,80}, args = { "la_peditor", "Opened radial fallback. Use commands or hotkeys for actions." } })
        for i, item in ipairs(menu) do
            print(("[la_peditor] %d) %s — command: la_peditor_cmd_%s"):format(i, item.label, item.id))
            RegisterCommand("la_peditor_cmd_" .. item.id, function() item.action() end, false)
        end
    end, false)

    la.log('info', 'radial/qb: No QB radial export; fallback registered')
    return false
end

return M
