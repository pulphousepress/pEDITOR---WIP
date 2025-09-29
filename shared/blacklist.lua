-- resources/la_peditor/shared/blacklist.lua
-- theme="1950s-cartoon-noir"
-- Era-appropriate blacklist (namespaced). Explicit compatibility shim at bottom.

if not la_peditor then la_peditor = {} end
la_peditor.Config = la_peditor.Config or {}
la_peditor.Config.Blacklist = {
    male = {
        hair = { 76, 92, 95, 98, 99, 101 },
        components = {
            masks = { 134, 135, 137, 141 },
            upperBody = { 111, 113, 118 },
            lowerBody = { 89, 93 },
            bags = { 45, 56, 60 },
            shoes = { 54, 59, 63 },
            scarfAndChains = { 38 },
            shirts = {},
            bodyArmor = { 16, 17 },
            decals = { 65 },
            jackets = { 121, 123 }
        },
        props = {
            hats = { 45, 98, 101, 102 },
            glasses = { 17, 20 },
            ear = { 7, 10 },
            watches = { 3, 7, 9 },
            bracelets = { 4, 6 }
        }
    },
    female = {
        hair = { 87, 99, 100, 102 },
        components = {
            masks = { 138, 142 },
            upperBody = { 119, 121 },
            lowerBody = { 86, 88 },
            bags = { 58, 61 },
            shoes = { 53, 60 },
            scarfAndChains = {},
            shirts = {},
            bodyArmor = { 15, 18 },
            decals = { 67 },
            jackets = { 125, 127 }
        },
        props = {
            hats = { 100, 104 },
            glasses = { 18, 22 },
            ear = { 8, 11 },
            watches = { 5, 8 },
            bracelets = { 3, 5 }
        }
    }
}

-- Explicit compatibility shim for code that reads Config.Blacklist globally.
-- This sets the global Config only if it isn't already present to minimize accidental overrides.
la_peditor.Config = la_peditor.Config
if not _G.Config then
    Config = Config or la_peditor.Config
end

print("[la_peditor/shared/blacklist.lua] loaded — blacklist applied")
return la_peditor.Config.Blacklist
