-- la_peditor/server/editable/database.lua
-- Custom database bridge for PEDitor on Los Animales / QBox.
-- Uses la_core or qbx_core to derive a canonical identifier
-- and persists appearance to the skin_data table.

local function getCanonicalIdentifier(source)
    source = tonumber(source) or source

    -- Preferred: la_core helper if present
    local hasLaCore, laCoreId = pcall(function()
        if exports['la_core'] and exports['la_core'].GetIdentifier then
            return exports['la_core']:GetIdentifier(source)
        end
        return nil
    end)

    if hasLaCore and laCoreId and laCoreId ~= '' then
        return ('la:%s'):format(laCoreId)
    end

    -- Fallback: qbx_core player data
    local ok, player = pcall(function()
        if exports['qbx_core'] and exports['qbx_core'].GetPlayer then
            return exports['qbx_core']:GetPlayer(source)
        end
        return nil
    end)

    if ok and player then
        -- QBox commonly has citizenid
        if player.citizenid then
            return ('cid:%s'):format(player.citizenid)
        end

        -- Some builds use nested PlayerData
        if player.PlayerData and player.PlayerData.citizenid then
            return ('cid:%s'):format(player.PlayerData.citizenid)
        end

        if player.license then
            return ('lic:%s'):format(player.license)
        end
    end

    -- Last fallback: source based identifier
    return ('src:%s'):format(source)
end

--- Saves player skin data to skin_data table.
--- Parameters:
---   source      number  Player server ID
---   skinOptions table   PEDitor style skin options (optional)
--- Returns:
---   boolean success
function saveSkinData(source, skinOptions)
    local identifier = getCanonicalIdentifier(source)
    if not identifier then
        print('[la_peditor] saveSkinData: missing identifier for ' .. tostring(source))
        return false
    end

    -- If caller did not pass options, ask PEDitor for the current skin
    if not skinOptions or type(skinOptions) ~= 'table' then
        local ok, currentSkin = pcall(function()
            return exports['PEDitor']:getSkinOptions()
        end)

        if not ok or type(currentSkin) ~= 'table' then
            print('[la_peditor] saveSkinData: could not fetch current skin options for ' .. identifier)
            return false
        end

        skinOptions = currentSkin
    end

    local encoded = json.encode(skinOptions)
    local existing = MySQL.single.await(
        'SELECT id FROM skin_data WHERE identifier = ? LIMIT 1',
        { identifier }
    )

    if not existing then
        local inserted = MySQL.update.await(
            'INSERT INTO skin_data (identifier, skinData) VALUES (?, ?)',
            { identifier, encoded }
        )
        local okInsert = inserted and inserted > 0
        if not okInsert then
            print('[la_peditor] saveSkinData: insert failed for ' .. identifier)
        end
        return okInsert
    else
        local updated = MySQL.update.await(
            'UPDATE skin_data SET skinData = ?, updated_at = CURRENT_TIMESTAMP WHERE identifier = ?',
            { encoded, identifier }
        )
        local okUpdate = updated and updated > 0
        if not okUpdate then
            print('[la_peditor] saveSkinData: update failed for ' .. identifier)
        end
        return okUpdate
    end
end

--- Retrieves player skin data from skin_data table.
--- Parameters:
---   source  number  Player server ID
--- Returns:
---   table or nil
function retrieveSkinData(source)
    local identifier = getCanonicalIdentifier(source)
    if not identifier then
        print('[la_peditor] retrieveSkinData: missing identifier for ' .. tostring(source))
        return nil
    end

    local row = MySQL.single.await(
        'SELECT skinData FROM skin_data WHERE identifier = ? LIMIT 1',
        { identifier }
    )

    if not row or not row.skinData then
        return nil
    end

    local ok, decoded = pcall(json.decode, row.skinData)
    if not ok or type(decoded) ~= 'table' then
        print('[la_peditor] retrieveSkinData: failed to decode skinData for ' .. identifier)
        return nil
    end

    return decoded
end

-- Optional helper export so other resources can use the same identifier logic
exports('getCanonicalIdentifier', getCanonicalIdentifier)

--Note: this assumes the skin_data schema created earlier:
-- id, identifier, skinData, updated_at.
