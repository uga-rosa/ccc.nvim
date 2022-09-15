local config = require("ccc.config")

---@class CssRgbOutput: ColorOutput
local CssRgbOutput = {
    name = "CssRGB",
}

---@param R integer
---@param G integer
---@param B integer
---@return string
function CssRgbOutput.str(R, G, B)
    ---@type string
    local rgb_format = config.get("rgb_format")
    return rgb_format:format(R, G, B)
end

return CssRgbOutput
