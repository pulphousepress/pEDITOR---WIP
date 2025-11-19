-- server/server.lua
-- theme="1950s-cartoon-noir"
-- Server events for saving/loading appearances. Hardened and DB-safe.

if not la_peditor then la_peditor = {} end
local la = la_peditor
local ServerUtil = la.ServerUtil or {}

-- Helper to validate an appearance table minimally
local function isValidAppearance(appearance)
    return appearance ~= nil and type(appearance) == "table"
end

-- Save appearance (client -> server)
RegisterServerEvent("la_peditor:saveAppearance")
AddEventHandler("la_peditor:saveAppearance", function(appearance)
    local src = source
    if not isValidAppearance(appearance) then
        la.log('warn', "[saveAppearance] Invalid appearance payload from source " .. tostring(src))
        return
    end

    local license = nil
    if ServerUtil and type(ServerUtil.GetPlayerIdentifier) == "function" then
        license = ServerUtil.GetPlayerIdentifier(src)
    end

    if not license then
        la.log('warn', "[saveAppearance] No identifier for source " .. tostring(src) .. " - aborting save.")
        return
    end

    -- sanitize appearance: avoid storing functions / userdata; only store basic types
    local ok, safePayload = pcall(function() return json.encode(appearance) end)
    if not ok or not safePayload then
        la.log('warn', "[saveAppearance] Failed to JSON encode appearance for " .. tostring(license))
        return
    end

    -- Upsert into DB
    local query = [[
        INSERT INTO la_peditor_appearances (license, appearance)
        VALUES (@license, @appearance)
        ON DUPLICATE KEY UPDATE appearance = @appearance
    ]]
    ServerUtil.DBExecute(query, { ['@license'] = license, ['@appearance'] = safePayload }, function(res)
        la.log('info', ("[saveAppearance] Saved appearance for %s (rows=%s)"):format(tostring(license), tostring(res)))
    end)
end)

-- Load appearance (client -> server)
RegisterServerEvent("la_peditor:loadAppearance")
AddEventHandler("la_peditor:loadAppearance", function()
    local src = source
    local license = nil
    if ServerUtil and type(ServerUtil.GetPlayerIdentifier) == "function" then
        license = ServerUtil.GetPlayerIdentifier(src)
    end

    if not license then
        la.log('warn', "[loadAppearance] No identifier for source " .. tostring(src) .. " - aborting load.")
        return
    end

    local query = [[ SELECT appearance FROM la_peditor_appearances WHERE license = @license ]]
    ServerUtil.DBFetchScalar(query, { ['@license'] = license }, function(appearanceJson)
        if not appearanceJson then
            la.log('info', ("[loadAppearance] No appearance found for %s"):format(tostring(license)))
            return
        end

        local ok, appearance = pcall(function() return json.decode(appearanceJson) end)
        if not ok or type(appearance) ~= "table" then
            la.log('warn', ("[loadAppearance] Failed to decode appearance for %s"):format(tostring(license)))
            return
        end

        -- Send to client (only if source is a player)
        if src and src > 0 then
            TriggerClientEvent("la_peditor:applyOutfit", src, appearance)
            la.log('info', ("[loadAppearance] Sent appearance to %s"):format(tostring(license)))
        end
    end)
end)

la.log('info', 'server/server.lua loaded')
