-- resources/la_peditor/shared/peds.lua
-- theme="1950s-cartoon-noir"
-- Ped whitelist and anthro/head-mask helpers (namespaced)

if not la_peditor then la_peditor = {} end
la_peditor.SharedPeds = la_peditor.SharedPeds or {}

local SharedPeds = la_peditor.SharedPeds

SharedPeds.AllowedPeds = SharedPeds.AllowedPeds or {
    "mp_m_freemode_01",
    "mp_f_freemode_01"
}

SharedPeds.SpeciesHeadMask = SharedPeds.SpeciesHeadMask or {
    raccoon = { component_id = 1, drawable = 21, texture = 0 },
    fox     = { component_id = 1, drawable = 22, texture = 0 },
    wolf    = { component_id = 1, drawable = 23, texture = 0 }
}

function SharedPeds.ValidateModel(model)
    if not model then return false end
    for _, m in ipairs(SharedPeds.AllowedPeds) do
        if tostring(m) == tostring(model) then return true end
    end
    return false
end

function SharedPeds.GetHeadMask(species)
    return SharedPeds.SpeciesHeadMask[species] or SharedPeds.SpeciesHeadMask.raccoon
end

-- Compatibility shim: if older code expects SharedPeds global, set it only if not already present.
if not _G.SharedPeds then
    SharedPedsGlobal = SharedPeds -- avoid using bare SharedPeds global, expose a named symbol instead
end

print("[la_peditor/shared/peds.lua] loaded")
return SharedPeds
