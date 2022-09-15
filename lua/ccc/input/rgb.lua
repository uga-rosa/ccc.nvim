local ColorInput = require("ccc.input")

---@class RgbInput: ColorInput
local RgbInput = setmetatable({
    name = "RGB",
    max = { 255, 255, 255 },
    bar_name = { "R", "G", "B" },
}, { __index = ColorInput })

---@param R integer
---@param G integer
---@param B integer
---@return integer R
---@return integer G
---@return integer B
function RgbInput.from_rgb(R, G, B)
    return R, G, B
end

---@param R integer
---@param G integer
---@param B integer
---@return integer R
---@return integer G
---@return integer B
function RgbInput.to_rgb(R, G, B)
    return R, G, B
end

return RgbInput
