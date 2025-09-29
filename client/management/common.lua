-- client/management/common.lua
-- theme="1950s-cartoon-noir"
-- Shared helpers used by the management submodule of la_peditor
-- Hardened: namespaced, idempotent.

if not la_peditor then la_peditor = {} end
local la = la_peditor
la.Management = la.Management or {}
local Management = la.Management

local QBCore = nil
pcall(function() if exports and exports['qb-core'] then QBCore = exports['qb-core']:GetCoreObject() end end)
local lib = la.lib or (type(_G)=='table' and rawget(_G, "lib")) or nil

-- Internal registry of created menus so AddItems/RemoveItems are idempotent
Management._menus = Management._menus or {}

-- Adds a "back" item (if the menuing library supports nested contexts)
function Management.AddBackMenuItem(menuTable, args)
    if not menuTable or type(menuTable) ~= "table" then return end
    local back = {
        title = "Back",
        description = "Return",
        onselect = function()
            if type(args) == "table" and args.parentMenu and lib and type(lib.showContext) == "function" then
                pcall(function() lib.showContext(args.parentMenu) end)
            end
        end
    }
    menuTable.options = menuTable.options or {}
    table.insert(menuTable.options, 1, back)
end

-- Safe notify helper (theme aware)
function Management.Notify(title, description, type_)
    local t = type_ or "inform"
    if lib and type(lib.notify) == "function" then
        pcall(function()
            lib.notify({ title = title, description = description, type = t, position = (la.Config and la.Config.NotifyOptions and la.Config.NotifyOptions.position) or "top" })
        end)
    else
        TriggerEvent("chat:addMessage", { color = {200,180,80}, args = { title, description } })
    end
end

function Management.RegisterContext(id, ctx)
    if not id or not ctx then return end
    if lib and type(lib.registerContext) == "function" then
        pcall(function() lib.registerContext(ctx) end)
    end
    Management._menus[id] = ctx
end

function Management.RemoveItems()
    for id, _ in pairs(Management._menus or {}) do
        Management._menus[id] = nil
    end
    la.log('info', 'Management menu items removed — theme="1950s-cartoon-noir"')
end

la.log('info', 'client/management/common.lua loaded')
