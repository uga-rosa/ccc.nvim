local ColorInput = require("ccc.input")
local utils = require("ccc.utils")
local convert = require("ccc.utils.convert")

---@class HslInput: ccc.ColorInput
local HslInput = setmetatable({
  name = "HSL",
  max = { 360, 1, 1 },
  min = { 0, 0, 0 },
  delta = { 1, 0.01, 0.01 },
  bar_name = { "H", "S", "L" },
}, { __index = ColorInput })

---@param n number
---@param i integer
---@return string
function HslInput.format(n, i)
  if i > 1 then
    n = n * 100
  end
  n = utils.round(n)
  return ("%6d"):format(n)
end

---@param RGB RGB
---@return HSL
function HslInput.from_rgb(RGB)
  return convert.rgb2hsl(RGB)
end

---@param HSL HSL
---@return RGB
function HslInput.to_rgb(HSL)
  return convert.hsl2rgb(HSL)
end

return HslInput
