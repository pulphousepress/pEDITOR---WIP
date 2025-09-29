-- server/database/database.lua
-- theme="1950s-cartoon-noir"
-- Robust DB adapter: supports oxmysql (MySQL.query.await) and mysql-async (MySQL.Async.*) with safe fallbacks.
-- Namespaced under la_peditor but kept compatibility shim.

if not la_peditor then la_peditor = {} end
la_peditor.Database = la_peditor.Database or {}
local Database = la_peditor.Database

local function has_oxmysql()
    return type(MySQL) == "table" and type(MySQL.query) == "function"
end

local function has_mysql_async()
    return type(MySQL) == "table" and type(MySQL.Async) == "table"
end

local function wait_for_callback(fn, timeoutMs)
    timeoutMs = timeoutMs or 5000
    local done = false
    local result = nil
    local finishedAt = os.time() + math.ceil(timeoutMs / 1000)
    pcall(function()
        fn(function(res) result = res; done = true end)
    end)
    while not done do
        if os.time() > finishedAt then
            la_peditor.log('warn', 'DB wait_for_callback timed out after ' .. tostring(timeoutMs) .. 'ms')
            break
        end
        Citizen.Wait(0)
    end
    return result
end

function Database.Execute(query, params)
    if has_oxmysql() then
        local ok, res = pcall(function() return MySQL.query.await(query, params or {}) end)
        if ok then return res end
        la_peditor.log('warn', 'Database.Execute oxmysql error: ' .. tostring(res))
        return nil
    elseif has_mysql_async() then
        return wait_for_callback(function(cb)
            MySQL.Async.execute(query, params or {}, function(rowsAffected) cb(rowsAffected) end)
        end)
    else
        la_peditor.log('warn', 'Database.Execute: no MySQL driver available')
        return nil
    end
end

function Database.Fetch(query, params)
    if has_oxmysql() then
        local ok, res = pcall(function() return MySQL.query.await(query, params or {}) end)
        if ok then return (res and res[1]) or nil end
        la_peditor.log('warn', 'Database.Fetch oxmysql error: ' .. tostring(res))
        return nil
    elseif has_mysql_async() then
        return wait_for_callback(function(cb)
            MySQL.Async.fetchAll(query, params or {}, function(rows) cb((rows and rows[1]) or nil) end)
        end)
    else
        la_peditor.log('warn', 'Database.Fetch: no MySQL driver available')
        return nil
    end
end

function Database.FetchAll(query, params)
    if has_oxmysql() then
        local ok, res = pcall(function() return MySQL.query.await(query, params or {}) end)
        if ok then return res or {} end
        la_peditor.log('warn', 'Database.FetchAll oxmysql error: ' .. tostring(res))
        return {}
    elseif has_mysql_async() then
        return wait_for_callback(function(cb)
            MySQL.Async.fetchAll(query, params or {}, function(rows) cb(rows or {}) end)
        end)
    else
        la_peditor.log('warn', 'Database.FetchAll: no MySQL driver available')
        return {}
    end
end

function Database.Insert(query, params)
    if has_oxmysql() then
        local ok, res = pcall(function() return MySQL.insert.await(query, params or {}) end)
        if ok then return res end
        la_peditor.log('warn', 'Database.Insert oxmysql error: ' .. tostring(res))
        return nil
    elseif has_mysql_async() then
        -- mysql-async does not directly return insert id via API; execute then SELECT LAST_INSERT_ID()
        local execRes = wait_for_callback(function(cb)
            MySQL.Async.execute(query, params or {}, function(rowsChanged) cb(rowsChanged) end)
        end)
        -- try to fetch last id
        local last = wait_for_callback(function(cb)
            MySQL.Async.fetchAll("SELECT LAST_INSERT_ID() as id", {}, function(res) cb((res and res[1] and res[1].id) or nil) end)
        end)
        return last
    else
        la_peditor.log('warn', 'Database.Insert: no MySQL driver available')
        return nil
    end
end

function Database.Scalar(query, params)
    if has_oxmysql() then
        local ok, res = pcall(function() return MySQL.scalar.await(query, params or {}) end)
        if ok then return res end
        la_peditor.log('warn', 'Database.Scalar oxmysql error: ' .. tostring(res))
        return nil
    elseif has_mysql_async() then
        return wait_for_callback(function(cb)
            MySQL.Async.fetchAll(query, params or {}, function(rows) cb((rows and rows[1] and (rows[1].count or rows[1].COUNT or rows[1].id or rows[1].result)) or nil) end)
        end)
    else
        la_peditor.log('warn', 'Database.Scalar: no MySQL driver available')
        return nil
    end
end

-- Compatibility shim (explicit)
Database = la_peditor.Database

la_peditor.log('info', 'server/database/database.lua loaded — DB adapter ready')
return Database
