local ColorInput = require("ccc.input")
local utils = require("ccc.utils")
local convert = require("ccc.utils.convert")

---@class HsvInput: ccc.ColorInput
local HsvInput = setmetatable({
  name = "HSV",
  max = { 360, 1, 1 },
  min = { 0, 0, 0 },
  delta = { 1, 0.01, 0.01 },
  bar_name = { "H", "S", "V" },
}, { __index = ColorInput })

---@param n number
---@param i integer
---@return string
function HsvInput.format(n, i)
  if i > 1 then
    n = n * 100
  end
  n = utils.round(n)
  return ("%6d"):format(n)
end

---@param RGB RGB
---@return HSV
function HsvInput.from_rgb(RGB)
  return convert.rgb2hsv(RGB)
end

---@param HSV HSV
---@return RGB
function HsvInput.to_rgb(HSV)
  return convert.hsv2rgb(HSV)
end

return HsvInput
