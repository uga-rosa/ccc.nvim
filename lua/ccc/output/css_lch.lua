local convert = require("ccc.utils.convert")

---@class CssLchOutput: ColorOutput
local CssLchOutput = {
    name = "CssLCH",
}

---@param RGB RGB
---@param A? Alpha
---@return string
function CssLchOutput.str(RGB, A)
    local L, C, H = unpack(convert.rgb2lch(RGB))
    if A then
        local pattern = "lch(%d%% %d %d / %d%%)"
        return pattern:format(L, C, H, A * 100)
    else
        local pattern = "lch(%d%% %d %d)"
        return pattern:format(L, C, H)
    end
end

return CssLchOutput
