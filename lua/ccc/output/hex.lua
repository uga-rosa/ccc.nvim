local convert = require("ccc.utils.convert")

---@class HexOutput: ColorOutput
local HexOutput = {
    name = "HEX",
    pattern = "#%02x%02x%02x",
}

---@param RGB number[]
---@return string
function HexOutput.str(RGB)
    return HexOutput.pattern:format(convert.rgb_format(RGB))
end

return HexOutput
