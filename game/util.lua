-- resources/la_peditor/game/util.lua
-- theme="1950s-cartoon-noir"
-- Utility helpers used by game/customization and other game scripts.

-- prefer 'game.constants' module (correct relative module)
local ok, Constants = pcall(require, "game.constants")
if not ok or not Constants then
    -- some legacy files may try different require variants; attempt a few fallbacks
    pcall(function() Constants = require("la_peditor.game.constants") end)
end
Constants = Constants or {
    PED_COMPONENTS_IDS = {0,1,2,3,4,5,6,7,8,9,10,11},
    PED_PROPS_IDS = {0,1,2,6,7},
    EYE_COLORS = {}
}

local Util = {}

function Util.isFreemodeModel(model)
    if not model then return false end
    local h = type(model) == "number" and model or GetHashKey(model)
    return h == GetHashKey("mp_m_freemode_01") or h == GetHashKey("mp_f_freemode_01")
end

function Util.safeVec3(v)
    if not v then return vector3(0.0,0.0,0.0) end
    if type(v) == "table" and v.x and v.y and v.z then
        return vector3(v.x, v.y, v.z)
    end
    return vector3(tonumber(v[1]) or 0, tonumber(v[2]) or 0, tonumber(v[3]) or 0)
end

-- small helper to clamp values
function Util.clamp(v, lo, hi)
    local n = tonumber(v) or 0
    if lo and n < lo then return lo end
    if hi and n > hi then return hi end
    return n
end

return Util
