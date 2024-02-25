local ColorInput = require("ccc.input")
local convert = require("ccc.utils.convert")
local utils = require("ccc.utils")

---@class OklchInput: ccc.ColorInput
local OklchInput = setmetatable({
  name = "OKLCH",
  max = { 1, 0.4, 360 },
  min = { 0, 0, 0 },
  delta = { 0.01, 0.004, 1 },
  bar_name = { "L", "C", "H" },
}, { __index = ColorInput })

---@param n number
---@param i integer
---@return string
function OklchInput.format(n, i)
  if i == 1 then
    n = utils.round(n * 100)
    return ("%5d%%"):format(n)
  elseif i == 2 then
    return ("%6.3f"):format(n)
  else
    n = utils.round(n)
    return ("%6d"):format(n)
  end
end

---@param RGB RGB
---@return OKLCH
function OklchInput.from_rgb(RGB)
  return convert.rgb2oklch(RGB)
end

---@param OKLCH OKLCH
---@return RGB
function OklchInput.to_rgb(OKLCH)
  return convert.oklch2rgb(OKLCH)
end

return OklchInput
