-- server/util.lua
-- theme="1950s-cartoon-noir"
-- Namespaced server utilities (no hidden globals). Adds safe DB wrappers and identifier helpers.

if not la_peditor then la_peditor = {} end
la_peditor.ServerUtil = la_peditor.ServerUtil or {}
local ServerUtil = la_peditor.ServerUtil

-- Debug printer (uses la_peditor.log)
function ServerUtil.DebugPrint(...)
    la_peditor.log('info', ...)
end

function ServerUtil.PrintDebug(...)
    if la_peditor.Config and la_peditor.Config.Debug then
        la_peditor.log('debug', ...)
    end
end

-- Get player's primary identifier (license preferred), fallback to first identifier available.
-- Returns nil for console (source==0) or if no identifier found.
function ServerUtil.GetPlayerIdentifier(source)
    if not source or source == 0 then return nil end
    local ids = GetPlayerIdentifiers(source) or {}
    -- prefer license:
    for _, v in ipairs(ids) do
        if tostring(v):match("^license:") then return tostring(v) end
    end
    -- fallback to steam:
    for _, v in ipairs(ids) do
        if tostring(v):match("^steam:") then return tostring(v) end
    end
    -- otherwise first id
    return ids[1]
end

-- Safely get a named DB function (MySQL.Async.fetchScalar / execute). Works with oxmysql / mysql-async alt.
local function get_mysql_async()
    if type(MySQL) == "table" and type(MySQL.Async) == "table" then
        return MySQL.Async
    end
    -- oxmysql exposes `exports.oxmysql` but we've included '@oxmysql/lib/MySQL.lua' in fxmanifest to inject MySQL globally.
    return nil
end

-- Safe execute wrapper: query, params table, callback(optional)
function ServerUtil.DBExecute(query, params, cb)
    local mysqlAsync = get_mysql_async()
    if not mysqlAsync or type(mysqlAsync.execute) ~= "function" then
        la_peditor.log('warn', "DBExecute: MySQL.Async.execute not available; DB disabled or not started.")
        if type(cb) == "function" then cb(false) end
        return
    end
    local ok, err = pcall(function()
        mysqlAsync.execute(query, params or {}, function(rowsChanged)
            if type(cb) == "function" then
                pcall(cb, rowsChanged)
            end
        end)
    end)
    if not ok then
        la_peditor.log('warn', "DBExecute error: " .. tostring(err))
        if type(cb) == "function" then cb(false) end
    end
end

-- Safe fetchScalar wrapper: query, params, callback(result)
function ServerUtil.DBFetchScalar(query, params, cb)
    local mysqlAsync = get_mysql_async()
    if not mysqlAsync or type(mysqlAsync.fetchScalar) ~= "function" then
        la_peditor.log('warn', "DBFetchScalar: MySQL.Async.fetchScalar not available; DB disabled or not started.")
        if type(cb) == "function" then cb(nil) end
        return
    end
    local ok, err = pcall(function()
        mysqlAsync.fetchScalar(query, params or {}, function(result)
            if type(cb) == "function" then
                pcall(cb, result)
            end
        end)
    end)
    if not ok then
        la_peditor.log('warn', "DBFetchScalar error: " .. tostring(err))
        if type(cb) == "function" then cb(nil) end
    end
end

-- Explicit compatibility shim (visible)
ServerUtil = la_peditor.ServerUtil

la_peditor.log('info', 'server/util.lua loaded')
