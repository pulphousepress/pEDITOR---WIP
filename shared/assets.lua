-- shared/assets.lua
-- theme="1950s-cartoon-noir"
-- Data-driven asset pack loader for pEditor (masks, clothing, props, hair, beards).
-- Owners can drop JSON files into config/assetpacks and list them in index.json or Config.AssetPacks.

if not la_peditor then la_peditor = {} end
la_peditor.Assets = {}
local Assets = la_peditor.Assets

local resourceName = (GetCurrentResourceName and GetCurrentResourceName()) or "la_peditor"
local log = function(level, ...)
    if la_peditor and type(la_peditor.log) == "function" then
        la_peditor.log(level, ...)
    else
        print(('[la_peditor][%s] %s'):format(level, table.concat({...}, ' ')))
    end
end

local function shallowCopy(tbl)
    local out = {}
    for k, v in pairs(tbl) do out[k] = v end
    return out
end

local function decodeJson(path)
    local raw = LoadResourceFile(resourceName, path)
    if not raw then return nil, 'missing' end
    if not json or type(json.decode) ~= 'function' then return nil, 'json-missing' end
    local ok, parsed = pcall(json.decode, raw)
    if not ok or type(parsed) ~= 'table' then
        return nil, 'decode-failed'
    end
    return parsed, nil
end

local COMPONENT_NAME_TO_ID = {
    mask = 1, masks = 1,
    torso = 3, torsos = 3, arms = 3,
    legs = 4, pants = 4,
    bag = 5, bags = 5,
    shoes = 6,
    accessory = 7, accessories = 7, chains = 7,
    undershirt = 8, undershirts = 8,
    bodyarmor = 9, armor = 9,
    decal = 10, decals = 10,
    jacket = 11, jackets = 11, top = 11
}

local PROP_NAME_TO_ID = {
    hat = 0, hats = 0,
    glasses = 1,
    ear = 2, ears = 2,
    watch = 6, watches = 6,
    bracelet = 7, bracelets = 7
}

Assets.Registry = { props = {}, components = {}, hair = {}, beards = {} }
Assets.ById = {}
Assets.Packs = {}

