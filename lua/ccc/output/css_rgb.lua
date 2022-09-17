local convert = require("ccc.utils.convert")

---@class CssRgbOutput: ColorOutput
local CssRgbOutput = {
    name = "CssRGB",
    pattern = "rgb(%d,%d,%d)",
}

---@param RGB number[]
---@return string
function CssRgbOutput.str(RGB)
    return CssRgbOutput.pattern:format(convert.rgb_format(RGB))
end

return CssRgbOutput
