-- client/zones.lua
-- theme="1950s-cartoon-noir"
-- la_peditor: zone creation & handlers (hardened)

if not la_peditor then la_peditor = {} end
local la = la_peditor
local Config = la.Config or {}
local Framework = la.Framework or {}
local lib = la.lib or (type(_G)=='table' and _G.lib) or nil
local locale = la.locale or nil

if Config.UseTarget then
    la.log('info', 'client/zones.lua skipped because Config.UseTarget is true')
    return
end

local function safeGetPlayerData()
    if Framework and type(Framework.GetPlayerData) == 'function' then
        local ok, pd = pcall(Framework.GetPlayerData)
        if ok and pd then return pd end
    end
    return {}
end

local function playerJobName()
    local pd = safeGetPlayerData()
    return pd.job and pd.job.name or nil
end

local function playerGangName()
    local pd = safeGetPlayerData()
    return pd.gang and pd.gang.name or nil
end

local function coordsToVec3(c)
    if type(c) == "vector3" or type(c) == "userdata" then return c end
    if type(c) == "table" and c.x and c.y and c.z then return vector3(c.x, c.y, c.z) end
    return vector3(0.0, 0.0, 0.0)
end

local currentZone = nil
local Zones = { Store = {}, ClothingRoom = {}, PlayerOutfitRoom = {} }

local function RemoveZones()
    for i = 1, #Zones.Store do
        local z = Zones.Store[i]
        if z and type(z.remove) == "function" then pcall(z.remove) end
    end
    Zones.Store = {}

    for i = 1, #Zones.ClothingRoom do
        local z = Zones.ClothingRoom[i]
        if z and type(z.remove) == "function" then pcall(z.remove) end
    end
    Zones.ClothingRoom = {}

    for i = 1, #Zones.PlayerOutfitRoom do
        local z = Zones.PlayerOutfitRoom[i]
        if z and type(z.remove) == "function" then pcall(z.remove) end
    end
    Zones.PlayerOutfitRoom = {}
end

local function findStoreByID(id)
    if not Config.Stores then return nil, nil end
    for i = 1, #Config.Stores do
        if Config.Stores[i] and Config.Stores[i].id == id then
            return i, Config.Stores[i]
        end
    end
    return nil, nil
end

local function safeShowTextUI(msg)
    if not msg then return end
    if lib and type(lib.showTextUI) == "function" then
        pcall(function() lib.showTextUI(msg, Config.TextUIOptions) end)
    else
        TriggerEvent("chat:addMessage", { color = {200,180,80}, args = {"la_peditor", tostring(msg)} })
    end
end

local function safeHideTextUI()
    if lib and type(lib.hideTextUI) == "function" then pcall(lib.hideTextUI) end
end

local function onStoreEnter(data)
    if not data or not data.id then return end
    local index, store = findStoreByID(data.id)
    if not store then return end
    local jobName = store.job and playerJobName() or nil
    local gangName = store.gang and playerGangName() or nil
    if (store.job and jobName == store.job) or (store.gang and gangName == store.gang) or (not store.job and not store.gang) then
        currentZone = { name = store.type, index = index }
        local msg = "Open " .. tostring(store.type)
        if type(locale) == "function" then
            local ok, s = pcall(locale, "open_menu")
            if ok and s then msg = s end
        end
        safeShowTextUI(msg)
    end
end

local function onZoneExit()
    safeHideTextUI()
    currentZone = nil
end

function CreateZones()
    if not lib or not lib.zones or type(lib.zones.box) ~= "function" then
        la.log('warn', 'lib.zones not available; skipping CreateZones')
        return
    end

    RemoveZones()

    if Config.Stores and type(Config.Stores) == "table" then
        for i = 1, #Config.Stores do
            local store = Config.Stores[i]
            if store and store.coords then
                local coords = coordsToVec3(store.coords)
                local size = vec3(store.width or 2.0, store.length or 2.0, store.height or 2.0)
                local z = lib.zones.box({
                    id = store.id,
                    coords = coords,
                    size = size,
                    rotation = store.heading or 0.0,
                    onEnter = onStoreEnter,
                    onExit = onZoneExit,
                    debug = store.debug or false
                })
                Zones.Store[#Zones.Store + 1] = z
            end
        end
    end

    if Config.ClothingRooms and type(Config.ClothingRooms) == "table" then
        for i = 1, #Config.ClothingRooms do
            local room = Config.ClothingRooms[i]
            if room and room.coords then
                local coords = coordsToVec3(room.coords)
                local size = vec3(room.width or 2.0, room.length or 2.0, room.height or 1.0)
                local z = lib.zones.box({
                    id = room.id,
                    coords = coords,
                    size = size,
                    rotation = room.heading or 0.0,
                    onEnter = function()
                        currentZone = { name = "clothing_room", index = i }
                        local msg = "Open Clothing Room"
                        if type(locale) == "function" then
                            local ok, s = pcall(locale, "open_clothingroom")
                            if ok and s then msg = s end
                        end
                        safeShowTextUI(msg)
                    end,
                    onExit = onZoneExit,
                    debug = room.debug or false
                })
                Zones.ClothingRoom[#Zones.ClothingRoom + 1] = z
            end
        end
    end

    if Config.PlayerOutfitRooms and type(Config.PlayerOutfitRooms) == "table" then
        for i = 1, #Config.PlayerOutfitRooms do
            local room = Config.PlayerOutfitRooms[i]
            if room and room.coords then
                local coords = coordsToVec3(room.coords)
                local size = vec3(room.width or 2.0, room.length or 2.0, room.height or 1.0)
                local z = lib.zones.box({
                    id = room.id,
                    coords = coords,
                    size = size,
                    rotation = room.heading or 0.0,
                    onEnter = function()
                        currentZone = { name = "player_outfit_room", index = i }
                        local msg = "Open Dresser"
                        if type(locale) == "function" then
                            local ok, s = pcall(locale, "open_player_outfit_room")
                            if ok and s then msg = s end
                        end
                        safeShowTextUI(msg)
                    end,
                    onExit = onZoneExit,
                    debug = room.debug or false
                })
                Zones.PlayerOutfitRoom[#Zones.PlayerOutfitRoom + 1] = z
            end
        end
    end

    la.log('info', 'Zones created')
end

function GetCurrentZone() return currentZone end

exports('CreateZones', CreateZones)
exports('GetCurrentZone', GetCurrentZone)
exports('RemoveZones', RemoveZones)

CreateThread(function() Wait(1500); CreateZones() end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    RemoveZones()
end)
