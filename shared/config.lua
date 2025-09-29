-- resources/la_peditor/shared/config.lua
-- theme="1950s-cartoon-noir"
-- Central config — namespaced under la_peditor.Config with an explicit, visible global shim.

if not la_peditor then la_peditor = {} end
la_peditor.Config = la_peditor.Config or {}

local cfg = la_peditor.Config

-- Core Settings
cfg.Framework = cfg.Framework or 'qbox'
cfg.UseTarget = cfg.UseTarget or false
cfg.PersistUniforms = cfg.PersistUniforms or true
cfg.ClothingCost = cfg.ClothingCost or 25
cfg.ReloadSkinCooldown = cfg.ReloadSkinCooldown or 5000
cfg.Debug = cfg.Debug or false

-- Job Settings
cfg.BossManagedOutfits = cfg.BossManagedOutfits or true
cfg.PreventTrackerRemoval = cfg.PreventTrackerRemoval or true
cfg.RCoreTattoosCompatibility = cfg.RCoreTattoosCompatibility or false

-- Notify Options
cfg.NotifyOptions = cfg.NotifyOptions or {
    position = 'top',
    theme = "1950s-cartoon-noir"
}

-- Initial clothes (era-appropriate defaults)
cfg.InitialPlayerClothes = cfg.InitialPlayerClothes or {
    male = {
        Model = "mp_m_freemode_01",
        Components = {
            { component_id = 1, drawable = 21, texture = 0 },
            { component_id = 3, drawable = 1, texture = 0 },
            { component_id = 4, drawable = 10, texture = 0 },
            { component_id = 6, drawable = 9, texture = 0 },
            { component_id = 8, drawable = 15, texture = 0 },
            { component_id = 11, drawable = 27, texture = 0 },
        },
        Props = { { prop_id = 0, drawable = 18, texture = 0 } },
        Hair = { hairStyle = 1, hairColor = 0 }
    },
    female = {
        Model = "mp_f_freemode_01",
        Components = {
            { component_id = 1, drawable = 21, texture = 0 },
            { component_id = 3, drawable = 1, texture = 0 },
            { component_id = 4, drawable = 6, texture = 0 },
            { component_id = 6, drawable = 7, texture = 0 },
            { component_id = 8, drawable = 14, texture = 0 },
            { component_id = 11, drawable = 28, texture = 0 },
        },
        Props = { { prop_id = 0, drawable = 20, texture = 0 } },
        Hair = { hairStyle = 5, hairColor = 1 }
    }
}

cfg.NewCharacterSections = cfg.NewCharacterSections or {
    Ped = true, HeadBlend = true, FaceFeatures = true, HeadOverlays = true,
    Components = true, Props = true, Tattoos = false
}

cfg.DisableComponents = cfg.DisableComponents or {
    Masks = false, UpperBody = false, LowerBody = false, Bags = false,
    Shoes = false, ScarfAndChains = false, BodyArmor = true, Shirts = false,
    Decals = false, Jackets = false
}

cfg.DisableProps = cfg.DisableProps or {
    Hats = false, Glasses = false, Ear = false, Watches = true, Bracelets = true
}

cfg.Stores = cfg.Stores or {
    {
        id = "downtown_clothing",
        type = "clothing",
        coords = vec3(426.5, -806.3, 29.5),
        width = 2.0, length = 2.0, height = 1.0, heading = 0.0, debug = false
    }
}

cfg.ClothingRooms = cfg.ClothingRooms or {
    {
        id = "police_clothing",
        job = "police",
        coords = vec3(461.7, -999.1, 30.2),
        width = 2.0, length = 2.0, height = 1.0, heading = 90.0, debug = false
    }
}

cfg.PlayerOutfitRooms = cfg.PlayerOutfitRooms or {
    {
        id = "apartment_dresser",
        coords = vec3(-267.0, -958.6, 31.2),
        width = 2.0, length = 2.0, height = 1.0, heading = 270.0, debug = false
    }
}

-- Ped whitelist (era-appropriate). Keep long list in shared/peds.lua if you need expansion.
cfg.Peds = cfg.Peds or {
    pedConfig = cfg.Peds and cfg.Peds.pedConfig or {
        {
            peds = {
                "mp_m_freemode_01", "mp_f_freemode_01",
                "a_f_m_beach_01", "a_f_m_bevhills_02", "a_f_o_genstreet_01", -- trimmed example
            }
        }
    }
}

-- Expose namespaced config. Provide explicit global shim only if global Config is absent.
la_peditor.Config = cfg
if not _G.Config then
    Config = Config or la_peditor.Config
end

print("[la_peditor/shared/config.lua] loaded — Config namespaced (explicit shim applied if missing)")
return la_peditor.Config
