local convert = require("ccc.utils.convert")

---@class CssHslOutput: ColorOutput
local CssHslOutput = {
    name = "CssHSL",
    pattern = "hsl(%d,%d%%,%d%%)",
}

---@param RGB number[]
---@return string
function CssHslOutput.str(RGB)
    return CssHslOutput.pattern:format(unpack(convert.rgb2hsl(RGB)))
end

return CssHslOutput
