local utils = require("ccc.utils")
local convert = require("ccc.utils.convert")

---@class CssHwbOutput: ccc.ColorOutput
local CssHwbOutput = {
  name = "CssHWB",
}

---@param RGB RGB
---@param A? Alpha
---@return string
function CssHwbOutput.str(RGB, A)
  local H, W, B = unpack(convert.rgb2hwb(RGB))
  H = utils.round(H)
  W = utils.round(W * 100)
  B = utils.round(B * 100)
  if A then
    A = utils.round(A * 100)
    return ("hwb(%d %d%% %d%% / %d%%)"):format(H, W, B, A)
  else
    return ("hwb(%d %d%% %d%%)"):format(H, W, B)
  end
end

return CssHwbOutput
