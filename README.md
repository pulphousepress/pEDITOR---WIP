# la_peditor (Los Animales RP Edition)

🌆 Fully theme-compliant player appearance system for QBox-based RP servers.
🎩 Theme: `1950s-cartoon-noir`

## Features
- Default appearance based on gender
- Outfit application on spawn
- NUI-based editor with era-appropriate filtering
- `/peditor_test` and `/test_peditor_outfit` for debug

## Installation
1. Place in `resources/[local]/la_peditor`
2. Add to `server.cfg`:

```
ensure oxmysql
ensure ox_lib
ensure qbx_core
ensure la_peditor
```

3. Set `setr qbx:enableBridge true`

## Compatibility
- ✅ QBox native (qbx_core)
- ✅ oxmysql
- ✅ ox_lib
- ❌ Not compatible with old qb-core or ESX

## License
MIT — Copyright (c) pulphouse press
