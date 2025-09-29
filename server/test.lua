-- server/test.lua
-- Simple self-checks for la_peditor dependencies.
local la = la_peditor
RegisterCommand('la_peditor_test', function(source, args, raw)
    if source ~= 0 then
        -- only console can run this to avoid abuse
        print('la_peditor_test: please run from server console')
        return
    end
    local ok = true
    print('la_peditor: running self-tests...')
    if GetResourceState('qbx_core') ~= 'started' then
        print('la_peditor TEST: qbx_core not started or not installed.')
        ok = false
    else
        print('la_peditor TEST: qbx_core OK.')
    end
    if GetResourceState('oxmysql') ~= 'started' and GetResourceState('mysql-async') ~= 'started' then
        print('la_peditor TEST: mysql resource not found (oxmysql/mysql-async).')
        ok = false
    else
        print('la_peditor TEST: mysql OK.')
    end
    print('la_peditor TEST: done. status=' .. tostring(ok))
end, false)
