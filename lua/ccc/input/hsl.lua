local ColorInput = require("ccc.input")
local utils = require("ccc.utils")

---@class HslInput: ColorInput
local HslInput = setmetatable({
    name = "HSL",
    max = { 360, 100, 100 },
    min = { 0, 0, 0 },
    delta = { 1, 1, 1 },
    bar_name = { "H", "S", "L" },
}, { __index = ColorInput })

---@param RGB integer[]
---@return integer[] HSL
function HslInput.from_rgb(RGB)
    return utils.rgb2hsl(RGB)
end

---@param HSL integer[]
---@return integer[] RGB
function HslInput.to_rgb(HSL)
    return utils.hsl2rgb(HSL)
end

return HslInput
