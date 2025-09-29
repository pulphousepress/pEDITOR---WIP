-- shared/namespace.lua
-- Ensure a safe, namespaced global table for this resource. Files should use `local la_peditor = la_peditor` at top.
if not la_peditor then
    la_peditor = {}
end
-- create sub-tables if missing
la_peditor.Config = la_peditor.Config or {}
la_peditor.ServerUtil = la_peditor.ServerUtil or {}
la_peditor.ClientUtil = la_peditor.ClientUtil or {}
la_peditor.Theme = la_peditor.Theme or {}

-- helper logger
function la_peditor.log(level, ...)
    local tag = "[la_peditor]"
    local msg = table.concat({...}, " ")
    if level == "debug" and la_peditor.Config and la_peditor.Config.Debug then
        print("^3"..tag.."[DEBUG]^0 "..tostring(msg))
    elseif level == "warn" then
        print("^1"..tag.."[WARN]^0 "..tostring(msg))
    else
        print(tag.." "..tostring(msg))
    end
end
