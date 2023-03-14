local convert = require("ccc.utils.convert")

---@class HexShortOutput: ColorOutput
local HexShortOutput = {
  name = "HEXshort",
}

---@param RGB RGB
---@param A? Alpha
---@return string
function HexShortOutput.str(RGB, A)
  local R, G, B = convert.rgb_format(RGB)
  -- No rounding here
  R = R / 16
  G = G / 16
  B = B / 16
  if A then
    A = A * 255 / 16
    return ("#%x%x%x%x"):format(R, G, B, A)
  else
    return ("#%x%x%x"):format(R, G, B)
  end
end

return HexShortOutput
