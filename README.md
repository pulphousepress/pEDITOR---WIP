# pEditor – Character Creator Spec

## 📑 Table of Contents
- [UX Principles (player-facing)](#ux-principles-player-facing)  
- [Permissions & Commands (staff)](#permissions--commands-staff)  
- [Money & Items (hook points)](#-money--items-hook-points)  
- [Data Model (server-side)](#-data-model-server-side)  
- [Origins (lore-friendly presets + custom)](#-origins-lore-friendly-presets--custom)  
- [Edit Points (shops/locations)](#-edit-points-shopslocations)  
- [Wardrobes](#-wardrobes)  
- [Programmatic Open](#️-programmatic-open-for-housingraid-scripts)  
- [Editor Menu](#-editor-menu)  
- [Hooks & Exports](#-hooks--exports)  
- [Anti-Grief](#-anti-grief)  
- [Camera Controls](#-camera-controls)  
- [Passport / First-Run Flow](#-passport--first-run-flow)  
- [Installation](#-installation)  
- [Roadmap](#-roadmap-next-steps)  

---

Open source. Standalone; zero framework dependency unless you toggle optional item checks or QBX notify.

One-key menu. Binds a single key/command to open the editor.

Code-driven UI. No brittle XML—components are defined in config (json/lua).

Drag-n-drop assets. Import masks, clothes, hair, beards, etc. by updating config + simple manifest tweak if needed.

Server tools. Staff commands to open editor for self/others; set/reset ped models globally or per player.

qbox/qbcore friendly. Works standalone, also plays nice with qbox/qbcore.

---

## UX Principles (player-facing)

- **“Origin”, not “Nationality.”** Lore-friendly origins (Earth regions, anthro lands, off-world, toon realms, or custom OC text).  
- **Zero accidental nukes.** During passport/first-run, menu can’t be closed in a way that saves blank data.  
- **Cinematic view.** Free camera zoom + rotate around ped; context zooms (face, torso, legs) while editing.  
- **Modular edit points.** Place Barbers, Plastic Surgeons, Clothing Stores, etc. Each point exposes only the components you whitelist.  
- **Wardrobes anywhere.** House interiors, safehouses, crew HQs; also openable by API call for housing scripts.  
- **Over-the-top morphs (optional).** “Exaggerated sliders” mode to push face shapes toward animal/creature silhouettes (with server-side clamps so you don’t spawn a geometry crime).  

---

## Permissions & Commands (staff)

| Command | Who | What it does |
|---------|-----|--------------|
| `/peditor [id]` | Staff only | Opens editor for yourself or target player. |
| `/setped [id] [model]` | Staff only | Force-sets a model for player (overrides their chosen one). |
| `/delped [id]` | Staff only | Clears forced model; reverts to player’s saved model. |

Players can open the editor via your chosen keybind or `/pe` (configurable).

---

## 💰 Money & Items (hook points)

- **Out of the box:** No payments. Editing is free.  
- **Hooks provided:** `OnBeforeSave`, `OnUseEditPoint`, `OnOpenWardrobe` – return true/false to allow/deny based on your economy.  
- **Optional checks:** Item-gated access (e.g., “barber voucher”), job/role gating, cooldowns.  

---

## 🗂 Data Model (server-side)

Saved per character (DB row or JSON):

```json
{
  "characterId": "steam:110000112345678",
  "model": "mp_m_freemode_01",
  "appearance": {
    "face": {"shapeMix": 0.2, "mother": 21, "father": 6, "skinMix": 0.45},
    "features": {"noseWidth": -0.2, "jawBoneWidth": 0.4},
    "overdrive": {"snout": 0.6, "earPoint": 0.35, "muzzleWidth": 0.3},
    "hair": {"style": 12, "color": 3, "highlight": 1},
    "makeup": {"type": 5, "opacity": 0.4, "color": 2},
    "beard": {"style": 10, "opacity": 0.8, "color": 1},
    "eyes": {"color": 4, "size": 0},
    "props": [{"slot": "mask", "drawable": 7, "texture": 2}]
  },
  "origin": {"type": "preset", "value": "Califurnia"},
  "wardrobe": [
    {"name": "Heist Fit", "components": {"torso": [15,2], "legs": [21,0], "shoes": [10,1]}}
  ],
  "meta": {"lastEdited": 1727651200, "version": 3}
}
```

---

## 🌍 Origins (lore-friendly presets + custom)

```lua
Origins = {
  { id="califurnia", label="Califurnia", voice="V_Furry_A", emote="wave2"},
  { id="toontown",   label="ToonTown",   voice="V_Toon_A",  emote="jazzhands"},
  { id="offworld",   label="Offworld",   voice="V_Synth_A", emote="salute"},
  { id="custom",     label="Custom (OC)", allowText=true, maxLen=24 }
}
```

---

## 🏬 Edit Points (shops/locations)

```lua
EditPoints = {
  {
    id = "vespucci_barber",
    label = "Barber",
    coords = vec3(-1282.0, -1117.3, 6.99),
    heading = 90.0,
    components = { "hair", "beard", "eyebrows", "makeup" },
    openKey = "E"
  },
  {
    id = "pillbox_plastic",
    label = "Plastic Surgeon",
    coords = vec3(299.0, -581.0, 43.2),
    components = { "face", "features", "overdrive" }
  },
  {
    id = "rockford_threads",
    label = "Clothing Store",
    coords = vec3(-1197.6, -772.6, 17.3),
    components = { "props", "clothes", "wardrobeSave" }
  }
}
```

---

## 👗 Wardrobes

```lua
Wardrobes = {
  { id="apt_12",   label="Apartment Closet", coords=vec3(-267.5, -957.1, 31.2), radius=1.5 },
  { id="gang_hq",  label="HQ Locker", coords=vec3(112.3, -2005.9, 20.9) }
}
```

---

## ⚙️ Programmatic Open (for housing/raid scripts)

```lua
-- Server -> Client
TriggerClientEvent("peditor:openWardrobe", playerId, "apt_12")
```

---

## 📝 Editor Menu

```lua
EditorMenu = {
  global = { "origin","face","features","hair","beard","eyes","props","clothes","wardrobeSave","wardrobeLoad" },
  allowModelSelect = true,   -- remove "model" if false
  exaggeratedMode = false    -- true at surgeons only via EditPoints
}
```

---

## 🔌 Hooks & Exports

### Server Hooks
```lua
exports("OnBeforeSave", function(playerId, data) return true end)
exports("OnUseEditPoint", function(playerId, editPointId) return true end)
exports("OnOpenWardrobe", function(playerId, wardrobeId) return true end)
```

### Events
- `peditor:requestOpen(type, context)` → client → server  
- `peditor:save(data)` → client → server  
- `peditor:openEditor(context)` → server → client  
- `peditor:openWardrobe(id)` → server → client  
- `peditor:notify(level, message)` → server → client  

---

## 🛡 Anti-Grief

- Slider clamps (min/max).  
- Blacklist props/clothes combos known to crash.  
- Save rate limit (e.g., 1 per 2s).  
- Preview→Apply pattern to prevent half-applied looks.  

---

## 🎥 Camera Controls

- Scroll/Controller triggers to zoom.  
- Hold right mouse (or LB) to orbit.  
- Context snaps auto-frame face/torso/legs while editing.  
- Configurable zoom/orbit speed; locked during passport save.  

---

## 🛂 Passport / First-Run Flow

1. Player joins → First-Run Gate opens editor.  
2. Required fields: model (if enabled), base face, origin.  
3. Menu cannot be closed until required fields valid.  
4. On save:  
   - Validate.  
   - Fire `OnBeforeSave(playerId, data)` → return false to reject.  
   - Persist to DB or JSON.  
   - Broadcast `OnAfterSave(playerId, data)` for integrations.  

---

## 📦 Installation

1. Drop `peditor` into `resources/[local]`.  
2. Add to your `server.cfg`:  
   ```cfg
   ensure peditor
   ```

---

## 🛠 Roadmap (next steps)

- Economy/payment adapters (ox_inventory, qb-inventory, custom).  
- Photo booth export (PNG mugshots).  
- Outfit share codes.  
- Origin-based “story seeds.”  
- Accessibility tweaks (controller-first, color-blind safe).  

---
