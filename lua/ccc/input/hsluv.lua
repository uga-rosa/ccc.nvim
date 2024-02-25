local ColorInput = require("ccc.input")
local convert = require("ccc.utils.convert")

---@class HSLuvInput: ccc.ColorInput
local HSLuvInput = setmetatable({
  name = "HSLuv",
  max = { 360, 100, 100 },
  min = { 0, 0, 0 },
  delta = { 1, 1, 1 },
  bar_name = { "H", "S", "L" },
}, { __index = ColorInput })

---@param RGB RGB
---@return HSLuv
function HSLuvInput.from_rgb(RGB)
  return convert.rgb2hsluv(RGB)
end

---@param HSLuv HSLuv
---@return RGB
function HSLuvInput.to_rgb(HSLuv)
  return convert.hsluv2rgb(HSLuv)
end

return HSLuvInput
