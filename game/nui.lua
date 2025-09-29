-- la_peditor/game/nui.lua
-- theme="1950s-cartoon-noir"
-- NUI callbacks (hardened & namespaced)

if not la_peditor then la_peditor = {} end
local la = la_peditor
local client = la.client or {}
local cache = la.cache or {}
local lib = la.lib or (type(_G)=='table' and rawget(_G, "lib")) or nil

-- Safe locale getter (falls back to en)
local function getUIStrings()
    local lang = (la.Config and la.Config.Locale) or GetConvar("la_peditor:locale", "en")
    if la.Locales and la.Locales[lang] and la.Locales[lang].UI then
        return la.Locales[lang].UI
    end
    if la.Locales and la.Locales["en"] and la.Locales["en"].UI then
        return la.Locales["en"].UI
    end
    return {}
end

RegisterNUICallback("appearance_get_locales", function(_, cb)
    cb(getUIStrings())
end)

RegisterNUICallback("appearance_get_settings", function(_, cb)
    if type(client.getAppearanceSettings) == "function" then
        cb({ appearanceSettings = client.getAppearanceSettings() })
    else
        cb({ appearanceSettings = {} })
    end
end)

RegisterNUICallback("appearance_get_data", function(_, cb)
    Wait(250)
    local appearanceData = nil
    if type(client.getAppearance) == "function" then
        appearanceData = client.getAppearance()
    end
    if appearanceData and appearanceData.tattoos and type(client.setPedTattoos) == "function" then
        pcall(function() client.setPedTattoos(cache.ped, appearanceData.tattoos) end)
    end
    cb({
        config = (type(client.getConfig) == "function" and client.getConfig()) or (la.Config or {}),
        appearanceData = appearanceData
    })
end)

local function safeSetCamera(camera)
    if type(client.setCamera) == "function" and not (type(client.isDragActive) == "function" and client.isDragActive()) then
        pcall(function() client.setCamera(camera) end)
        return true
    end
    return false
end

RegisterNUICallback("appearance_set_camera", function(camera, cb)
    cb(1)
    if not safeSetCamera(camera) then
        -- fallback: restore focus / mouse bridges if needed
        SetNuiFocus(false, false)
        if type(client.getMouse) == "function" then pcall(client.getMouse) end
        if type(client.showMenu) == "function" then pcall(client.showMenu) end
    end
end)

local function safeDragStart()
    if type(client.isDragActive) == "function" and not client.isDragActive() and type(client.startDragCam) == "function" then
        pcall(client.startDragCam, cache.ped, { initial = 2.0, min = 0.35, max = 2.0, scrollIncrements = 0.1 })
        return true
    end
    return false
end

RegisterNUICallback("appearance_turn_around", function(_, cb)
    cb(1)
    if not safeDragStart() then
        SetNuiFocus(false, false)
        if type(client.getMouse) == "function" then pcall(client.getMouse) end
        if type(client.showMenu) == "function" then pcall(client.showMenu) end
    end
end)

RegisterNUICallback("appearance_rotate_camera", function(direction, cb)
    cb(1)
    if type(client.rotateCamera) == "function" and not (type(client.isDragActive) == "function" and client.isDragActive()) then
        pcall(function() client.rotateCamera(direction) end)
    else
        SetNuiFocus(false, false)
        if type(client.getMouse) == "function" then pcall(client.getMouse) end
        if type(client.showMenu) == "function" then pcall(client.showMenu) end
    end
end)

RegisterNUICallback("appearance_change_model", function(model, cb)
    if type(client.isDragActive) == "function" and client.isDragActive() and type(client.stopDragCam) == "function" then
        pcall(client.stopDragCam)
        if type(client.lightStatus) == "function" and client.lightStatus() and type(client.toggleSpotlight) == "function" then
            pcall(client.toggleSpotlight)
        end
    end
    local playerPed = nil
    if type(client.setPlayerModel) == "function" then
        local ok, ped = pcall(client.setPlayerModel, model)
        if ok then playerPed = ped end
    end
    if playerPed and cache and cache.ped then
        pcall(SetEntityHeading, cache.ped, (type(client.getHeading) == "function" and client.getHeading()) or GetEntityHeading(cache.ped))
        pcall(SetEntityInvincible, playerPed, true)
        pcall(TaskStandStill, playerPed, -1)
    end
    cb({
        appearanceSettings = (type(client.getAppearanceSettings) == "function" and client.getAppearanceSettings()) or {},
        appearanceData = (type(client.getPedAppearance) == "function" and client.getPedAppearance(playerPed or cache.ped)) or {}
    })
end)

RegisterNUICallback("appearance_change_component", function(component, cb)
    if type(client.setPedComponent) == "function" then pcall(client.setPedComponent, cache.ped, component) end
    cb((type(client.getComponentSettings) == "function" and client.getComponentSettings(cache.ped, component.component_id)) or {})
end)

RegisterNUICallback("appearance_change_prop", function(prop, cb)
    if type(client.setPedProp) == "function" then pcall(client.setPedProp, cache.ped, prop) end
    cb((type(client.getPropSettings) == "function" and client.getPropSettings(cache.ped, prop.prop_id)) or {})
end)

