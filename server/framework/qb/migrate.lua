-- server/framework/qb/migrate.lua
-- theme="1950s-cartoon-noir"
-- Safe migration handlers for other appearance systems -> la_peditor
-- Hardened: tolerant of missing QBCore, DB, lib; non-blocking; timeouts on waits.

if not la_peditor then la_peditor = {} end
la_peditor.Framework = la_peditor.Framework or {}
local Framework = la_peditor.Framework

-- Safe logger helper (falls back to print)
local function log(level, ...)
    if la_peditor and type(la_peditor.log) == "function" then
        la_peditor.log(level, ...)
    else
        local msg = table.concat({...}, " ")
        print(("[la_peditor][%s] %s"):format(level, msg))
    end
end

-- Defensive QBCore detection (supports qb-core and qbx_core)
local function getQBCore()
    local ok, qb = pcall(function()
        if exports and exports['qb-core'] and type(exports['qb-core'].GetCoreObject) == "function" then
            return exports['qb-core']:GetCoreObject()
        elseif exports and exports['qbx_core'] and type(exports['qbx_core'].GetCoreObject) == "function" then
            return exports['qbx_core']:GetCoreObject()
        elseif rawget(_G, "QBCore") then
            return rawget(_G, "QBCore")
        end
        return nil
    end)
    if ok then return qb end
    return nil
end

local QBCore = getQBCore()
local lib = la_peditor.lib or (type(_G) == "table" and rawget(_G, "lib")) or nil
local Database = la_peditor.Database or (pcall(require, "la_peditor.server.database.database") and la_peditor.Database) or nil
local Config = la_peditor.Config or {}

-- small helper: notify to source or server console (lib.notify if available)
local function safeNotify(targetSource, payload)
    if type(targetSource) ~= "number" or targetSource == 0 then
        log("info", "notify (console):", payload.title or payload.message or "")
        return
    end
    if lib and type(lib.notify) == "function" then
        pcall(function() lib.notify(targetSource, payload) end)
    else
        -- fallback to TriggerClientEvent chat message
        pcall(function()
            TriggerClientEvent("chat:addMessage", targetSource, { color = {200,180,80}, args = { payload.title or "la_peditor", payload.description or "" } })
        end)
    end
end

-- small safe wait-with-timeout helper
local function wait_timeout(predicate_fn, timeout_ms)
    local deadline = GetGameTimer() + (timeout_ms or 5000)
    while not predicate_fn() and GetGameTimer() < deadline do
        Wait(10)
    end
    return predicate_fn()
end

-- Migrate from fivem-appearance -> playerskins table
local function MigrateFivemAppearance(source)
    if not Database or not Database.Players or not Database.PlayerSkins then
        safeNotify(source, {
            title = "Migrate",
            description = "Database helpers unavailable; cannot migrate.",
            type = "error",
            position = (Config.NotifyOptions and Config.NotifyOptions.position) or "top"
        })
        log("warn", "MigrateFivemAppearance: Database helpers missing")
        return
    end

    log("info", "Starting fivem-appearance -> playerskins migration")
    local allPlayers = Database.Players.GetAll() or {}
    local playerSkins = {}

    for i = 1, #allPlayers do
        local row = allPlayers[i]
        if row and row.skin and tostring(row.skin) ~= "" then
            table.insert(playerSkins, {
                citizenID = row.citizenid or row.citizenID or row.citizenId,
                skin = row.skin
            })
        end
    end

    local migrated = 0
    for i = 1, #playerSkins do
        local rec = playerSkins[i]
        local ok, decoded = pcall(function() return json.decode(rec.skin) end)
        if ok and decoded and decoded.model then
            Database.PlayerSkins.Add(rec.citizenID, decoded.model, rec.skin, 1)
            migrated = migrated + 1
        else
            log("warn", ("Skipping invalid skin for %s"):format(tostring(rec.citizenID)))
        end
    end

    safeNotify(source, {
        title = "Migration",
        description = ("Migrated %d entries from fivem-appearance"):format(migrated),
        type = "success",
        position = (Config.NotifyOptions and Config.NotifyOptions.position) or "top"
    })

    log("info", ("MigrateFivemAppearance complete — migrated %d entries"):format(migrated))
end

