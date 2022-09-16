local ColorInput = require("ccc.input")
local convert = require("ccc.utils.convert")

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
    return convert.rgb2hsl(RGB)
end

---@param HSL integer[]
---@return integer[] RGB
function HslInput.to_rgb(HSL)
    return convert.hsl2rgb(HSL)
end

return HslInput
