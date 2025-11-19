# la_peditor (Los Animales RP Edition)

Fully theme compliant wrapper around PEDitor for QBox based Los Animales RP servers.

## Features

- Uses PEDitor for advanced character appearance editing
- Auto creates `skin_data` table if missing
- Applies base model by gender on spawn
- Applies saved PEDitor skin options on player load
- Simple exports for opening the editor in clothing or barber mode
- Ready to plug into era filters using `la_core` and `la_codex`

## Requirements

Add these to your `server.cfg` in this order:

```cfg
ensure oxmysql
ensure ox_lib
ensure qbx_core
ensure la_core
ensure PEDitor          # upstream PEDitor script
ensure la_peditor

Below is a first-pass, copy-paste-ready `la_peditor` wrapper that uses the PEDitor documentation you pasted and plugs it into your Los Animales / QBox stack.

It assumes:

* You already have the original `PEDitor` resource in `resources/[local]/PEDitor`
* You are using `qbx_core`, `ox_lib`, `oxmysql`, and your own `la_core` events
* You want `la_peditor` to:

  * Auto create the `skin_data` table
  * Apply base model + saved skin on spawn
  * Expose simple exports for opening the PEDitor menu in different modes
  * Be theme compliant and ready for era filtering later

You can refine era filtering and character lists later without changing the integration.

---

## 1. Folder layout

Create this structure in `resources/[local]/la_peditor`:

```text
la_peditor/
  fxmanifest.lua
  README.md

  config/
    config.lua
    server/
      configServer.lua

  client/
    main.lua
    editable/
      prechecks.lua
      handlers.lua

  server/
    main.lua

  data/
    pedModels.lua

  locales/
    en.json
```

Tiles and greenscreener live in the `PEDitor` resource as per its docs, so I am not duplicating that here.

---

## 2. fxmanifest.lua

```lua
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
    'client/editable/*.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'config/server/configServer.lua',
    'server/main.lua',
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
```

---

## 3. README.md

````markdown
# la_peditor (Los Animales RP Edition)

Fully theme compliant wrapper around PEDitor for QBox based Los Animales RP servers.

## Features

- Uses PEDitor for advanced character appearance editing
- Auto creates `skin_data` table if missing
- Applies base model by gender on spawn
- Applies saved PEDitor skin options on player load
- Simple exports for opening the editor in clothing or barber mode
- Ready to plug into era filters using `la_core` and `la_codex`

## Requirements

Add these to your `server.cfg` in this order:

```cfg
ensure oxmysql
ensure ox_lib
ensure qbx_core
ensure la_core
ensure PEDitor          # upstream PEDitor script
ensure la_peditor
````

Make sure your `PEDitor` resource is configured according to its documentation
(tiles, greenscreener, editable files, and so on).

## Basic usage

* On player load, `la_peditor`:

  * Sets base freemode model based on character gender
  * Loads saved PEDitor skin and applies it if present

### Commands (example)

You can bind these into any other script:

```lua
-- open normal editor
exports['la_peditor']:openSkinEditor('full')

-- open clothing shop mode
exports['la_peditor']:openSkinEditor('clothing')

-- open barber mode
exports['la_peditor']:openSkinEditor('barber')
```

## Server side

`la_peditor` auto creates the `skin_data` table on resource start so that
PEDitor can save and load skins without manual SQL migration.

## Notes

* Era filtering (limiting clothes and models to the Los Animales 1950s noir theme)
  should be handled in your `PEDitor` tiles and `data/pedModels.lua` files and in
  future `la_codex` integration.
