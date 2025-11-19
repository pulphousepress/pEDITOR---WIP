-- la_peditor/client/editable/handlers.lua

local function locale(key)
    if lib and lib.locale then
        return lib.locale(key)
    end
    return key
end

function onSkinMenuOpened()
    -- Show camera control hints at bottom left
    showKeyhintsPermanent({
        {
            keyIcon = { "ph-fill ph-mouse-left-click", "ph-fill ph-arrows-horizontal" },
            keyClass = "flex flex-col items-center align-center keyhint_iconsVertical",
            info = locale('keyhint_rotateCharacter'),
        },
        {
            keyIcon = { "ph-fill ph-mouse-middle-click", "ph-fill ph-arrows-vertical" },
            keyClass = "flex flex-col items-center align-center keyhint_iconsVertical",
            info = locale('keyhint_changeCameraHeight'),
        },
        {
            keyIcon = { "ph-fill ph-mouse-right-click", "ph-fill ph-arrows-out-simple" },
            keyClass = "flex flex-col items-center align-center keyhint_iconsVertical",
            info = locale('keyhint_moveCamera'),
        },
        {
            keyIcon = { "ph-fill ph-mouse-scroll", "ph-fill ph-magnifying-glass-plus" },
            keyClass = "flex flex-col items-center align-center keyhint_iconsVertical",
            info = locale('keyhint_zoomCamera'),
        },
    }, 'bottom-left')
end

function onSkinMenuClosed()
    clearKeyhints()

    -- Example hook into your own system:
    -- TriggerEvent('la_core:onPeditorClosed')
end

-- Optional: ensure skin is reapplied when player loads, in addition to la_peditor main logic.
AddEventHandler('la_core:onPlayerLoaded', function()
    local skin = exports['PEDitor']:getSkinOptionsDb()
    if skin and type(skin) == 'table' then
        exports['PEDitor']:setSkinOptions(skin)
    end
end)

-- showKeyhintsPermanent and clearKeyhints are part of PEDitor’s UI utils, so this file is intended to live alongside or inside its editable handler system.