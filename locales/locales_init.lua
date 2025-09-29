-- la_peditor/shared/locales_init.lua
-- theme="1950s-cartoon-noir"
-- Safe locales initializer. Loads locale files if they exist, otherwise no-op.
-- This prevents fxmanifest warnings and avoids hard crashes when locales are missing.

local ok, err = pcall(function()
    local locales = {}
    local localeFiles = {
        'locales/en.lua', 'locales/fr.lua', 'locales/de.lua', 'locales/es-ES.lua',
        'locales/it.lua', 'locales/pt-BR.lua', 'locales/nl.lua', 'locales/ro-RO.lua',
        'locales/hu.lua', 'locales/ar.lua', 'locales/bg.lua', 'locales/zh-CN.lua', 'locales/zh-TW.lua'
    }

    for _, path in ipairs(localeFiles) do
        local file = io.open(path, 'r')
        if file then
            file:close()
            local succ, mod = pcall(function() return assert(loadfile(path))() end)
            if succ and type(mod) == 'table' then
                for k, v in pairs(mod) do
                    locales[k] = v
                end
            end
        end
    end

    -- Expose a simple getter
    LA_PEDITOR_LOCALES = LA_PEDITOR_LOCALES or {}
    for k, v in pairs(locales) do LA_PEDITOR_LOCALES[k] = v end
end)

if not ok then
    print('[la_peditor] locales_init failed — continuing without locales. theme="1950s-cartoon-noir"')
    print(tostring(err))
end
