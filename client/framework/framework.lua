-- client/framework/framework.lua
-- theme="1950s-cartoon-noir"
-- la_peditor: client-side framework helpers (gender detection, ped utilities)
-- Hardened: namespaced, no globals

if not la_peditor then la_peditor = {} end
local la = la_peditor
la.Framework = la.Framework or {}
local Framework = la.Framework

local function getPlayerData()
    if type(Framework.GetPlayerData) == 'function' then
        local ok, pdata = pcall(Framework.GetPlayerData)
        if ok and pdata then return pdata end
    end
    local qb = Framework.GetCoreObject and Framework.GetCoreObject()
    if qb and qb.Functions and type(qb.Functions.GetPlayerData) == 'function' then
        local ok, pdata = pcall(qb.Functions.GetPlayerData)
        if ok and pdata then return pdata end
    end
    return nil
end

-- Return player's stored/character gender where possible.
-- Tries several common qb/qbx character fields, falls back to ped model detection.
-- Always returns "male" or "female" (lowercase) for consistency.
function Framework.GetPlayerGender()
    local pdata = getPlayerData()
    if pdata then
        if pdata.charinfo and pdata.charinfo.gender then
            local g = tostring(pdata.charinfo.gender):lower()
            if g == 'female' or g == 'f' then return 'female' end
            if g == 'male' or g == 'm' then return 'male' end
        end
        if pdata.gender then
            local g = tostring(pdata.gender):lower()
            if g == 'female' or g == 'f' then return 'female' end
            if g == 'male' or g == 'm' then return 'male' end
        end
        if pdata.metadata and pdata.metadata.gender then
            local g = tostring(pdata.metadata.gender):lower()
            if g == 'female' or g == 'f' then return 'female' end
            if g == 'male' or g == 'm' then return 'male' end
        end
    end

    -- 2) Ped-model fallback
    local ped = PlayerPedId()
    if ped and DoesEntityExist(ped) then
        local modelHash = GetEntityModel(ped)
        if modelHash == GetHashKey("mp_f_freemode_01") then
            return "female"
        else
            return "male"
        end
    end

    -- Default fallback
    return "male"
end

-- Primary API used by the client UI/creation flows.
-- If isNew == true OR Config.GenderBasedOnPed is false/nil, use stored player gender.
-- Otherwise prefer ped-based gender detection (useful when customizing a spawned ped).
-- Returns "male" or "female".
function Framework.GetGender(isNew)
    local cfg = type(la.Config) == "table" and la.Config or {}
    if isNew or (cfg.GenderBasedOnPed == nil or cfg.GenderBasedOnPed == false) then
        return Framework.GetPlayerGender()
    end

    local ped = PlayerPedId()
    if ped and DoesEntityExist(ped) then
        local modelHash = GetEntityModel(ped)
        if modelHash == GetHashKey("mp_f_freemode_01") then
            return "female"
        else
            return "male"
        end
    end

    return Framework.GetPlayerGender()
end

-- Returns ped model name for the current ped where possible
function Framework.GetPedModelName()
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) then return nil end
    local hash = GetEntityModel(ped)
    if hash == GetHashKey("mp_f_freemode_01") then return "mp_f_freemode_01" end
    if hash == GetHashKey("mp_m_freemode_01") then return "mp_m_freemode_01" end
    return nil
end

la.log('info', 'client/framework/framework.lua loaded — theme="1950s-cartoon-noir"')
