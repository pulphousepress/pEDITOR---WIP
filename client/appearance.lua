-- client/client.lua
-- theme="1950s-cartoon-noir"
-- Author: Pulphouse Press
-- la_peditor main client bootstrap (replaces bostra_appearance client entry)

local QBCore = exports['qb-core']:GetCoreObject()
local initialized = false

-- Fallback default animal head (component 1 = head/mask slot)
local FALLBACK_ANIMAL_HEAD = { component_id = 1, drawable = 21, texture = 0 } -- raccoon

local function GetDefaultHeadMask()
    -- Prefer shared helper (if shared/peds.lua loaded), otherwise fallback
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

-- Self-test command for admins/devs
RegisterCommand("la_peditor_test", function()
    local ped = PlayerPedId()
    local ok = ped and DoesEntityExist(ped)

    TriggerEvent("chat:addMessage", {
        color = { 200, 180, 80 },
        multiline = false,
        args = { "la_peditor", ok and "✅ Client self-test passed (1950s-cartoon-noir)" or "❌ No valid ped found" }
    })

    print("[la_peditor] Self-test run. QBCore present:", tostring(QBCore ~= nil))
    if ok then
        local head = GetDefaultHeadMask()
        local current = GetPedDrawableVariation(ped, head.component_id)
        print(("[la_peditor] Current head drawable: %s — default expected: %s"):format(current, head.drawable))
    end
end, false)
