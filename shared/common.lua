-- resources/la_peditor/shared/common.lua
-- Minimal common utilities + logger for la_peditor
-- theme="1950s-cartoon-noir"
-- Purpose: supply la_peditor.log used across server/client modules.

if not la_peditor then la_peditor = {} end
la_peditor.Common = la_peditor.Common or {}

local ThemePrefix = (la_peditor and la_peditor.Theme and la_peditor.Theme.Metadata and la_peditor.Theme.Metadata.log_prefix) or "[la_peditor]"

-- log(level, ...)
-- levels: "debug", "info", "warn", "error"
function la_peditor.log(level, ...)
    level = tostring(level or "info"):lower()
    local parts = {}
    for i = 1, select("#", ...) do
        parts[#parts+1] = tostring(select(i, ...))
    end
    local msg = table.concat(parts, " ")

    -- color-coding is only visual in console; keep simple print
    local out = ("%s [%s] %s"):format(ThemePrefix, level:upper(), msg)

    if level == "error" then
        print("^1" .. out .. "^7")
    elseif level == "warn" then
        print("^3" .. out .. "^7")
    elseif level == "debug" then
        if la_peditor.Config and la_peditor.Config.Debug then
            print("^2" .. out .. "^7")
        end
    else
        print(out)
    end
end

-- convenience helpers
function la_peditor.log_info(...)   la_peditor.log("info",  ...) end
function la_peditor.log_warn(...)   la_peditor.log("warn",  ...) end
function la_peditor.log_error(...)  la_peditor.log("error", ...) end
function la_peditor.log_debug(...)  la_peditor.log("debug", ...) end

-- provide legacy global shim only if code expects a `Common` global (keeps it explicit)
if not _G.Common then
    Common = Common or la_peditor.Common
end

la_peditor.log("info", "shared/common.lua loaded — logger initialized (theme=\"1950s-cartoon-noir\")")
return la_peditor.Common
