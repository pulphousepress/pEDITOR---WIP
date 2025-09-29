-- resources/la_peditor/shared/theme.lua
-- theme="1950s-cartoon-noir"
-- Theme metadata and helper functions (namespaced)

if not la_peditor then la_peditor = {} end
la_peditor.Theme = la_peditor.Theme or {}

la_peditor.Theme.Metadata = la_peditor.Theme.Metadata or {
    name = "Los Animales RP",
    style = "1950s-cartoon-noir",
    era = "1920s–1970s",
    visual = {
        fonts = "retro sans-serif",
        ui_palette = { "sepia", "greyscale", "soft pastels" },
        debug_style = "typewriter",
        log_prefix = "[la_peditor]"
    },
    policy = {
        enforceEraLimits = true,
        allowFantasyToontown = true,
        blockModernAssets = true,
        approvedAnimalHeads = { "raccoon", "fox", "wolf" }
    }
}

function la_peditor.Theme.IsAssetEraCompliant(asset)
    if not asset then return false end
    if asset.era and tonumber(asset.era) then
        return tonumber(asset.era) <= 1970
    end
    -- If asset has no era metadata, be conservative and return false
    return false
end

function la_peditor.Theme.IsToontownNamespace(asset)
    return asset and asset.id and tostring(asset.id):match("^bostra:toontown:")
end

function la_peditor.Theme.ApplyVisualMetadataToText(msg)
    return (la_peditor.Theme.Metadata.log_prefix or "[la_peditor]") .. " " .. tostring(msg) .. " — theme=\"" .. (la_peditor.Theme.Metadata.style or "1950s-cartoon-noir") .. "\""
end

print("[la_peditor/shared/theme.lua] loaded — theme metadata registered")
return la_peditor.Theme
