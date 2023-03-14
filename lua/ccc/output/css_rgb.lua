local utils = require("ccc.utils")
local convert = require("ccc.utils.convert")

---@class CssRgbOutput: ColorOutput
local CssRgbOutput = {
  name = "CssRGB",
}

---@param RGB RGB
---@param A? Alpha
---@return string
function CssRgbOutput.str(RGB, A)
  local R, G, B = convert.rgb_format(RGB)
  R = utils.round(R)
  G = utils.round(G)
  B = utils.round(B)
  if A then
    A = utils.round(A * 100)
    return ("rgb(%d %d %d / %d%%)"):format(R, G, B, A)
  else
    return ("rgb(%d %d %d)"):format(R, G, B)
  end
end

return CssRgbOutput
