local UI = require("ccc.ui")
local convert = require("ccc.utils.convert")

---@class CssHslOutput: ColorOutput
local CssHslOutput = {
    name = "CssHSL",
}

---@param RGB number[]
---@return string
function CssHslOutput.str(RGB)
    local H, S, L = unpack(convert.rgb2hsl(RGB))
    S = S * 100
    L = L * 100
    if UI.alpha.is_showed then
        local pattern = "hsl(%d,%d%%,%d%%,%d%%)"
        local A = UI.alpha:get() * 100
        return pattern:format(H, S, L, A)
    else
        local pattern = "hsl(%d,%d%%,%d%%)"
        return pattern:format(H, S, L)
    end
end

return CssHslOutput