-- Migrate from qb-clothing via client-side helper events (safe, with timeouts)
local function MigrateQBClothing(source)
    if not Database or not Database.PlayerSkins then
        safeNotify(source, {
            title = "Migrate",
            description = "Database helpers unavailable; cannot migrate qb-clothing.",
            type = "error",
            position = (Config.NotifyOptions and Config.NotifyOptions.position) or "top"
        })
        log("warn", "MigrateQBClothing: Database helpers missing")
        return
    end

    local allPlayerSkins = Database.PlayerSkins.GetAll() or {}
    local migrated = 0

    for i = 1, #allPlayerSkins do
        local ps = allPlayerSkins[i]
        if ps and ps.model and tonumber(ps.model) == nil then
            -- skip entries that do not look numeric (means already migrated/legacy)
            safeNotify(source, {
                title = "Migration",
                description = "qb-clothing entries appear incompatible; skipping some entries.",
                type = "inform",
                position = (Config.NotifyOptions and Config.NotifyOptions.position) or "top"
            })
        else
            -- trigger client migration event and wait for response via server event handler
            local migrated_flag = false
            local token = ("la_peditor_migrate_token_%d_%d"):format(GetGameTimer(), i)

            local handlerName = "la_peditor:server:migrate-qb-clothing-skin"
            -- The client should call back the handler (this file also listens below) to confirm each migration.
            -- We will attempt to trigger a client event for migration; if no client responds within timeout, skip.
            local clients = GetPlayers()
            for _, pid in ipairs(clients) do
                local ok, _ = pcall(function()
                    TriggerClientEvent("la_peditor:client:migration:load-qb-clothing-skin", tonumber(pid), ps)
                end)
            end

            -- Wait short period for client to call back (via RegisterNetEvent handler below sets a continue flag)
            wait_timeout(function() return _G.__la_peditor_migrate_continue == true end, 5000)
            if _G.__la_peditor_migrate_continue == true then
                migrated = migrated + 1
                _G.__la_peditor_migrate_continue = false
            else
                log("warn", "MigrateQBClothing: client callback not received for entry idx=" .. tostring(i))
            end
        end
    end

    -- ask clients to reload skin
    local clients = GetPlayers()
    for _, pid in ipairs(clients) do
        pcall(function() TriggerClientEvent("illenium-appearance:client:reloadSkin", tonumber(pid)) end)
    end

    safeNotify(source, {
        title = "Migration",
        description = ("Migrated %d skins from qb-clothing"):format(migrated),
        type = "success",
        position = (Config.NotifyOptions and Config.NotifyOptions.position) or "top"
    })

    log("info", ("MigrateQBClothing complete — migrated %d entries"):format(migrated))
end

-- Server event used by clients to indicate a migration step completed.
RegisterNetEvent("la_peditor:server:migrate-qb-clothing-skin", function(citizenid, appearance)
    local src = source
    if not citizenid or not appearance then
        log("warn", "migrate-qb-clothing-skin called with invalid arguments")
        return
    end

    -- safe DB update
    if Database and Database.PlayerSkins and type(Database.PlayerSkins.Add) == "function" then
        Database.PlayerSkins.DeleteByCitizenID(citizenid)
        Database.PlayerSkins.Add(citizenid, appearance.model or appearance.Model, json.encode(appearance), 1)
    end

    -- mark continue flag for the waiting migration loop (global but short-lived)
    _G.__la_peditor_migrate_continue = true

    -- notify the requesting source if present
    if src and src > 0 then
        safeNotify(src, {
            title = "Migration",
            description = "Skin migrated for " .. tostring(citizenid),
            type = "success",
            position = (Config.NotifyOptions and Config.NotifyOptions.position) or "top"
        })
    end
end)

-- Register admin command (uses lib.addCommand if present, else fallback to RegisterCommand for server console)
local function registerAdminCommand()
    if lib and type(lib.addCommand) == "function" then
        lib.addCommand("migrateskins", {
            help = "Migrate player skins from other appearance systems (fivem-appearance | qb-clothing).",
            params = {
                { name = "resourceName", type = "string" },
            },
            restricted = "group.admin"
        }, function(source, args)
            local resourceName = args and args.resourceName
            if not resourceName then
                safeNotify(source, { title = "Migration", description = "Usage: migrateskins <fivem-appearance|qb-clothing>", type = "error" })
                return
            end
            if resourceName == "fivem-appearance" then
                CreateThread(function() MigrateFivemAppearance(source) end)
            elseif resourceName == "qb-clothing" then
                CreateThread(function() MigrateQBClothing(source) end)
            else
                safeNotify(source, { title = "Migration", description = "Unknown resource type", type = "error" })
            end
        end)
        log("info", "Registered migrateskins via lib.addCommand")
    else
        RegisterCommand("migrateskins", function(source, args)
            if source ~= 0 then
                -- console-only fallback or restricted (quick check)
                local allowed = false
                if la_peditor.Permissions and type(la_peditor.Permissions.CanUsePedEditor) == "function" then
                    allowed = la_peditor.Permissions.CanUsePedEditor(source)
                end
                if not allowed then
                    safeNotify(source, { title = "Migration", description = "You are not permitted to run this command.", type = "error" })
                    return
                end
            end
            local resourceName = args and args[1]
            if not resourceName then
                safeNotify(source, { title = "Migration", description = "Usage: /migrateskins <fivem-appearance|qb-clothing>", type = "error" })
                return
            end
            if resourceName == "fivem-appearance" then
                CreateThread(function() MigrateFivemAppearance(source) end)
            elseif resourceName == "qb-clothing" then
                CreateThread(function() MigrateQBClothing(source) end)
            else
                safeNotify(source, { title = "Migration", description = "Unknown resource type", type = "error" })
            end
        end, true)
        log("info", "Registered migrateskins via RegisterCommand fallback")
    end
end

-- init: only register if QBCore detected (migrations target qb systems)
CreateThread(function()
    if not QBCore then
        log("info", "QBCore not detected; migration command will still register but will warn if used.")
    end
    registerAdminCommand()
end)
