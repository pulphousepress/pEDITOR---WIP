-- la_peditor/server/main.lua

CreateThread(function()
    print('[la_peditor] Initializing Los Animales PEDitor wrapper')

    -- Auto create skin_data table if missing.
    -- This is compatible with PEDitor database.lua expectations.
    local createSql = [[
        CREATE TABLE IF NOT EXISTS skin_data (
            id INT AUTO_INCREMENT PRIMARY KEY,
            identifier VARCHAR(64) NOT NULL UNIQUE,
            skinData LONGTEXT,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ]]

    local ok, err = pcall(function()
        MySQL.query.await(createSql, {})
    end)

    if ok then
        print('[la_peditor] Verified skin_data table')
    else
        print('[la_peditor] Error creating skin_data table: ' .. tostring(err))
    end
end)
