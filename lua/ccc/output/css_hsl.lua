local utils = require("ccc.utils")
local convert = require("ccc.utils.convert")

---@class ccc.ColorOutput
local CssHslOutput = {
  name = "CssHSL",
}

function CssHslOutput.str(RGB, A)
  local H, S, L = unpack(convert.rgb2hsl(RGB))
  H = utils.round(H)
  S = utils.round(S * 100)
  L = utils.round(L * 100)
  if A then
    A = utils.round(A * 100)
    return ("hsl(%d %d%% %d%% / %d%%)"):format(H, S, L, A)
  else
    return ("hsl(%d %d%% %d%%)"):format(H, S, L)
  end
end

return CssHslOutput
