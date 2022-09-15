local ColorInput = require("ccc.input")
local utils = require("ccc.utils")

---@class HslInput: ColorInput
local HslInput = setmetatable({
    name = "HSL",
    max = { 360, 100, 100 },
    bar_name = { "H", "S", "L" },
}, { __index = ColorInput })

---@param R integer
---@param G integer
---@param B integer
---@return integer H
---@return integer S
---@return integer L
function HslInput.from_rgb(R, G, B)
    return utils.rgb2hsl(R, G, B)
end

---@param H integer
---@param S integer
---@param L integer
---@return integer R
---@return integer G
---@return integer B
function HslInput.to_rgb(H, S, L)
    return utils.hsl2rgb(H, S, L)
end

return HslInput