RegisterNUICallback("appearance_change_head_blend", function(headBlend, cb)
    cb(1)
    if type(client.setPedHeadBlend) == "function" then pcall(client.setPedHeadBlend, cache.ped, headBlend) end
end)

RegisterNUICallback("appearance_change_face_feature", function(faceFeatures, cb)
    cb(1)
    if type(client.setPedFaceFeatures) == "function" then pcall(client.setPedFaceFeatures, cache.ped, faceFeatures) end
end)

RegisterNUICallback("appearance_change_head_overlay", function(headOverlays, cb)
    cb(1)
    if type(client.setPedHeadOverlays) == "function" then pcall(client.setPedHeadOverlays, cache.ped, headOverlays) end
end)

RegisterNUICallback("appearance_change_hair", function(hair, cb)
    if type(client.setPedHair) == "function" then pcall(client.setPedHair, cache.ped, hair) end
    cb((type(client.getHairSettings) == "function" and client.getHairSettings(cache.ped)) or {})
end)

RegisterNUICallback("appearance_change_eye_color", function(eyeColor, cb)
    cb(1)
    if type(client.setPedEyeColor) == "function" then pcall(client.setPedEyeColor, cache.ped, eyeColor) end
end)

RegisterNUICallback("appearance_apply_tattoo", function(data, cb)
    local paid = true
    if data and data.tattoo and la.Config and la.Config.ChargePerTattoo and lib and lib.callback and lib.callback.await then
        local ok, res = pcall(lib.callback.await, "illenium-appearance:server:payForTattoo", false, data.tattoo)
        paid = ok and res
    end
    if paid and type(client.addPedTattoo) == "function" then pcall(client.addPedTattoo, cache.ped, data.updatedTattoos or data) end
    cb(paid)
end)

RegisterNUICallback("appearance_preview_tattoo", function(previewTattoo, cb)
    cb(1)
    if type(client.setPreviewTattoo) == "function" then pcall(client.setPreviewTattoo, cache.ped, previewTattoo.data, previewTattoo.tattoo) end
end)

RegisterNUICallback("appearance_delete_tattoo", function(data, cb)
    cb(1)
    if type(client.removePedTattoo) == "function" then pcall(client.removePedTattoo, cache.ped, data) end
end)

RegisterNUICallback("appearance_wear_clothes", function(dataWearClothes, cb)
    cb(1)
    if type(client.wearClothes) == "function" then pcall(client.wearClothes, dataWearClothes.data, dataWearClothes.key) end
end)

RegisterNUICallback("appearance_remove_clothes", function(clothes, cb)
    cb(1)
    if type(client.removeClothes) == "function" then pcall(client.removeClothes, clothes) end
end)

RegisterNUICallback("appearance_save", function(appearance, cb)
    cb(1)
    -- apply in safe order, guard missing functions
    if type(client.wearClothes) == "function" then
        pcall(client.wearClothes, appearance, "head")
        pcall(client.wearClothes, appearance, "body")
        pcall(client.wearClothes, appearance, "bottom")
    end
    if type(client.exitPlayerCustomization) == "function" then pcall(client.exitPlayerCustomization, appearance) end
    if lib and type(lib.hideTextUI) == "function" then pcall(lib.hideTextUI) end
    if type(client.isDragActive) == "function" and client.isDragActive() and type(client.stopDragCam) == "function" then
        pcall(client.stopDragCam)
        if type(client.lightStatus) == "function" and client.lightStatus() and type(client.toggleSpotlight) == "function" then
            pcall(client.toggleSpotlight)
        end
    end
end)

RegisterNUICallback("appearance_exit", function(_, cb)
    cb(1)
    if type(client.exitPlayerCustomization) == "function" then pcall(client.exitPlayerCustomization) end
    if lib and type(lib.hideTextUI) == "function" then pcall(lib.hideTextUI) end
    if type(client.isDragActive) == "function" and client.isDragActive() and type(client.stopDragCam) == "function" then
        pcall(client.stopDragCam)
        if type(client.lightStatus) == "function" and client.lightStatus() and type(client.toggleSpotlight) == "function" then
            pcall(client.toggleSpotlight)
        end
    end
end)

RegisterNUICallback("rotate_left", function(_, cb)
    cb(1)
    if type(client.isDragActive) == "function" and not client.isDragActive() and type(client.pedTurn) == "function" then
        pcall(client.pedTurn, cache.ped, 10.0)
    else
        SetNuiFocus(false, false)
        if type(client.getMouse) == "function" then pcall(client.getMouse) end
        if type(client.showMenu) == "function" then pcall(client.showMenu) end
    end
end)

RegisterNUICallback("rotate_right", function(_, cb)
    cb(1)
    if type(client.isDragActive) == "function" and not client.isDragActive() and type(client.pedTurn) == "function" then
        pcall(client.pedTurn, cache.ped, -10.0)
    else
        SetNuiFocus(false, false)
        if type(client.getMouse) == "function" then pcall(client.getMouse) end
        if type(client.showMenu) == "function" then pcall(client.showMenu) end
    end
end)

RegisterNUICallback("get_theme_configuration", function(_, cb)
    cb((la.Config and la.Config.Theme) or { name = "1950s-cartoon-noir" })
end)
