local ColorInput = require("ccc.input")
local convert = require("ccc.utils.convert")
local utils = require("ccc.utils")

---@class OklabInput: ccc.ColorInput
local OklabInput = setmetatable({
  name = "OKLab",
  max = { 1, 0.4, 0.4 },
  min = { 0, -0.4, -0.4 },
  delta = { 0.01, 0.008, 0.008 },
  bar_name = { "L", "a", "b" },
}, { __index = ColorInput })

---@param n number
---@param i integer
---@return string
function OklabInput.format(n, i)
  if i == 1 then
    n = n * 100
  else
    n = n * 250
  end
  n = utils.round(n)
  return ("%5d%%"):format(n)
end

---@param RGB RGB
---@return OKLab
function OklabInput.from_rgb(RGB)
  return convert.rgb2oklab(RGB)
end

---@param OKLab OKLab
---@return RGB
function OklabInput.to_rgb(OKLab)
  local RGB = convert.oklab2rgb(OKLab)
  return vim.tbl_map(function(x)
    return utils.clamp(x, 0, 1)
  end, RGB)
end

return OklabInput
