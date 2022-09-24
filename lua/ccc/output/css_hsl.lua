local convert = require("ccc.utils.convert")

---@class CssHslOutput: ColorOutput
local CssHslOutput = {
    name = "CssHSL",
}

---@param RGB number[]
---@param A? number
---@return string
function CssHslOutput.str(RGB, A)
    local H, S, L = unpack(convert.rgb2hsl(RGB))
    S = S * 100
    L = L * 100
    if A then
        local pattern = "hsl(%d,%d%%,%d%%,%d%%)"
        return pattern:format(H, S, L, A * 100)
    else
        local pattern = "hsl(%d,%d%%,%d%%)"
        return pattern:format(H, S, L)
    end
end

return CssHslOutput
