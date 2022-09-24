local ColorInput = require("ccc.input")
local convert = require("ccc.utils.convert")

---@class HSLuvInput: ColorInput
local HSLuvInput = setmetatable({
    name = "HSLuv",
    max = { 360, 1, 1 },
    min = { 0, 0, 0 },
    delta = { 1, 0.01, 0.01 },
    bar_name = { "H", "S", "L" },
}, { __index = ColorInput })

---@param n number
---@param i integer
---@return string
function HSLuvInput.format(n, i)
    if i > 1 then
        n = n * 100
    end
    return ("%6d"):format(n)
end

---@param RGB number[]
---@return number[] HSLuv
function HSLuvInput.from_rgb(RGB) return convert.rgb2hsluv(RGB) end

---@param HSLuv number[]
---@return number[] RGB
function HSLuvInput.to_rgb(HSLuv) return convert.hsluv2rgb(HSLuv) end

return HSLuvInput
