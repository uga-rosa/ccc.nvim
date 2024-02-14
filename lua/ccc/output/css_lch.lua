local utils = require("ccc.utils")
local convert = require("ccc.utils.convert")

---@class CssLchOutput: ccc.ColorOutput
local CssLchOutput = {
  name = "CssLCH",
}

---@param RGB RGB
---@param A? Alpha
---@return string
function CssLchOutput.str(RGB, A)
  local L, C, H = unpack(convert.rgb2lch(RGB))
  L = utils.round(L)
  C = utils.round(C)
  H = utils.round(H)
  if A then
    A = utils.round(A * 100)
    return ("lch(%d%% %d %d / %d%%)"):format(L, C, H, A)
  else
    return ("lch(%d%% %d %d)"):format(L, C, H)
  end
end

return CssLchOutput
