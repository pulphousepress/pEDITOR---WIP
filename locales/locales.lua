-- la_peditor/locales/locales.lua
-- theme="1950s-cartoon-noir"
-- Locale loader for la_peditor. Exposes a fallback-safe global `_L` function for legacy code.
-- NOTE: legacy code uses _L("key") widely. We provide a safe implementation that avoids
-- creating globals if one already exists. For future refactor: prefer exports (GetLocale).

-- Load translations (only English is included; additional language files can be added as needed).
local ok, en = pcall(function() return require("locales.en") end)
local Locales = {}
if ok and type(en) == "table" then
    Locales["en"] = en
else
    Locales["en"] = {}
end

-- Default locale code
local DEFAULT_LOCALE = "en"

-- If the resource has a Config with `Locale`, try to use it; otherwise fallback to `en`.
local function getActiveLocale()
    if type(Config) == "table" and type(Config.Locale) == "string" and Locales[Config.Locale] then
        return Config.Locale
    end
    return DEFAULT_LOCALE
end

-- Retrieve localized string by key; supports formatting via string.format.
local function translate(key, ...)
    if not key then return "" end
    local locale = getActiveLocale()
    local dict = Locales[locale] or Locales[DEFAULT_LOCALE] or {}
    local value = dict[key] or dict[key:lower()] or key
    if select('#', ...) > 0 then
        -- Protect string.format usage
        local ok, res = pcall(string.format, value, ...)
        if ok then return res end
    end
    return value
end

-- Expose `_L` only if not present (legacy compatibility). This avoids stomping other resources.
if _G["_L"] == nil then
    _G["_L"] = translate
else
    -- If _L already exists, provide an exported accessor instead
    RegisterNetEvent("la_peditor:getLocale", function()
        local _src = source
        TriggerClientEvent("la_peditor:sendLocale", _src, getActiveLocale(), Locales[getActiveLocale()])
    end)
end

-- Also provide export-friendly getter
local function GetLocale()
    return getActiveLocale(), Locales[getActiveLocale()]
end

-- Make export available (server + client)
if (GetResourceState and GetResourceState(GetCurrentResourceName()) == "started") or true then
    exports("GetLocale", GetLocale)
end

return {
    GetLocale = GetLocale,
    translate = translate,
    Locales = Locales
}
