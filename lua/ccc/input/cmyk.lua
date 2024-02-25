local ColorInput = require("ccc.input")
local convert = require("ccc.utils.convert")

---@class CmykInput: ccc.ColorInput
local CmykInput = setmetatable({
  name = "CMYK",
  max = { 1, 1, 1, 1 },
  min = { 0, 0, 0, 0 },
  delta = { 0.005, 0.005, 0.005, 0.005 },
  bar_name = { "C", "M", "Y", "K" },
}, { __index = ColorInput })

---@param n number
---@return string
function CmykInput.format(n)
  return ("%5.1f%%"):format(math.floor(n * 200) / 2)
end

---@param RGB RGB
---@return CMYK
function CmykInput.from_rgb(RGB)
  return convert.rgb2cmyk(RGB)
end

---@param CMYK CMYK
---@return RGB
function CmykInput.to_rgb(CMYK)
  return convert.cmyk2rgb(CMYK)
end

return CmykInput
