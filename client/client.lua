-- client/client.lua
-- theme="1950s-cartoon-noir"
-- la_peditor main client bootstrap (hardened & qbx-compatible)

if not la_peditor then la_peditor = {} end
local la = la_peditor
local Config = la.Config or {}
local Framework = la.Framework or {}
local Assets = la.Assets or {}
local lib = la.lib or (type(_G) == 'table' and _G.lib) or nil
local initialized = false
local isMenuOpen = false
local propSlots = {0, 1, 2, 6, 7}
local QBCore = (Framework.GetCoreObject and Framework.GetCoreObject()) or Framework.qb
if type(Framework.WhenCoreReady) == 'function' then
    Framework.WhenCoreReady(function(core) QBCore = core end)
end

local function safeEncode(data)
    if json and type(json.encode) == 'function' then
        local ok, payload = pcall(json.encode, data)
        if ok then return payload end
    end
    return tostring(data)
end

local FALLBACK_ANIMAL_HEAD = { component_id = 1, drawable = 21, texture = 0 }

local function GetDefaultHeadMask()
    local assetId = Config.DefaultMaskAsset
    if assetId and Assets and type(Assets.FindEntryById) == 'function' then
        local entry = Assets.FindEntryById(assetId)
        if entry and entry.type == 'component' and entry.component_id then
            return { component_id = entry.component_id, drawable = entry.drawable or 0, texture = entry.texture or 0 }
        end
    end
    if type(la.SharedPeds) == 'table' and type(la.SharedPeds.GetHeadMask) == 'function' then
        local ok, mask = pcall(la.SharedPeds.GetHeadMask, 'raccoon')
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

local function getPedAppearance(ped)
    ped = ped or PlayerPedId()
    if not ped or not DoesEntityExist(ped) then return nil end
    local appearance = { model = GetEntityModel(ped), components = {}, props = {}, theme = '1950s-cartoon-noir' }
    for i = 0, 11 do
        appearance.components[#appearance.components + 1] = {
            component_id = i,
            drawable = GetPedDrawableVariation(ped, i),
            texture = GetPedTextureVariation(ped, i)
        }
    end
    for _, slot in ipairs(propSlots) do
        local drawable = GetPedPropIndex(ped, slot)
        if drawable and drawable >= 0 then
            appearance.props[#appearance.props + 1] = {
                prop_id = slot,
                drawable = drawable,
                texture = GetPedPropTextureIndex(ped, slot)
            }
        end
    end
    local hairColor, hairHighlight = GetPedHairColor(ped)
    appearance.hair = {
        drawable = GetPedDrawableVariation(ped, 2),
        texture = GetPedTextureVariation(ped, 2),
        color = hairColor or 0,
        highlight = hairHighlight or hairColor or 0
    }
    appearance.eyeColor = GetPedEyeColor(ped)
    return appearance
end

local function setPlayerModel(model)
    if not model then return false end
    local hash = type(model) == 'number' and model or joaat(model)
    if not hash or not IsModelInCdimage(hash) or not IsModelValid(hash) then return false end
    RequestModel(hash)
    local deadline = GetGameTimer() + 5000
    while not HasModelLoaded(hash) and GetGameTimer() < deadline do
        Wait(0)
    end
    if not HasModelLoaded(hash) then return false end
    SetPlayerModel(PlayerId(), hash)
    SetPedDefaultComponentVariation(PlayerPedId())
    SetModelAsNoLongerNeeded(hash)
    return true
end

local function sendAssetsToNui()
    if not Assets or type(Assets.GetSummary) ~= 'function' then return end
    local ok, summary = pcall(Assets.GetSummary)
    if ok and summary then
        summary.command = Config.OpenCommand
        SendNUIMessage({ type = 'appearance_assets', payload = summary })
    end
end

local function openMenu(context, meta)
    isMenuOpen = true
    SetNuiFocus(true, true)
    if SetNuiFocusKeepInput then SetNuiFocusKeepInput(false) end
    local payload = {
        message = context or 'opened from client',
        context = context,
        meta = meta or {},
        command = Config.OpenCommand,
        theme = la.Theme and la.Theme.Metadata and la.Theme.Metadata.style or '1950s-cartoon-noir'
    }
    SendNUIMessage({ type = 'appearance_display', payload = payload })
    sendAssetsToNui()
end

