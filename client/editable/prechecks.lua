-- la_peditor/client/editable/prechecks.lua
-- Custom prechecks for opening the PEDitor skin menu

local function isPlayerDead()
    local ped = PlayerPedId()
    return GetEntityHealth(ped) <= 0
end

local function isInVehicle()
    return IsPedInAnyVehicle(PlayerPedId(), false)
end

local function isInRestrictedZone()
    -- Hook this into your own zoning if needed
    -- Example:
    -- return exports['la_core']:isInRestrictedZone()
    return false
end

local function hasPeditorPermission()
    -- Hook this into your permission system if desired
    -- Example (QBox group check):
    -- local player = exports['qbx_core']:GetPlayerData()
    -- if player and player.group == 'admin' then return true end
    -- return false
    return true
end

function canOpenSkinMenu()
    if isPlayerDead() then
        fs.utils.notify('You cannot change your appearance while dead', 'error')
        return false
    end

    if isInVehicle() then
        fs.utils.notify('Exit your vehicle to use the wardrobe', 'error')
        return false
    end

    if isInRestrictedZone() then
        fs.utils.notify('You cannot change appearance in this area', 'error')
        return false
    end

    if not hasPeditorPermission() then
        fs.utils.notify('You do not have permission to use the wardrobe', 'error')
        return false
    end

    return true
end


-- Note: fs.utils.notify is part of PEDitor’s utility layer. If you renamed it upstream, adjust here.