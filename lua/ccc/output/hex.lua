local convert = require("ccc.utils.convert")

---@class HexOutput: ColorOutput
local HexOutput = {
    name = "HEX",
}

---@param RGB number[]
---@return string
function HexOutput.str(RGB)
    local pattern = "#%02x%02x%02x"
    return pattern:format(convert.rgb_format(RGB))
end

return HexOutput
