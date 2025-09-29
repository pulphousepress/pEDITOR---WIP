-- client/client.lua
-- theme="1950s-cartoon-noir"
-- la_peditor main client bootstrap (hardened)

if not la_peditor then la_peditor = {} end
local la = la_peditor
local Config = la.Config or {}
local QBCore = (exports['qb-core'] and exports['qb-core']:GetCoreObject()) or nil
local initialized = false

local FALLBACK_ANIMAL_HEAD = { component_id = 1, drawable = 21, texture = 0 }

local function GetDefaultHeadMask()
    if type(la.SharedPeds) == "table" and type(la.SharedPeds.GetHeadMask) == "function" then
        local ok, mask = pcall(la.SharedPeds.GetHeadMask, "raccoon")
        if ok and mask and mask.component_id and mask.drawable then return mask end
    end
    return FALLBACK_ANIMAL_HEAD
end

local function ApplyDefaultAnimalHead(ped)
    if not ped or not DoesEntityExist(ped) then return end
    local head = GetDefaultHeadMask()
    pcall(function()
        SetPedComponentVariation(ped, head.component_id, head.drawable, head.texture or 0, 2)
    end)
    la.log('info', ("Applied default animal head drawable=%s"):format(head.drawable))
end

local function InitializeAppearance()
    if initialized then return end
    initialized = true
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) then
        Wait(500); ped = PlayerPedId()
    end
    ApplyDefaultAnimalHead(ped)
    la.log('info', 'client initialized')
end

-- ped cache hook: keep props on damage if configured
local lib = la.lib or (type(_G)=='table' and _G.lib) or nil
if lib and type(lib.onCache) == "function" then
    lib.onCache('ped', function(value)
        local ped = value
        if not ped or not DoesEntityExist(ped) then return end
        if type(Config) ~= "table" then return end
        if Config.AlwaysKeepProps then
            pcall(function() SetPedCanLosePropsOnDamage(ped, false, 0) end)
            la.log('debug', 'Ensured props stay on ped (AlwaysKeepProps=true)')
        end
    end)
else
    CreateThread(function()
        while true do
            if Config and Config.AlwaysKeepProps then
                local ped = PlayerPedId()
                if ped and DoesEntityExist(ped) then pcall(function() SetPedCanLosePropsOnDamage(ped, false, 0) end) end
            end
            Wait(2000)
        end
    end)
    la.log('info', 'lib.onCache not found; started fallback ped-props guardian')
end

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CreateThread(function() Wait(1000); InitializeAppearance() end)
    end
end)

AddEventHandler("playerSpawned", function()
    CreateThread(function() Wait(1000); InitializeAppearance() end)
end)

RegisterCommand("la_peditor_test", function()
    local ped = PlayerPedId()
    local ok = ped and DoesEntityExist(ped)
    TriggerEvent("chat:addMessage", {
        color = { 200, 180, 80 },
        multiline = false,
        args = { "la_peditor", ok and "✅ Client self-test passed (1950s-cartoon-noir)" or "❌ No valid ped found" }
    })
    la.log('info', "Self-test run. QBCore present: " .. tostring(QBCore ~= nil))
    if ok then
        local head = GetDefaultHeadMask()
        local current = GetPedDrawableVariation(ped, head.component_id)
        la.log('debug', ("Current head drawable: %s — default expected: %s"):format(current, head.drawable))
    end
end, false)

-- client.lua (FiveM)
local resourceName = GetCurrentResourceName()

RegisterCommand('open_peditor', function()
  SetNuiFocus(true, true) -- give cursor & keyboard focus to NUI
  SendNUIMessage({ type = 'appearance_display', payload = { message = 'opened from client' } })
end)

RegisterNUICallback('nuiPing', function(data, cb)
  print('[la_peditor] received nuiPing', json.encode(data))
  -- reply or trigger server-side stuff here
  cb({ ok = true })
end)

RegisterNUICallback('nuiHide', function(data, cb)
  print('[la_peditor] received nuiHide', json.encode(data))
  SetNuiFocus(false, false)
  SendNUIMessage({ type = 'appearance_hide' })
  cb({ ok = true })
end)

