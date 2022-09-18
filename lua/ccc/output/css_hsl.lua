local convert = require("ccc.utils.convert")

---@class CssHslOutput: ColorOutput
local CssHslOutput = {
    name = "CssHSL",
}

---@param RGB number[]
---@param alpha AlphaSlider
---@return string
function CssHslOutput.str(RGB, alpha)
    local H, S, L = unpack(convert.rgb2hsl(RGB))
    S = S * 100
    L = L * 100
    if alpha.is_showed then
        local pattern = "hsl(%d,%d%%,%d%%,%d%%)"
        local A = alpha:get() * 100
        return pattern:format(H, S, L, A)
    else
        local pattern = "hsl(%d,%d%%,%d%%)"
        return pattern:format(H, S, L)
    end
end

return CssHslOutput
