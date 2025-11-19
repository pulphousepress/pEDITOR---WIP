-- resources/la_peditor/client/props.lua
-- theme="1950s-cartoon-noir"
-- Hardened props helper — does not rely on a global `lib` and avoids crashes.

-- Namespaced module
if not la_peditor then la_peditor = {} end
la_peditor.client_props = la_peditor.client_props or {}
local M = la_peditor.client_props
local Assets = la_peditor.Assets or {}

-- Attempt to use existing lib (ox_lib or qb-lib) if present; otherwise fall back to safe stubs.
local lib = rawget(_G, "lib") or {} -- if resource provides a global lib it will be used
-- Provide safe stub functions if lib lacks them to avoid nil indexing errors
lib.requestAnimDict = lib.requestAnimDict or function(dict, timeout)
    if not dict then return end
    RequestAnimDict(dict)
    local deadline = GetGameTimer() + (timeout or 2000)
    while not HasAnimDictLoaded(dict) and GetGameTimer() < deadline do Wait(0) end
end
lib.onCache = lib.onCache or function(name, cb) -- stub: immediate call
    if type(cb) == "function" then cb() end
end

-- Safe logger (use shared logger if present)
local log = (la_peditor and la_peditor.log) or function(...) print("[la_peditor][props]", ...) end

-- local helpers to set props
local function clearProp(ped, slot)
    if not DoesEntityExist(ped) then return end
    ClearPedProp(ped, slot)
end

local function setProp(ped, prop)
    if not DoesEntityExist(ped) or not prop then return end
    if prop.drawable == -1 or prop.drawable == nil then
        ClearPedProp(ped, prop.prop_id or 0)
        return
    end
    SetPedPropIndex(ped, prop.prop_id or 0, prop.drawable or 0, prop.texture or 0, false)
end

local function setComponent(ped, component)
    if not DoesEntityExist(ped) or not component or component.component_id == nil then return end
    SetPedComponentVariation(ped, component.component_id, component.drawable or 0, component.texture or 0, component.palette or 2)
end

local function setHair(ped, entry)
    if not DoesEntityExist(ped) or not entry then return end
    local drawable = entry.drawable or entry.style or 0
    SetPedComponentVariation(ped, 2, drawable, entry.texture or 0, 0)
    if entry.color then
        SetPedHairColor(ped, entry.color, entry.highlight or entry.color or 0)
    end
end

local function setBeard(ped, entry)
    if not DoesEntityExist(ped) or not entry then return end
    local overlay = entry.overlay or 1
    local opacity = entry.opacity or 1.0
    local style = entry.style or entry.drawable or 0
    SetPedHeadOverlay(ped, overlay, style, opacity)
    SetPedHeadOverlayColor(ped, overlay, 1, entry.color or 0, entry.highlight or entry.color or 0)
end

-- Public API: apply props table to ped (safe)
function M.applyProps(ped, props)
    if not ped or not DoesEntityExist(ped) then
        ped = PlayerPedId()
    end
    if not props or type(props) ~= "table" then return end
    for _, p in ipairs(props) do
        pcall(function() setProp(ped, p) end)
    end
end

-- Public API: remove all props of a ped (safe)
function M.clearAllProps(ped)
    ped = ped or PlayerPedId()
    for _, slot in ipairs({0,1,2,6,7}) do
        pcall(function() ClearPedProp(ped, slot) end)
    end
end

function M.applyAsset(assetId, ped)
    if not assetId or not Assets or type(Assets.FindEntryById) ~= 'function' then return false end
    local entry = Assets.FindEntryById(assetId)
    if not entry then
        log('warn', ('[props] Unknown asset id %s'):format(tostring(assetId)))
        return false
    end
    ped = ped or PlayerPedId()
    if not ped or not DoesEntityExist(ped) then return false end
    if entry.type == 'prop' then
        setProp(ped, entry)
        return true
    elseif entry.type == 'component' then
        setComponent(ped, entry)
        return true
    elseif entry.type == 'hair' then
        setHair(ped, entry)
        return true
    elseif entry.type == 'beard' then
        setBeard(ped, entry)
        return true
    end
    log('warn', ('[props] Unsupported asset type %s for %s'):format(tostring(entry.type), tostring(assetId)))
    return false
end

-- Backwards compatibility: if legacy code expects global `Props` or `props`, expose minimal shim
if not _G.Props then
    Props = M
end
if not la_peditor.client_props then la_peditor.client_props = M end

RegisterNetEvent('la_peditor:client:applyAsset', function(assetId)
    M.applyAsset(assetId)
end)

exports('ApplyAsset', function(assetId, ped)
    return M.applyAsset(assetId, ped)
end)

log("info", "client/props.lua loaded (lib fallback active)")
return M
