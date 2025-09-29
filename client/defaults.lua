-- client/defaults.lua
-- theme="1950s-cartoon-noir"
-- la_peditor: default customization config helper (defensive & QBox-compatible)

if not la_peditor then la_peditor = {} end
local la = la_peditor
local Config = la.Config or {}
local Framework = la.Framework or {}

local function _safeDisable(tbl)
    if type(tbl) ~= "table" then return {} end
    return tbl
end

local function getComponentConfig()
    local disable = _safeDisable(Config and Config.DisableComponents)
    return {
        masks           = not disable.Masks,
        upperBody       = not disable.UpperBody,
        lowerBody       = not disable.LowerBody,
        bags            = not disable.Bags,
        shoes           = not disable.Shoes,
        scarfAndChains  = not disable.ScarfAndChains,
        bodyArmor       = not disable.BodyArmor,
        shirts          = not disable.Shirts,
        decals          = not disable.Decals,
        jackets         = not disable.Jackets
    }
end

local function getPropConfig()
    local disable = _safeDisable(Config and Config.DisableProps)
    return {
        hats       = not disable.Hats,
        glasses    = not disable.Glasses,
        ear        = not disable.Ear,
        watches    = not disable.Watches,
        bracelets  = not disable.Bracelets
    }
end

function GetDefaultConfig()
    local cfg = Config or {}
    local fw  = la.Framework or {}

    local hasTracker = false
    if cfg.PreventTrackerRemoval and fw and type(fw.HasTracker) == "function" then
        pcall(function() hasTracker = fw.HasTracker() end)
    end

    return {
        ped = false,
        headBlend = false,
        faceFeatures = false,
        headOverlays = false,
        components = false,
        componentConfig = getComponentConfig(),
        props = false,
        propConfig = getPropConfig(),
        tattoos = false,
        enableExit = true,
        hasTracker = hasTracker,
        automaticFade = cfg.AutomaticFade or false,
        theme = "1950s-cartoon-noir"
    }
end
