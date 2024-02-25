local ColorInput = require("ccc.input")
local utils = require("ccc.utils")
local convert = require("ccc.utils.convert")

---@class OkhsvInput: ccc.ColorInput
local OkhsvInput = setmetatable({
  name = "OKHSV",
  max = { 360, 1, 1 },
  min = { 0, 0, 0 },
  delta = { 1, 0.01, 0.01 },
  bar_name = { "H", "S", "V" },
}, { __index = ColorInput })

---@param n number
---@param i integer
---@return string
function OkhsvInput.format(n, i)
  if i > 1 then
    n = n * 100
  end
  n = utils.round(n)
  return ("%6d"):format(n)
end

---@param RGB RGB
---@return OKHSV
function OkhsvInput.from_rgb(RGB)
  return convert.rgb2okhsv(RGB)
end

---@param OKHSV OKHSV
---@return RGB
function OkhsvInput.to_rgb(OKHSV)
  return convert.okhsv2rgb(OKHSV)
end

return OkhsvInput