local function closeMenu()
    if not isMenuOpen then return end
    isMenuOpen = false
    SetNuiFocus(false, false)
    if SetNuiFocusKeepInput then SetNuiFocusKeepInput(false) end
    SendNUIMessage({ type = 'appearance_hide' })
end

local function InitializeAppearance()
    if initialized then return end
    initialized = true
    local ped = PlayerPedId()
    if not ped or not DoesEntityExist(ped) then
        Wait(500)
        ped = PlayerPedId()
    end
    ApplyDefaultAnimalHead(ped)
    sendAssetsToNui()
    la.log('info', 'client initialized')
end

-- ped cache hook: keep props on damage if configured
if lib and type(lib.onCache) == 'function' then
    lib.onCache('ped', function(value)
        local ped = value
        if not ped or not DoesEntityExist(ped) then return end
        if type(Config) ~= 'table' then return end
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
                if ped and DoesEntityExist(ped) then
                    pcall(function() SetPedCanLosePropsOnDamage(ped, false, 0) end)
                end
            end
            Wait(2000)
        end
    end)
    la.log('info', 'lib.onCache not found; started fallback ped-props guardian')
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CreateThread(function()
            Wait(1000)
            InitializeAppearance()
        end)
    end
end)

AddEventHandler('playerSpawned', function()
    CreateThread(function()
        Wait(1000)
        InitializeAppearance()
    end)
end)

local function registerOpenCommand(commandName, description, keybind)
    if not commandName or commandName == '' then return end
    local sanitized = commandName:gsub('^/', '')
    RegisterCommand(sanitized, function()
        openMenu('command:' .. sanitized, { source = 'command' })
    end, false)
    if keybind and keybind ~= '' then
        pcall(function() RegisterKeyMapping(sanitized, description or 'Open pEditor', 'keyboard', keybind) end)
    end
    la.log('info', ("Registered pEditor command /%s (key=%s)"):format(sanitized, keybind or 'none'))
end

if Config.OpenCommandEnabled ~= false then
    registerOpenCommand(Config.OpenCommand or 'pe', Config.OpenCommandDescription, Config.OpenKey)
end
if (Config.OpenCommand or 'pe') ~= 'open_peditor' then
    registerOpenCommand('open_peditor', 'Open pEditor (legacy)', nil)
end

RegisterCommand('la_peditor_test', function()
    local ped = PlayerPedId()
    local ok = ped and DoesEntityExist(ped)
    TriggerEvent('chat:addMessage', {
        color = { 200, 180, 80 },
        multiline = false,
        args = { 'la_peditor', ok and '✅ Client self-test passed (1950s-cartoon-noir)' or '❌ No valid ped found' }
    })
    local summary = (Assets and type(Assets.GetSummary) == 'function' and Assets.GetSummary()) or {}
    la.log('info', ('Self-test run. QBCore present: %s, asset packs=%s'):format(tostring(QBCore ~= nil), tostring(summary.packs and #summary.packs or 0)))
    if ok then
        local head = GetDefaultHeadMask()
        local current = GetPedDrawableVariation(ped, head.component_id)
        la.log('debug', ("Current head drawable: %s — default expected: %s"):format(current, head.drawable))
    end
end, false)

RegisterNetEvent('la_peditor:client:openMenu', function(_, menuType, metadata)
    local context = menuType and ('event:' .. tostring(menuType)) or 'event:full'
    openMenu(context, metadata)
end)

RegisterNetEvent('la_peditor:client:openClothingShop', function()
    openMenu('event:clothing')
end)

RegisterNetEvent('la_peditor:client:openClothingShopMenu', function()
    openMenu('event:clothing-menu')
end)

RegisterNUICallback('nuiPing', function(data, cb)
    la.log('debug', '[NUI] ping ' .. safeEncode(data))
    cb({
        ok = true,
        command = Config.OpenCommand,
        appearance = getPedAppearance(),
        assets = (Assets and type(Assets.GetSummary) == 'function' and Assets.GetSummary()) or {}
    })
end)

RegisterNUICallback('nuiHide', function(data, cb)
    la.log('debug', '[NUI] hide ' .. safeEncode(data))
    closeMenu()
    cb({ ok = true })
end)

exports('la_peditor_getPedAppearance', getPedAppearance)
exports('la_peditor_setPlayerModel', setPlayerModel)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    closeMenu()
end)
