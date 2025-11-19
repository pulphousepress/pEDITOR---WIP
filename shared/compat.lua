-- resources/la_peditor/shared/compat.lua
-- Compatibility & safe bindings for framework/core objects (namespaced)
-- Run this early as shared_script in fxmanifest.

if not la_peditor then la_peditor = {} end
la_peditor.Bindings = la_peditor.Bindings or {}

local bindings = la_peditor.Bindings

-- Don't create global QBCore by default. Create a namespaced accessor and provide
-- a controlled, documented shim only if EXPECT_QBCORE_GLOBAL is true.
local function detectQBCore()
    -- prefer qbx_core naming conventions first, then fall back to qb-core
    if exports then
        if exports['qbx_core'] and type(exports['qbx_core'].GetCoreObject) == "function" then
            return exports['qbx_core']:GetCoreObject()
        end
        if exports['qbx-core'] and type(exports['qbx-core'].GetCoreObject) == "function" then
            return exports['qbx-core']:GetCoreObject()
        end
        if exports['qb-core'] and type(exports['qb-core'].GetCoreObject) == "function" then
            return exports['qb-core']:GetCoreObject()
        end
    end
    if rawget(_G, 'QBCore') and type(_G.QBCore) == "table" then
        return _G.QBCore
    end
    return nil
end

function la_peditor.GetCoreObject()
    if la_peditor.QBCore then return la_peditor.QBCore end
    local core = detectQBCore()
    if core then
        la_peditor.QBCore = core
    end
    return la_peditor.QBCore
end

-- Try to bind during startup, but tolerant: we don't block resource load
CreateThread(function()
    local attempts = 0
    while not la_peditor.QBCore and attempts < 25 do
        local qb = la_peditor.GetCoreObject()
        if qb then
            la_peditor.QBCore = qb
            print("^3[la_peditor]^7 QBCore/qbx_core detected and bound (namespaced).")
            break
        end
        attempts = attempts + 1
        Wait(200)
    end
    if not la_peditor.QBCore then
        print("^3[la_peditor]^7 QBCore/qbx_core not detected at startup. Framework features will wait or fail gracefully.")
    end
end)

-- Locales and Config fallbacks: keep them namespaced but allow explicit global shim if requested.
la_peditor.Locales = la_peditor.Locales or {}
la_peditor.Config = la_peditor.Config or {}

local function detectOxLib()
    if la_peditor.lib and type(la_peditor.lib) == "table" then
        return la_peditor.lib
    end

    local globalLib = rawget(_G, "lib")
    if type(globalLib) == "table" then
        la_peditor.lib = globalLib
        return globalLib
    end

    if exports and exports['ox_lib'] then
        local ok, exported = pcall(function()
            return exports['ox_lib']
        end)
        if ok and type(exported) == "table" then
            la_peditor.lib = exported
            return exported
        end
    end

    return nil
end

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
if _G and _G.EXPECT_QBCORE_GLOBAL then
    local qb = la_peditor.GetCoreObject()
    if qb then
        QBCore = qb
        print("^3[la_peditor]^7 QBCore bound to global QBCore (explicit shim).")
    end
end

-- Attempt to bind ox_lib helpers without forcing the dependency.
CreateThread(function()
    local attempts = 0
    while attempts < 20 do
        local lib = detectOxLib()
        if lib then
            print("^3[la_peditor]^7 ox_lib detected (lib shim registered).")
            break
        end
        attempts = attempts + 1
        Wait(250)
    end
    if not la_peditor.lib then
        print("^3[la_peditor]^7 ox_lib not found; continuing with fallback UI/helpers.")
    end
end)

return la_peditor
