local config = require("ccc.config")

---@class HexOutput: ColorOutput
local HexOutput = {
    name = "HEX",
}

---@param R integer
---@param G integer
---@param B integer
---@return string
function HexOutput.str(R, G, B)
    ---@type string
    local hex_format = config.get("hex_format")
    return hex_format:format(R, G, B)
end

return HexOutput
