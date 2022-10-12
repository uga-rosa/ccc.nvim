local convert = require("ccc.utils.convert")

---@class CssLabOutput: ColorOutput
local CssLabOutput = {
    name = "CssLab",
}

---@param RGB RGB
---@param A? Alpha
---@return string
function CssLabOutput.str(RGB, A)
    local L, a, b = unpack(convert.rgb2lab(RGB))
    if A then
        local pattern = "lab(%d%% %d %d / %d%%)"
        return pattern:format(L, a, b, A * 100)
    else
        local pattern = "lab(%d%% %d %d)"
        return pattern:format(L, a, b)
    end
end

return CssLabOutput
