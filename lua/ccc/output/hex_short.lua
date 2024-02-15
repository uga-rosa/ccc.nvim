local convert = require("ccc.utils.convert")

local pattern = {
  uppercase = {
    "#%X%X%X%X",
    "#%X%X%X",
  },
  lowercase = {
    "#%x%x%x%x",
    "#%x%x%x",
  },
}

---@class ccc.ColorOutput
local HexShortOutput = {
  name = "HEXshort",
  pattern = pattern.lowercase,
}

---@param opt { uppercase?: boolean }
function HexShortOutput.setup(opt)
  if opt.uppercase then
    HexShortOutput.pattern = pattern.uppercase
  else
    HexShortOutput.pattern = pattern.lowercase
  end
end

function HexShortOutput.str(RGB, A)
  local R, G, B = convert.rgb_format(RGB)
  -- No rounding here
  R = R / 16
  G = G / 16
  B = B / 16
  if A then
    A = A * 255 / 16
    return HexShortOutput.pattern[1]:format(R, G, B, A)
  else
    return HexShortOutput.pattern[2]:format(R, G, B)
  end
end

return HexShortOutput
