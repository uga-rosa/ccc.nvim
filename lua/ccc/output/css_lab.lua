local utils = require("ccc.utils")
local convert = require("ccc.utils.convert")

---@class ccc.ColorOutput
local CssLabOutput = {
  name = "CssLab",
}

function CssLabOutput.str(RGB, A)
  local L, a, b = unpack(convert.rgb2lab(RGB))
  L = utils.round(L)
  a = utils.round(a)
  b = utils.round(b)
  if A then
    A = utils.round(A * 100)
    return ("lab(%d%% %d %d / %d%%)"):format(L, a, b, A)
  else
    return ("lab(%d%% %d %d)"):format(L, a, b)
  end
end

return CssLabOutput
