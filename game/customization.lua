-- resources/la_peditor/game/customization.lua
-- theme="1950s-cartoon-noir"
-- Small compatibility wrapper used by client UI.

local ok, Constants = pcall(require, "game.constants")
if not ok or not Constants then
    pcall(function() Constants = require("la_peditor.game.constants") end)
end
Constants = Constants or {}

local Custom = {}

function Custom.defaultAppearance(gender)
    gender = gender or "male"
    local defaults = (la_peditor and la_peditor.Config and la_peditor.Config.InitialPlayerClothes) or {}
    local entry = defaults[gender] or defaults["male"] or {}
    return {
        model = entry.Model or (gender == "female" and "mp_f_freemode_01" or "mp_m_freemode_01"),
        components = entry.Components or {},
        props = entry.Props or {},
        hair = entry.Hair or { hairStyle = 1, hairColor = 0 }
    }
end

return Custom
