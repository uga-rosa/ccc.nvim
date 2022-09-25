local convert = require("ccc.utils.convert")

---@class CssRgbOutput: ColorOutput
local CssRgbOutput = {
    name = "CssRGB",
}

---@param RGB number[]
---@param A? number
---@return string
function CssRgbOutput.str(RGB, A)
    local R, G, B = convert.rgb_format(RGB)
    if A then
        local pattern = "rgb(%d,%d,%d,%d%%)"
        return pattern:format(R, G, B, A * 100)
    else
        local pattern = "rgb(%d,%d,%d)"
        return pattern:format(R, G, B)
    end
end

return CssRgbOutput
