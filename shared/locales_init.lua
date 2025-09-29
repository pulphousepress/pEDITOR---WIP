-- shared/locales_init.lua (AUTO-GENERATED stub)
-- Provides a minimal locale loader and default strings.
local la = la_peditor

la.Locales = la.Locales or {}
la.Locales['en'] = la.Locales['en'] or {
    ['menu_title'] = 'Appearance Editor',
    ['save_success'] = 'Appearance saved.',
    ['load_success'] = 'Appearance loaded.',
    ['invalid_data'] = 'Invalid appearance data.',
}

function la.GetLocale(key)
    local lang = la.Config and la.Config.Locale or 'en'
    if la.Locales[lang] and la.Locales[lang][key] then
        return la.Locales[lang][key]
    end
    -- fallback to english or raw key
    return (la.Locales['en'] and la.Locales['en'][key]) or key
end