local function registerEntry(category, entry, packId)
    if not Assets.Registry[category] then Assets.Registry[category] = {} end
    local record = shallowCopy(entry)
    record.pack = packId
    record.category = record.category or category
    if not record.id or record.id == '' then
        record.id = ("%s:%s:%s"):format(packId, category, #Assets.Registry[category] + 1)
    end
    if Assets.ById[record.id] then
        log('warn', ('[assets] Duplicate asset id "%s" overwritten (pack=%s)'):format(record.id, tostring(packId)))
    end
    Assets.ById[record.id] = record
    Assets.Registry[category][#Assets.Registry[category] + 1] = record
end

local function normalizeComponent(slotName, entry)
    local componentId = tonumber(entry.component_id) or tonumber(entry.slot)
    if not componentId and slotName then
        componentId = COMPONENT_NAME_TO_ID[slotName:lower()]
    end
    if not componentId then return nil, 'component-id-missing' end
    return {
        id = entry.id,
        label = entry.label or slotName or ("Component " .. componentId),
        component_id = componentId,
        drawable = tonumber(entry.drawable) or 0,
        texture = tonumber(entry.texture) or 0,
        palette = tonumber(entry.palette) or 0,
        type = 'component'
    }
end

local function normalizeProp(slotName, entry)
    local propId = tonumber(entry.prop_id) or tonumber(entry.slot)
    if not propId and slotName then
        propId = PROP_NAME_TO_ID[slotName:lower()]
    end
    if propId == nil then return nil, 'prop-id-missing' end
    return {
        id = entry.id,
        label = entry.label or slotName or ("Prop " .. propId),
        prop_id = propId,
        drawable = tonumber(entry.drawable) or -1,
        texture = tonumber(entry.texture) or 0,
        type = 'prop'
    }
end

local function normalizeHair(entry)
    local drawable = tonumber(entry.drawable or entry.style)
    if drawable == nil then return nil, 'hair-style-missing' end
    return {
        id = entry.id,
        label = entry.label or 'Hair Style',
        drawable = drawable,
        texture = tonumber(entry.texture) or 0,
        color = tonumber(entry.color) or 0,
        highlight = tonumber(entry.highlight or entry.highlightColor or entry.color) or 0,
        type = 'hair'
    }
end

local function normalizeBeard(entry)
    return {
        id = entry.id,
        label = entry.label or 'Beard',
        overlay = tonumber(entry.overlay) or 1,
        style = tonumber(entry.style or entry.drawable) or 0,
        opacity = tonumber(entry.opacity or entry.alpha) or 1.0,
        color = tonumber(entry.color) or 0,
        highlight = tonumber(entry.highlight or entry.color) or 0,
        type = 'beard'
    }
end

local function mergePack(packId, packData)
    local counts = { props = 0, components = 0, hair = 0, beards = 0 }
    if type(packData.props) == 'table' then
        for slot, entries in pairs(packData.props) do
            if type(entries) == 'table' then
                for _, entry in ipairs(entries) do
                    local normalized, err = normalizeProp(slot, entry)
                    if normalized then
                        registerEntry('props', normalized, packId)
                        counts.props = counts.props + 1
                    else
                        log('warn', ('[assets] Prop skipped (%s:%s): %s'):format(packId, tostring(slot), tostring(err)))
                    end
                end
            end
        end
    end
    if type(packData.components) == 'table' then
        for slot, entries in pairs(packData.components) do
            if type(entries) == 'table' then
                for _, entry in ipairs(entries) do
                    local normalized, err = normalizeComponent(slot, entry)
                    if normalized then
                        registerEntry('components', normalized, packId)
                        counts.components = counts.components + 1
                    else
                        log('warn', ('[assets] Component skipped (%s:%s): %s'):format(packId, tostring(slot), tostring(err)))
                    end
                end
            end
        end
    end
    if type(packData.hair) == 'table' then
        for _, entry in ipairs(packData.hair) do
            local normalized, err = normalizeHair(entry)
            if normalized then
                registerEntry('hair', normalized, packId)
                counts.hair = counts.hair + 1
            else
                log('warn', ('[assets] Hair skipped (%s): %s'):format(packId, tostring(err)))
            end
        end
    end
    if type(packData.beards) == 'table' then
        for _, entry in ipairs(packData.beards) do
            local normalized, err = normalizeBeard(entry)
            if normalized then
                registerEntry('beards', normalized, packId)
                counts.beards = counts.beards + 1
            else
                log('warn', ('[assets] Beard skipped (%s): %s'):format(packId, tostring(err)))
            end
        end
    end
    Assets.Packs[#Assets.Packs + 1] = {
        id = packId,
        name = packData.name or packId,
        description = packData.description,
        file = packData.__file,
        counts = counts
    }
end

local function gatherPackPaths()
    local cfg = la_peditor.Config or {}
    local paths = {}
    local seen = {}
    local function addPath(path)
        if type(path) ~= 'string' or path == '' then return end
        if seen[path] then return end
        seen[path] = true
        paths[#paths + 1] = path
    end

    if type(cfg.AssetPacks) == 'table' then
        for _, path in ipairs(cfg.AssetPacks) do addPath(path) end
    end

    local indexPath = cfg.AssetPackIndex or 'config/assetpacks/index.json'
    local index, err = decodeJson(indexPath)
    if index then
        local list = index.packs or index
        if type(list) == 'table' then
            for _, path in ipairs(list) do addPath(path) end
        elseif type(list) == 'string' then
            addPath(list)
        end
    else
        log('debug', ('[assets] index %s not loaded (%s)'):format(indexPath, tostring(err)))
    end

    if #paths == 0 then
        addPath('config/assetpacks/base.json')
    end
    return paths
end

local function loadPacks()
    Assets.Registry = { props = {}, components = {}, hair = {}, beards = {} }
    Assets.ById = {}
    Assets.Packs = {}
    local packPaths = gatherPackPaths()
    for _, path in ipairs(packPaths) do
        local data, err = decodeJson(path)
        if not data then
            log('warn', ('[assets] Failed to load %s (%s)'):format(path, tostring(err)))
        else
            data.__file = path
            local packId = data.id or data.name or path
            mergePack(packId, data)
            log('info', ('[assets] Loaded pack %s (%s)'):format(packId, path))
        end
    end
end

loadPacks()

function Assets.GetSummary()
    local summary = { theme = la_peditor.Theme and la_peditor.Theme.Metadata and la_peditor.Theme.Metadata.style, packs = {}, categories = {} }
    for _, pack in ipairs(Assets.Packs or {}) do
        summary.packs[#summary.packs + 1] = {
            id = pack.id,
            name = pack.name,
            description = pack.description,
            file = pack.file,
            counts = pack.counts
        }
    end
    for category, entries in pairs(Assets.Registry or {}) do
        summary.categories[#summary.categories + 1] = {
            category = category,
            count = #entries
        }
    end
    return summary
end

function Assets.FindEntryById(id)
    if not id then return nil end
    return Assets.ById[id]
end

function Assets.GetEntries(category)
    return (Assets.Registry and Assets.Registry[category]) or {}
end

function Assets.RegisterPack(packId, data)
    if type(data) ~= 'table' then return false end
    packId = packId or ("lua_pack_%d"):format(#Assets.Packs + 1)
    mergePack(packId, data)
    log('info', ('[assets] Registered Lua pack %s'):format(packId))
    return true
end

log('info', ('shared/assets.lua loaded (%d packs)'):format(#Assets.Packs))
return Assets
