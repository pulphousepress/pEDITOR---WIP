-- server/permissions.lua
-- theme="1950s-cartoon-noir"
-- Namespaced permissions helpers + explicit compatibility shim

if not la_peditor then la_peditor = {} end
la_peditor.Permissions = la_peditor.Permissions or {}
local Perm = la_peditor.Permissions

-- Safe reference to ServerUtil (may be injected later during startup)
local function getServerUtil()
    return la_peditor.ServerUtil or {}
end

-- Returns true if the player's group matches `group` or the player is an admin
function Perm.HasAccess(source, group)
    local ServerUtil = getServerUtil()
    local playerGroup = "user"
    if ServerUtil and type(ServerUtil.GetPlayerGroup) == "function" then
        local ok, res = pcall(ServerUtil.GetPlayerGroup, source)
        if ok and res then playerGroup = res end
    end
    return tostring(playerGroup) == tostring(group) or tostring(playerGroup) == "admin"
end

-- Returns whether the player may use the ped editor (checks Config.AllowedGroups)
function Perm.CanUsePedEditor(source)
    local cfg = la_peditor.Config or {}
    local allowedGroups = cfg.AllowedGroups or { "admin", "mod" }
    local ServerUtil = getServerUtil()
    local playerGroup = "user"
    if ServerUtil and type(ServerUtil.GetPlayerGroup) == "function" then
        local ok, res = pcall(ServerUtil.GetPlayerGroup, source)
        if ok and res then playerGroup = res end
    end

    for _, g in ipairs(allowedGroups) do
        if tostring(g) == tostring(playerGroup) then
            return true
        end
    end
    return false
end

-- Explicit compatibility shim for older code that expects global `Permissions`
-- This is intentional and visible so it's easy to remove if you migrate fully.
Permissions = la_peditor.Permissions

la_peditor.log('info', 'server/permissions.lua loaded')
