-- la_peditor/client/editable/compatibility.lua
-- Compatibility helpers for PEDitor with skinchanger and illenium-appearance.

local AppearanceBridge = {}

-- Initial backend from config
AppearanceBridge.backend = (Config and Config.AppearanceBackend) or 'peditor'

function AppearanceBridge.setBackend(backend)
    backend = backend and backend:lower() or 'peditor'
    if backend ~= 'peditor' and backend ~= 'illenium' and backend ~= 'skinchanger' then
        backend = 'peditor'
    end
    AppearanceBridge.backend = backend
    if Config.Debug then
        print('[la_peditor] Appearance backend set to:', backend)
    end
end

function AppearanceBridge.getBackend()
    return AppearanceBridge.backend
end

---------------------------------
-- Core wrappers around PEDitor
---------------------------------

local function getClothingOptions(excludedComponents, excludedProps)
    excludedComponents = excludedComponents or {}
    excludedProps = excludedProps or {}

    return exports['PEDitor']:getClothingOptions(excludedComponents, excludedProps)
end

local function setClothingOptions(clothingOptions)
    if not clothingOptions or type(clothingOptions) ~= 'table' then
        return
    end
    exports['PEDitor']:setClothingOptions(clothingOptions)
end

local function getSkinOptionsDb()
    return exports['PEDitor']:getSkinOptionsDb()
end

local function getSkinOptions()
    return exports['PEDitor']:getSkinOptions()
end

local function saveSkinOptions(skinOptions)
    -- If options are provided, pass them through
    if skinOptions and type(skinOptions) == 'table' then
        return exports['PEDitor']:saveSkinOptions(skinOptions)
    end

    -- Otherwise let PEDitor read current skin and save
    return exports['PEDitor']:saveSkinOptions()
end

exports('getClothingOptions', getClothingOptions)
exports('setClothingOptions', setClothingOptions)
exports('getSkinOptionsDb', getSkinOptionsDb)
exports('getSkinOptions', getSkinOptions)
exports('saveSkinOptions', saveSkinOptions)

---------------------------------
-- skinchanger compatibility
---------------------------------

-- When another script calls: TriggerEvent("skinchanger:loadClothes", skin)
-- we map that to PEDitor clothing application, but only if we are in that backend.
RegisterNetEvent('skinchanger:loadClothes', function(skin)
    if AppearanceBridge.backend ~= 'skinchanger' then
        return
    end

    if not skin or type(skin) ~= 'table' then
        return
    end

    setClothingOptions(skin)
end)

-- skinchanger:change usually targets a single component.
-- Basic mapping: read current skin, patch component entry, reapply.
RegisterNetEvent('skinchanger:change', function(componentName, drawable, texture)
    if AppearanceBridge.backend ~= 'skinchanger' then
        return
    end

    if not componentName then
        return
    end

    local current = getSkinOptions()
    if not current or type(current) ~= 'table' then
        return
    end

    current.components = current.components or {}

    local compEntry = current.components[componentName] or {}

    if drawable ~= nil then
        compEntry.drawable = drawable
    end

    if texture ~= nil then
        compEntry.texture = texture
    end

    current.components[componentName] = compEntry

    exports['PEDitor']:setSkinOptions(current)
end)

---------------------------------
-- Illenium <-> PEDitor conversion
---------------------------------

-- Illenium commonly provides an `appearance` table that includes:
--   - model
--   - components: indexed by GTA component id (0-11) or named keys
--   - props: indexed by GTA prop id (0-7) or named keys
-- We will focus on clothing and props, which is what most users expect
-- when "saving appearance" from the wardrobe.

-- Map Illenium/wardrobe component names -> GTA component IDs used by PEDitor
local illeniumComponentNamesToIds = {
    mask        = 1,
    hair        = 2,    -- often handled separately, but we include it
    torso       = 3,
    legs        = 4,
    bags        = 5,
    shoes       = 6,
    accessories1 = 7,
    undershirt  = 8,
    bodyArmor   = 9,
    decals      = 10,
    tops        = 11
}

-- Map Illenium/wardrobe prop names -> GTA prop IDs used by PEDitor
local illeniumPropNamesToIds = {
    hat       = 0,
    glasses   = 1,
    ear       = 2,
    watch     = 6,
    bracelet  = 7
}

-- Helper: try to extract a numerical component id from a key
local function resolveComponentId(key)
    if type(key) == 'number' then
        return key
    end

    if type(key) == 'string' then
        local lower = key:lower()
        if illeniumComponentNamesToIds[lower] then
            return illeniumComponentNamesToIds[lower]
        end

        local num = tonumber(key)
        if num then
            return num
        end
    end

    return nil
end

