-- client/client.lua
-- theme="1950s-cartoon-noir"
-- Author: Pulphouse Press
-- la_peditor main client bootstrap (replaces bostra_appearance client entry)

if not la_peditor then la_peditor = {} end
local la = la_peditor
local Config = la.Config or {}
local Assets = la.Assets or {}
local SharedPeds = la.SharedPeds or {}
local initialized = false

-- Fallback default animal head (component 1 = head/mask slot)
local FALLBACK_ANIMAL_HEAD = { component_id = 1, drawable = 21, texture = 0 } -- raccoon

local function GetDefaultHeadMask()
    if Config and Config.DefaultMaskAsset and Assets and type(Assets.FindEntryById) == 'function' then
        local entry = Assets.FindEntryById(Config.DefaultMaskAsset)
        if entry and entry.type == 'component' then
            return { component_id = entry.component_id, drawable = entry.drawable or 0, texture = entry.texture or 0 }
        end
    end
    if type(SharedPeds) == "table" and type(SharedPeds.GetHeadMask) == "function" then
        local mask = SharedPeds.GetHeadMask("raccoon")
        if mask and mask.component_id and mask.drawable then
            return mask
        end
    end
    return FALLBACK_ANIMAL_HEAD
end

local function ApplyDefaultAnimalHead(ped)
    if not ped or not DoesEntityExist(ped) then return end
    local head = GetDefaultHeadMask()
    SetPedComponentVariation(ped, head.component_id, head.drawable, head.texture or 0, 2)
    -- Theme-aware debug
    print(("[la_peditor] Applied default animal head drawable=%s (theme=\"1950s-cartoon-noir\")"):format(head.drawable))
end

local function InitializeAppearance()
    if initialized then return end
    initialized = true

    local ped = PlayerPedId()
    -- If ped model changes on init, ensure we operate on the current ped
    if not ped or not DoesEntityExist(ped) then
        Wait(500)
        ped = PlayerPedId()
    end

    ApplyDefaultAnimalHead(ped)

    -- Future: fetch saved appearance from server callback:
    -- QBCore.Functions.TriggerCallback('la_peditor:getAppearance', function(appearance) ... end)
    print('[la_peditor] la_peditor client initialized — theme="1950s-cartoon-noir"')
end

-- Safe resource start: initialize after resource starts
AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CreateThread(function()
            Wait(1000)
            InitializeAppearance()
        end)
    end
end)

-- Also run when player spawns (cover reconnects)
AddEventHandler("playerSpawned", function()
    CreateThread(function()
        Wait(1000)
        InitializeAppearance()
    end)
end)
