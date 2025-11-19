-- client/blips.lua
-- theme="1950s-cartoon-noir"
-- la_peditor: blip management (hardened)

if not la_peditor then la_peditor = {} end
local la = la_peditor
local Config = la.Config or {}

local function getCoreObject()
    if la and la.GetCoreObject then
        return la.GetCoreObject()
    end
    return nil
end

local QBCore = getCoreObject()
local Blips = {}
local activeNearestThread = nil

local function safeGetPlayerData()
    if QBCore and type(QBCore.Functions.GetPlayerData) == "function" then
        local ok, pdata = pcall(QBCore.Functions.GetPlayerData)
        if ok and pdata then return pdata end
    end
    return {}
end

local function coordsToVec3(c)
    if type(c) == "table" and c.x and c.y and c.z then
        return vector3(c.x, c.y, c.z)
    end
    if type(c) == "userdata" then return c end
    return vector3(0.0, 0.0, 0.0)
end

local function ShowBlip(blipConfig, store)
    if not blipConfig or not store then return false end
    local pdata = safeGetPlayerData()
    local playerJob = pdata.job and pdata.job.name or nil
    local playerGang = pdata.gang and pdata.gang.name or nil

    if store.job and store.job ~= playerJob then return false end
    if store.gang and store.gang ~= playerGang then return false end
    if Config.RCoreTattoosCompatibility and blipConfig.type == "tattoo" then return false end

    if blipConfig.Show == true and store.showBlip == nil then return true end
    return store.showBlip == true
end

local function CreateBlipForCoords(blipConfig, coords)
    local v = coordsToVec3(coords)
    local blip = AddBlipForCoord(v.x, v.y, v.z)
    pcall(function()
        if blipConfig.Sprite then SetBlipSprite(blip, blipConfig.Sprite) end
        if blipConfig.Color then SetBlipColour(blip, blipConfig.Color) end
        if blipConfig.Scale then SetBlipScale(blip, blipConfig.Scale) end
        SetBlipAsShortRange(blip, true)
        if blipConfig.Name then
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(tostring(blipConfig.Name))
            EndTextCommandSetBlipName(blip)
        end
    end)
    return blip
end

local function SetupBlips()
    for _, b in ipairs(Blips) do if b and DoesBlipExist(b) then RemoveBlip(b) end end
    Blips = {}
    if not Config.Blips or not Config.Stores then return end
    for _, store in ipairs(Config.Stores) do
        local blipConfig = Config.Blips and Config.Blips[store.type]
        if blipConfig and ShowBlip(blipConfig, store) then
            local b = CreateBlipForCoords(blipConfig, store.coords)
            table.insert(Blips, b)
        end
    end
end

function ResetBlips()
    if Config.ShowNearestShopOnly then return end
    for _, b in ipairs(Blips) do if DoesBlipExist(b) then RemoveBlip(b) end end
    Blips = {}
    SetupBlips()
    la.log('info', 'Blips reset')
end
exports('ResetBlips', ResetBlips)

local function ShowNearestShopBlipLoop()
    local playerPed = PlayerPedId()
    local nearestBlips = {}
    while Config.ShowNearestShopOnly do
        playerPed = PlayerPedId()
        local plyCoords = GetEntityCoords(playerPed)
        for shopType, blipConfig in pairs(Config.Blips or {}) do
            local closestDist = math.huge
            local closestCoords = nil
            for _, shop in ipairs(Config.Stores or {}) do
                if shop.type == shopType and ShowBlip(blipConfig, shop) then
                    local shopVec = coordsToVec3(shop.coords)
                    local dist = #(plyCoords - shopVec)
                    if dist < closestDist then
                        closestDist = dist
                        closestCoords = shop.coords
                    end
                end
            end
            if nearestBlips[shopType] and DoesBlipExist(nearestBlips[shopType]) then
                RemoveBlip(nearestBlips[shopType])
                nearestBlips[shopType] = nil
            end
            if closestCoords then
                nearestBlips[shopType] = CreateBlipForCoords(blipConfig, closestCoords)
            end
        end
        Wait(math.max(1000, Config.NearestShopBlipUpdateDelay or 5000))
    end
    for _, b in pairs(nearestBlips) do if DoesBlipExist(b) then RemoveBlip(b) end end
end

CreateThread(function()
    if Config.ShowNearestShopOnly then
        if activeNearestThread == nil then activeNearestThread = CreateThread(ShowNearestShopBlipLoop) end
    else
        SetupBlips()
    end
end)

RegisterNetEvent('la_peditor:client:refreshBlips', function() ResetBlips() end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    for _, b in ipairs(Blips) do if DoesBlipExist(b) then RemoveBlip(b) end end
end)
