-- la_peditor/fxmanifest.lua
fx_version 'cerulean'
game 'gta5'

name 'la_peditor'
description 'Los Animales wrapper and integration for PEDitor character appearance system'
author 'pulphouse press / Los Animales RP'
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config/config.lua',
}

client_scripts {
    'client/main.lua',
    'client/shops.lua',
    'client/editable/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config/server/configServer.lua',
    'server/main.lua',
    'server/editable/database.lua',
}

files {
    'data/pedModels.lua',
    'locales/en.json',
}

dependencies {
    'ox_lib',
    'oxmysql',
    'qbx_core',
    'la_core',
    'PEDitor',       -- original PEDitor resource
}
