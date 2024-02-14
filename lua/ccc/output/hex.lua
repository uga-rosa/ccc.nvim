local utils = require("ccc.utils")
local convert = require("ccc.utils.convert")

local pattern = {
  uppercase = {
    "#%02X%02X%02X%02X",
    "#%02X%02X%02X",
  },
  lowercase = {
    "#%02x%02x%02x%02x",
    "#%02x%02x%02x",
  },
}

---@class HexOutput: ccc.ColorOutput
local HexOutput = {
  name = "HEX",
  pattern = pattern.lowercase,
}

function HexOutput.setup(opt)
  if opt.uppercase then
    HexOutput.pattern = pattern.uppercase
  else
    HexOutput.pattern = pattern.lowercase
  end
end

---@param RGB RGB
---@param A? Alpha
---@return string
function HexOutput.str(RGB, A)
  local R, G, B = convert.rgb_format(RGB)
  R = utils.round(R)
  G = utils.round(G)
  B = utils.round(B)
  if A then
    A = utils.round(A * 255)
    return HexOutput.pattern[1]:format(R, G, B, A)
  else
    return HexOutput.pattern[2]:format(R, G, B)
  end
end

return HexOutput
