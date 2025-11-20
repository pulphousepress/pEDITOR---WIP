-- fxmanifest.lua
fx_version 'cerulean'
game 'gta5'

name 'la_peditor'
author 'Martin / la_peditor'
description 'la_peditor — 1950s-cartoon-noir appearance editor (qbx_core compatible)'
version '1.0.0'

lua54 'yes'

-- NOTE: keep dependencies minimal and ensure they are started before la_peditor in server.cfg.
-- We prefer qbx_core when present but do not require it so standalone servers can still load.

dependencies {
    'ox_lib',
    'oxmysql'
}

-- Shared (loaded before client/server)
shared_scripts {
    'shared/compat.lua',
    'shared/config.lua',
    'shared/common.lua',
    'shared/locales_init.lua',
    'shared/theme.lua',
    'shared/blacklist.lua',
    'shared/peds.lua',
    'shared/assets.lua',
    'shared/tattoos.lua',
    'locales/locales.lua',
    'shared/framework/**/*.lua'
}

-- Client scripts (order matters: core entry then modules)
client_scripts {
    'client/client.lua',
    'client/defaults.lua',
    'client/common.lua',
    'client/appearance.lua',
    'client/outfits.lua',
    'client/props.lua',
    'client/blips.lua',
    'client/zones.lua',
    'client/stats.lua',

    -- client framework adapters / modules (load after core client files)
    'client/framework/*.lua',
    'client/management/*.lua',
    'client/radial/*.lua',
    'client/target/*.lua',

    -- game helpers (camera, nui, utilities)
    'game/constants.lua',
    'game/util.lua',
    'game/customization.lua',
    'game/nui.lua'
}

-- Server scripts (order: DB adapter + util -> permissions -> main server)
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database/*.lua',
    'server/util.lua',
    'server/permissions.lua',
    'server/server.lua',
    'server/test.lua',
    'server/framework/**/*.lua'
}

-- Web UI (NUI)
files {
    'web/dist/index.html',
    'web/dist/*',
    'web/dist/**/*',
    'config/assetpacks/index.json',
    'config/assetpacks/*.json'
}
ui_page 'web/dist/index.html'

-- Exports (runtime helpers)
exports {
    'la_peditor_getPedAppearance',
    'la_peditor_setPlayerModel',
    'ApplyAsset'
}

provides {
    'la_peditor'
}
