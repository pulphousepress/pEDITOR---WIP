-- resources/la_peditor/shared/compat.lua
-- Compatibility & safe bindings for framework/core objects (namespaced)
-- Run this early as shared_script in fxmanifest.

if not la_peditor then la_peditor = {} end
la_peditor.Bindings = la_peditor.Bindings or {}

local bindings = la_peditor.Bindings

-- Don't create global QBCore by default. Create a namespaced accessor and provide
-- a controlled, documented shim only if EXPECT_QBCORE_GLOBAL is true.
local function detectQBCore()
    -- try the usual exports; support qb-core and qbx_core
    if exports and exports['qb-core'] and type(exports['qb-core'].GetCoreObject) == "function" then
        return exports['qb-core']:GetCoreObject()
    end
    if exports and exports['qbx_core'] and type(exports['qbx_core'].GetCoreObject) == "function" then
        return exports['qbx_core']:GetCoreObject()
    end
    if exports and exports['qbx-core'] and type(exports['qbx-core'].GetCoreObject) == "function" then
        return exports['qbx-core']:GetCoreObject()
    end
    -- no direct global assignment here — we will bind below if found
    return nil
end

-- Try to bind during startup, but tolerant: we don't block resource load
CreateThread(function()
    local attempts = 0
    while not la_peditor.QBCore and attempts < 25 do
        local qb = detectQBCore()
        if qb then
            la_peditor.QBCore = qb
            print("^3[la_peditor]^7 QBCore detected and bound (namespaced).")
            break
        end
        attempts = attempts + 1
        Wait(200)
    end
    if not la_peditor.QBCore then
        print("^3[la_peditor]^7 QBCore not detected at startup. Framework features that require QBCore will wait or fail gracefully.")
    end
end)

-- Locales and Config fallbacks: keep them namespaced but allow explicit global shim if requested.
la_peditor.Locales = la_peditor.Locales or {}
la_peditor.Config = la_peditor.Config or {}

-- Compatibility shim: set global Locales/Config only if the server expects them.
if not _G.Locales then
    Locales = Locales or la_peditor.Locales
end
if not _G.Config then
    -- NOTE: other scripts may rely on Config global. We set it only if absent to avoid overwriting.
    Config = Config or la_peditor.Config
end

-- If you explicitly want QBCore available as a global (not recommended), set:
-- _G.EXPECT_QBCORE_GLOBAL = true
if _G and _G.EXPECT_QBCORE_GLOBAL and la_peditor.QBCore then
    QBCore = la_peditor.QBCore
    print("^3[la_peditor]^7 QBCore bound to global QBCore (explicit shim).")
end

return la_peditor
