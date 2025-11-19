-- client/management/management.lua
-- theme="1950s-cartoon-noir"
-- Management UI bindings for boss-managed outfits (client-side)
-- Hardened and namespaced.

if not la_peditor then la_peditor = {} end
local la = la_peditor
la.Management = la.Management or {}
local Management = la.Management
local lib = la.lib or (type(_G)=='table' and rawget(_G, "lib")) or nil
local Framework = la.Framework or {}

local function fetchPlayerData()
    if Framework and type(Framework.GetPlayerData) == 'function' then
        local ok, data = pcall(Framework.GetPlayerData)
        if ok and data then return data end
    end
    return nil
end

-- Build and register the management menu for the player's job/gang (client-side)
function Management.AddItems()
    if not la.Config or not la.Config.BossManagedOutfits then
        return
    end

    if Management._registered then return end
    Management._registered = true

    local managementMenuID = "la_peditor_management_menu"

    local saveAction = {
        id = managementMenuID .. "_save",
        title = "[Manager] Save Outfit",
        description = "Save the current outfit for your job/gang.",
        event = "la_peditor:client:SaveManagementOutfit",
        args = nil
    }

    local openAction = {
        id = managementMenuID .. "_open",
        title = "[Manager] Open Outfit List",
        description = "Open the list of management outfits.",
        event = "la_peditor:client:OutfitManagementMenu",
        args = { type = "Job" }
    }

    local menu = {
        id = managementMenuID,
        title = "Outfit Management",
        options = {
            saveAction,
            openAction
        }
    }

    if Management.RegisterContext then
        Management.RegisterContext(managementMenuID, menu)
    else
        pcall(function() if lib and type(lib.registerContext) == "function" then lib.registerContext(menu) end end)
    end

    RegisterCommand("la_manageoutfits", function()
        local player = fetchPlayerData()
        local isBoss = (player and player.job and player.job.isboss)
        if isBoss then
            if lib and type(lib.showContext) == "function" then
                pcall(function() lib.showContext(managementMenuID) end)
            end
        else
            Management.Notify("Permission", "Only bosses may open the management menu.", "error")
        end
    end, false)

    la.log('info', 'Management items registered — theme="1950s-cartoon-noir"')
end

-- Show the management menu by requesting outfits from server then building UI
RegisterNetEvent("la_peditor:client:OutfitManagementMenu", function(args)
    local mType = args and args.type or "Job"
    local gender = Framework and Framework.GetGender and Framework.GetGender() or "male"

    local ok, result = pcall(function()
        if lib and type(lib.callback) == "table" then
            return lib.callback.await("la_peditor:server:getManagementOutfits", false, mType, gender)
        end
        return {}
    end)

    if not ok or not result then
        Management.Notify("Outfits", "Failed to load management outfits.", "error")
        return
    end

    local changeMenuID = "la_peditor_change_management_outfit_menu"
    local deleteMenuID = "la_peditor_delete_management_outfit_menu"

    local changeMenu = { id = changeMenuID, title = "Change Outfit", menu = "la_peditor_management_menu", options = {} }
    local deleteMenu = { id = deleteMenuID, title = "Delete Outfit", menu = "la_peditor_management_menu", options = {} }

    for i = 1, #result do
        local it = result[i]
        table.insert(changeMenu.options, {
            title = it.name,
            description = it.model or "unknown model",
            event = "la_peditor:client:changeOutfit",
            args = {
                type = mType,
                name = it.name,
                model = it.model,
                components = it.components,
                props = it.props,
                disableSave = true
            }
        })
        table.insert(deleteMenu.options, {
            title = ("Delete: %s"):format(it.name),
            description = it.model or "",
            event = "la_peditor:client:DeleteManagementOutfit",
            args = it.id
        })
    end

    Management.RegisterContext(changeMenuID, changeMenu)
    Management.RegisterContext(deleteMenuID, deleteMenu)

    local mainMenu = {
        id = "la_peditor_management_menu",
        title = ("Manage %s Outfits"):format(mType),
        options = {
            { title = "Change Outfit", description = "Apply a management outfit", menu = changeMenuID },
            { title = "Save Outfit", description = "Save current outfit as management outfit", event = "la_peditor:client:SaveManagementOutfit", args = mType },
            { title = "Delete Outfit", description = "Remove a management outfit", menu = deleteMenuID }
        }
    }

    Management.RegisterContext("la_peditor_management_menu", mainMenu)
    if lib and type(lib.showContext) == "function" then
        pcall(function() lib.showContext("la_peditor_management_menu") end)
    end
end)

RegisterNetEvent("la_peditor:client:SaveManagementOutfit", function(mType)
    mType = mType or "Job"
    local pd = fetchPlayerData()
    local jobName = (mType == "Job") and (pd and pd.job and pd.job.name) or (pd and pd.gang and pd.gang.name)

    local rankOptions = (Framework and Framework.GetRankInputValues and Framework.GetRankInputValues(mType:lower())) or {
        { label = "0", value = "0" }, { label = "1", value = "1" }, { label = "2", value = "2" }
    }

    -- Use lib.inputDialog if available
    local dialog = nil
    if lib and type(lib.inputDialog) == "function" then
        pcall(function()
            dialog = lib.inputDialog("Save Management Outfit", {
                { type = "input", label = "Outfit Name", required = true },
                { type = "select", label = "Gender", options = { { label = "Male", value = "male" }, { label = "Female", value = "female" } }, default = "male" },
                { type = "select", label = "Min Rank", options = rankOptions, default = "0" }
            })
        end)
    end
    if not dialog then return end

    local outfitName = dialog[1]
    local gender = dialog[2]
    local minRank = tonumber(dialog[3]) or 0

    local ped = PlayerPedId()
    local appearance = { Model = GetEntityModel(ped), Components = {}, Props = {} }

    for i = 0, 11 do
        local drawable = GetPedDrawableVariation(ped, i)
        local texture = GetPedTextureVariation(ped, i)
        appearance.Components[#appearance.Components + 1] = { component_id = i, drawable = drawable, texture = texture }
    end

    for i = 0, 7 do
        local propDrawable = GetPedPropIndex(ped, i)
        local propTexture = GetPedPropTextureIndex(ped, i)
        appearance.Props[#appearance.Props + 1] = { prop_id = i, drawable = propDrawable, texture = propTexture }
    end

    TriggerServerEvent("la_peditor:server:saveManagementOutfit", {
        Type = mType,
        JobName = jobName,
        Name = outfitName,
        Gender = gender,
        MinRank = minRank,
        Model = appearance.Model,
        Components = appearance.Components,
        Props = appearance.Props
    })

    Management.Notify("Saved", "Management outfit save requested.", "success")
end)

RegisterNetEvent("la_peditor:client:DeleteManagementOutfit", function(id)
    if not id then return end
    TriggerServerEvent("la_peditor:server:deleteManagementOutfit", id)
    Management.Notify("Deleted", "Management outfit deleted.", "success")
end)

function Management.RemoveItems()
    Management._registered = false
    Management._menus = {}
    la.log('info', 'Management.RemoveItems executed — theme="1950s-cartoon-noir"')
end
