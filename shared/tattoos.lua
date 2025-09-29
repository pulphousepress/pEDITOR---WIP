-- resources/la_peditor/shared/tattoos.lua
-- theme="1950s-cartoon-noir"
-- Era-appropriate tattoo whitelist (namespaced)

if not la_peditor then la_peditor = {} end
la_peditor.Config = la_peditor.Config or {}

la_peditor.Config.Tattoos = la_peditor.Config.Tattoos or {
    male = {
        { collection = "mpbeach_overlays", overlay = "FM_Hair_Fuzz" },
        { collection = "mpbeach_overlays", overlay = "FM_Tat_Award_M_001" },
        { collection = "mpbeach_overlays", overlay = "FM_Tat_M_002" },
        { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_001_M" },
        { collection = "mphipster_overlays", overlay = "FM_Tat_Hip_M_009" }
    },
    female = {
        { collection = "mpbeach_overlays", overlay = "FM_Hair_Fuzz" },
        { collection = "mpbeach_overlays", overlay = "FM_Tat_Award_F_001" },
        { collection = "mpbeach_overlays", overlay = "FM_Tat_F_003" },
        { collection = "mpbiker_overlays", overlay = "MP_Biker_Hair_001_F" },
        { collection = "mphipster_overlays", overlay = "FM_Tat_Hip_F_009" }
    }
}

-- Safe getter (use la_peditor.GetTattooList if preferred)
function la_peditor.GetTattooList(gender)
    return (la_peditor.Config and la_peditor.Config.Tattoos and la_peditor.Config.Tattoos[gender]) or {}
end

-- Explicit legacy global function for existing code (keeps GetTattooList available globally)
if not _G.GetTattooList then
    GetTattooList = la_peditor.GetTattooList
end

print("[la_peditor/shared/tattoos.lua] loaded — era-appropriate tattoo list ready")
return la_peditor.Config.Tattoos
