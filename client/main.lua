-- la_peditor/client/main.lua

local function detectGenderFromPlayerData(playerData)
    if not playerData then
        return Config.DefaultGender or 'm'
    end

    -- QBox charinfo.gender is often 0 male, 1 female
    local gender = nil

    if playerData.charinfo and playerData.charinfo.gender ~= nil then
        gender = playerData.charinfo.gender
    elseif playerData.gender ~= nil then
        gender = playerData.gender
    end

    if type(gender) == 'number' then
        if gender == 0 then
            return 'm'
        else
            return 'f'
        end
    end

    if type(gender) == 'string' then
        gender = gender:lower()
        if gender == 'm' or gender == 'male' then
            return 'm'
        elseif gender == 'f' or gender == 'female' then
            return 'f'
        end
    end

    return Config.DefaultGender or 'm'
end

local function applyBaseModelForGender(gender)
    gender = gender or Config.DefaultGender or 'm'

    -- Delegate to PEDitor
    exports['PEDitor']:setBaseModel(nil, gender)
end

local function applySavedSkin()
    local skinFromDb = exports['PEDitor']:getSkinOptionsDb()
    if skinFromDb and type(skinFromDb) == 'table' then
        -- Full skin application
        exports['PEDitor']:setSkinOptions(skinFromDb)
        return true
    end
    return false
end

local function applySpawnAppearance(playerData)
    local gender = detectGenderFromPlayerData(playerData)

    applyBaseModelForGender(gender)
    applySavedSkin()
end

-- Hook into la_core player loaded
RegisterNetEvent('la_core:onPlayerLoaded', function(playerData)
    applySpawnAppearance(playerData)

    if Config.Debug then
        print('[la_peditor] Applied spawn appearance for player with gender:', detectGenderFromPlayerData(playerData))
    end
end)

-- Optional: allow other scripts to trigger the same behavior
RegisterNetEvent('la_peditor:applySpawnAppearance', function(playerData)
    applySpawnAppearance(playerData)
end)

-- Export a simple editor opener that wraps PEDitor modes.
-- mode: 'full', 'clothing', 'barber'
local function openSkinEditor(mode)
    mode = mode or 'full'

    if mode == 'clothing' then
        exports['PEDitor']:openSkinMenu(true, false)
    elseif mode == 'barber' then
        exports['PEDitor']:openSkinMenu(false, true)
    else
        exports['PEDitor']:openSkinMenu(false, false)
    end
end

exports('openSkinEditor', openSkinEditor)

-- Optional debug command
if Config.Debug then
    RegisterCommand('peditor_test', function()
        openSkinEditor('full')
    end, false)
end