-- Helper: try to extract a numerical prop id from a key
local function resolvePropId(key)
    if type(key) == 'number' then
        return key
    end

    if type(key) == 'string' then
        local lower = key:lower()
        if illeniumPropNamesToIds[lower] then
            return illeniumPropNamesToIds[lower]
        end

        local num = tonumber(key)
        if num then
            return num
        end
    end

    return nil
end

-- Convert an Illenium appearance table into a PEDitor skinOptions-style clothing/props subset.
local function illeniumToPeditor(appearance)
    local base = getSkinOptions() or {}
    base.components = base.components or {}
    base.props = base.props or {}

    if not appearance or type(appearance) ~= 'table' then
        return base
    end

    -- Components
    if appearance.components and type(appearance.components) == 'table' then
        for key, comp in pairs(appearance.components) do
            local compId = resolveComponentId(key)
            if compId then
                -- Expect comp = { drawable = x, texture = y, palette = z } OR qb style { component_id, drawable, texture }
                local drawable = comp.drawable or comp[2]
                local texture = comp.texture or comp[3] or 0

                base.components[tostring(compId)] = {
                    drawable = drawable or 0,
                    texture = texture or 0
                }
            end
        end
    end

    -- Props
    if appearance.props and type(appearance.props) == 'table' then
        for key, prop in pairs(appearance.props) do
            local propId = resolvePropId(key)
            if propId then
                local drawable = prop.drawable or prop[2]
                local texture = prop.texture or prop[3] or 0

                base.props[tostring(propId)] = {
                    drawable = drawable or -1,
                    texture = texture or 0
                }
            end
        end
    end

    -- Note: if you want to also carry over faceFeatures, headOverlays, etc,
    -- you can wire them here to base.faceFeatures and base.headOverlays
    -- according to your own Illenium configuration.

    return base
end

-- Convert a PEDitor skinOptions into an Illenium-style appearance subset.
-- This is useful if you want to push PEDitor state into Illenium UIs.
local function peditorToIllenium(skinOptions)
    local appearance = {
        components = {},
        props = {}
    }

    if not skinOptions or type(skinOptions) ~= 'table' then
        return appearance
    end

    if skinOptions.components and type(skinOptions.components) == 'table' then
        for id, data in pairs(skinOptions.components) do
            local numId = tonumber(id) or id
            appearance.components[numId] = {
                drawable = data.drawable or 0,
                texture = data.texture or 0,
                palette = 0
            }
        end
    end

    if skinOptions.props and type(skinOptions.props) == 'table' then
        for id, data in pairs(skinOptions.props) do
            local numId = tonumber(id) or id
            appearance.props[numId] = {
                drawable = data.drawable or -1,
                texture = data.texture or 0,
                palette = 0
            }
        end
    end

    return appearance
end

---------------------------------
-- illenium-appearance hooks
---------------------------------

-- When Illenium saves an appearance (for example after using its wardrobe),
-- we convert that to PEDitor skinOptions and store it in the PEDitor DB.
RegisterNetEvent('illenium-appearance:client:saveAppearance', function(appearance)
    if AppearanceBridge.backend ~= 'illenium' then
        return
    end

    if type(appearance) ~= 'table' then
        return
    end

    local skinOptions = illeniumToPeditor(appearance)

    exports['PEDitor']:setSkinOptions(skinOptions)
    saveSkinOptions(skinOptions)

    if Config.Debug then
        print('[la_peditor] Saved Illenium appearance -> PEDitor skin_data')
    end
end)

-- Optional helper to push current PEDitor skin into Illenium.
-- You will likely need to adjust the target event name based on your IA setup.
RegisterNetEvent('la_peditor:applyToIllenium', function()
    if AppearanceBridge.backend ~= 'illenium' then
        return
    end

    local skin = getSkinOptions()
    if not skin then
        return
    end

    local appearance = peditorToIllenium(skin)

    -- Replace this event with the Illenium function your build expects:
    -- Common ones are e.g. "illenium-appearance:client:setAppearance" or similar.
    TriggerEvent('illenium-appearance:client:setAppearance', appearance)

    if Config.Debug then
        print('[la_peditor] Pushed PEDitor skin -> Illenium appearance event')
    end
end)

---------------------------------
-- High-level bridge API
---------------------------------

function AppearanceBridge.openClothingShop()
    local backend = AppearanceBridge.backend

    if backend == 'illenium' then
        -- Use Illenium wardrobe UI
        TriggerEvent('illenium-appearance:client:openClothingShop')
        return
    end

    -- Default: PEDitor clothing mode
    exports['la_peditor']:openSkinEditor('clothing')
end

function AppearanceBridge.openBarberShop()
    local backend = AppearanceBridge.backend

    if backend == 'illenium' then
        -- Use Illenium barber UI
        TriggerEvent('illenium-appearance:client:openBarberShop')
        return
    end

    -- Default: PEDitor barber mode
    exports['la_peditor']:openSkinEditor('barber')
end

exports('AppearanceBridge', function()
    return AppearanceBridge
end)
