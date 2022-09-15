local config = require("ccc.config")
local utils = require("ccc.utils")

---@class CssHslOutput: ColorOutput
local CssHslOutput = {
    name = "CssHSL",
}

---@param R integer
---@param G integer
---@param B integer
---@return string
function CssHslOutput.str(R, G, B)
    ---@type string
    local hsl_format = config.get("hsl_format")
    return hsl_format:format(utils.rgb2hsl(R, G, B))
end

return CssHslOutput
