-- client/outfits.lua
-- theme="1950s-cartoon-noir"
-- la_peditor: job outfit loader + outfit menu bindings
-- Author: Pulphouse Press (hardened)

-- Namespaced header (prevents hidden globals; requires shared/namespace.lua)
if not la_peditor then la_peditor = {} end
local la = la_peditor
local Config = la.Config or {}
local Framework = la.Framework or {}
local lib = la.lib or (type(_G)=='table' and _G.lib) or nil

-- local helper to detect metatype names or primitive types (keeps original behaviour)
local function typeof(var)
    local _type = type(var)
    if (_type ~= "table" and _type ~= "userdata") then
        return _type
    end
    local _meta = getmetatable(var)
    if (_meta ~= nil and _meta._NAME ~= nil) then
        return _meta._NAME
    else
        return _type
    end
end

-- Safely get player ped (defensive)
local function getPed()
    local p = PlayerPedId()
    if not p or not DoesEntityExist(p) then
        return nil
    end
    return p
end

-- Load a job/gang outfit to the current ped.
local function LoadJobOutfit(oData)
    if not oData then return end
    local ped = getPed()
    if not ped then return end

    local data = oData.outfitData
    if typeof(data) ~= "table" then
        local ok, dec = pcall(function() return json.decode(tostring(data or "")) end)
        if ok and type(dec) == "table" then
            data = dec
        else
            la.log('warn', 'Failed to decode outfit data (LoadJobOutfit)')
            return
        end
    end

    local function applyComponent(slot, item)
        if not item then return end
        local drawable = tonumber(item.item) or tonumber(item.drawable) or -1
        local texture  = tonumber(item.texture) or 0
        if drawable ~= nil and drawable >= 0 then
            pcall(function()
                SetPedComponentVariation(ped, slot, drawable, texture, 2)
            end)
        end
    end

    if data["pants"] ~= nil then applyComponent(4, data["pants"]) end
    if data["arms"] ~= nil then applyComponent(3, data["arms"]) end
    if data["t-shirt"] ~= nil then applyComponent(8, data["t-shirt"]) end
    if data["vest"] ~= nil then applyComponent(9, data["vest"]) end
    if data["torso2"] ~= nil then applyComponent(11, data["torso2"]) end
    if data["shoes"] ~= nil then applyComponent(6, data["shoes"]) end
    if data["decals"] ~= nil then applyComponent(10, data["decals"]) end

    local tracker = Config.TrackerClothingOptions
    if data["accessory"] ~= nil then
        if tracker and type(Framework) == "table" and type(Framework.HasTracker) == "function" then
            local ok, has = pcall(Framework.HasTracker)
            if ok and has then
                pcall(function() SetPedComponentVariation(ped, 7, tracker.drawable, tracker.texture, 2) end)
            else
                applyComponent(7, data["accessory"])
            end
        else
            applyComponent(7, data["accessory"])
        end
    else
        if tracker and type(Framework) == "table" and type(Framework.HasTracker) == "function" then
            local ok, has = pcall(Framework.HasTracker)
            if ok and has then
                pcall(function() SetPedComponentVariation(ped, 7, tracker.drawable, tracker.texture, 2) end)
            end
        end
    end

    if data["mask"] ~= nil then applyComponent(1, data["mask"]) end
    if data["bag"] ~= nil then applyComponent(5, data["bag"]) end

    if data["hat"] ~= nil then
        local hatItem = data["hat"]
        local drawable = tonumber(hatItem.item) or -1
        local texture = tonumber(hatItem.texture) or 0
        pcall(function()
            if drawable >= 0 then SetPedPropIndex(ped, 0, drawable, texture, true)
            else ClearPedProp(ped, 0) end
        end)
    end

    if data["glass"] ~= nil then
        local g = data["glass"]
        local drawable = tonumber(g.item) or -1
        local texture = tonumber(g.texture) or 0
        pcall(function()
            if drawable >= 0 then SetPedPropIndex(ped, 1, drawable, texture, true)
            else ClearPedProp(ped, 1) end
        end)
    end

    if data["ear"] ~= nil then
        local e = data["ear"]
        local drawable = tonumber(e.item) or -1
        local texture = tonumber(e.texture) or 0
        pcall(function()
            if drawable >= 0 then SetPedPropIndex(ped, 2, drawable, texture, true)
            else ClearPedProp(ped, 2) end
        end)
    end

    local length = 0
    for _ in pairs(data) do length = length + 1 end

    if Config.PersistUniforms and length > 1 then
        local uniformData = {
            jobName = oData.jobName,
            gender = oData.gender,
            label = oData.name
        }
        TriggerServerEvent("la_peditor:server:syncUniform", uniformData)
    end

    la.log('info', ("Loaded job outfit '%s' for job '%s'"):format(tostring(oData.name or "unknown"), tostring(oData.jobName or "unknown")))
end

RegisterNetEvent("la_peditor:client:loadJobOutfit", LoadJobOutfit)

RegisterNetEvent("la_peditor:client:openOutfitMenu", function()
    TriggerEvent("la_peditor:client:openMenu", false, "outfit")
end)

RegisterNetEvent("la_peditor:client:outfitsCommand", function(isJob)
    local outfits = nil
    if exports['la_peditor'] and exports['la_peditor'].GetPlayerJobOutfits then
        local ok, res = pcall(exports['la_peditor'].GetPlayerJobOutfits, isJob)
        if ok then outfits = res end
    end
    TriggerEvent("la_peditor:client:openJobOutfitsMenu", outfits or {})
end)

la.log('info', 'client/outfits.lua loaded')
