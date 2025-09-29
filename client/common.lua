-- client/common.lua
-- theme="1950s-cartoon-noir"
-- Shared client helpers for la_peditor (hardened)

if not la_peditor then la_peditor = {} end
local la = la_peditor
local Config = la.Config or {}
local Management = la.Management or {}
local QBCore = (exports['qb-core'] and exports['qb-core']:GetCoreObject()) or nil
local lib = la.lib or (type(_G)=='table' and _G.lib) or nil

local function getPlayerData()
    if QBCore and type(QBCore.Functions) == "table" and type(QBCore.Functions.GetPlayerData) == "function" then
        local ok, pdata = pcall(QBCore.Functions.GetPlayerData)
        if ok and pdata then return pdata end
    end
    return {}
end

local function getGender()
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return "male" end
    local model = GetEntityModel(ped)
    if model == `mp_f_freemode_01` then return "female" end
    return "male"
end

local function getJobGrade()
    local pd = getPlayerData()
    if pd and pd.job and pd.job.grade and pd.job.job == nil then
        if pd.job.grade.level ~= nil then
            return pd.job.grade.level
        end
        return tonumber(pd.job.grade) or 0
    end
    if pd and pd.job and pd.job.grade and type(pd.job.grade) == "table" then
        return tonumber(pd.job.grade.level) or 0
    end
    return 0
end

local function getGangGrade()
    local pd = getPlayerData()
    if pd and pd.gang and pd.gang.grade and pd.gang.grade.level then
        return pd.gang.grade.level
    end
    return tonumber(pd.gang and pd.gang.grade) or 0
end

local function getJobName()
    local pd = getPlayerData()
    return pd and pd.job and pd.job.name or nil
end

local function getGangName()
    local pd = getPlayerData()
    return pd and pd.gang and pd.gang.name or nil
end

local function CheckDuty()
    if not Config or not Config.OnDutyOnlyClothingRooms then
        return true
    end
    local pd = getPlayerData()
    return pd and pd.job and pd.job.onduty == true
end

local function IsPlayerAllowedForOutfitRoom(outfitRoom)
    if not outfitRoom then return false end
    local allowedList = outfitRoom.citizenIDs
    if not allowedList or #allowedList == 0 then
        return true
    end
    local pd = getPlayerData()
    local myCid = pd and pd.citizenid or nil
    if not myCid then return false end
    for i = 1, #allowedList do
        if tostring(allowedList[i]) == tostring(myCid) then
            return true
        end
    end
    return false
end

local function GetPlayerJobOutfits(isJob)
    local outfits = {}
    local gender = getGender()
    local gradeLevel = isJob and getJobGrade() or getGangGrade()
    local name = isJob and getJobName() or getGangName()

    if Config and Config.BossManagedOutfits and lib and type(lib.callback) == "table" then
        local mType = isJob and "Job" or "Gang"
        local ok, result = pcall(function()
            return lib.callback.await("la_peditor:server:getManagementOutfits", false, mType, gender)
        end)
        if ok and type(result) == "table" then
            for i = 1, #result do
                outfits[#outfits + 1] = {
                    type = mType,
                    model = result[i].model,
                    components = result[i].components,
                    props = result[i].props,
                    disableSave = true,
                    name = result[i].name
                }
            end
        end
    elseif name and Config and Config.Outfits and Config.Outfits[name] and Config.Outfits[name][gender] then
        for i = 1, #Config.Outfits[name][gender] do
            local cfg = Config.Outfits[name][gender][i]
            if cfg and cfg.grades then
                for _, allowedGrade in pairs(cfg.grades) do
                    if tonumber(allowedGrade) == tonumber(gradeLevel) then
                        local copy = {}
                        for k, v in pairs(cfg) do copy[k] = v end
                        copy.gender = gender
                        copy.jobName = name
                        outfits[#outfits + 1] = copy
                        break
                    end
                end
            end
        end
    end

    return outfits
end

local function OpenOutfitRoom(outfitRoom)
    if IsPlayerAllowedForOutfitRoom(outfitRoom) then
        TriggerEvent("la_peditor:client:openMenu", false, "outfit", outfitRoom)
    else
        if lib and type(lib.notify) == "function" then
            lib.notify({
                title = "Dresser",
                description = "You're not authorized to use this outfit locker.",
                type = "error",
                position = Config.NotifyOptions and Config.NotifyOptions.position or "top"
            })
        else
            TriggerEvent("chat:addMessage", { color = {200,180,80}, args = {"la_peditor", "You're not authorized to use this outfit locker."}})
        end
    end
end

local function OpenBarberShop()
    local config = GetDefaultConfig and GetDefaultConfig() or {}
    config.headOverlays = true
    TriggerEvent("la_peditor:client:openClothingShop", config, false, "barber")
end

local function OpenTattooShop()
    local config = GetDefaultConfig and GetDefaultConfig() or {}
    config.tattoos = true
    TriggerEvent("la_peditor:client:openClothingShop", config, false, "tattoo")
end

local function OpenSurgeonShop()
    local config = GetDefaultConfig and GetDefaultConfig() or {}
    config.headBlend = true
    config.faceFeatures = true
    TriggerEvent("la_peditor:client:openClothingShop", config, false, "surgeon")
end

AddEventHandler("onResourceStop", function(resource)
    if resource ~= GetCurrentResourceName() then return end
    if Management and type(Management.RemoveItems) == "function" then
        pcall(Management.RemoveItems)
    end
end)

exports('CheckDuty', CheckDuty)
exports('IsPlayerAllowedForOutfitRoom', IsPlayerAllowedForOutfitRoom)
exports('GetPlayerJobOutfits', GetPlayerJobOutfits)
exports('OpenOutfitRoom', OpenOutfitRoom)
exports('OpenBarberShop', OpenBarberShop)
exports('OpenTattooShop', OpenTattooShop)
exports('OpenSurgeonShop', OpenSurgeonShop)

RegisterNetEvent("la_peditor:client:OpenBarberShop", OpenBarberShop)
RegisterNetEvent("la_peditor:client:OpenTattooShop", OpenTattooShop)
RegisterNetEvent("la_peditor:client:OpenSurgeonShop", OpenSurgeonShop)

la.log('info', 'client/common.lua loaded')
