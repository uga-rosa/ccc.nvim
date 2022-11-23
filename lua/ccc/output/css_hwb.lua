local convert = require("ccc.utils.convert")

---@class CssHwbOutput: ColorOutput
local CssHwbOutput = {
  name = "CssHWB",
}

---@param RGB RGB
---@param A? Alpha
---@return string
function CssHwbOutput.str(RGB, A)
  local H, W, B = unpack(convert.rgb2hwb(RGB))
  W = W * 100
  B = B * 100
  if A then
    local pattern = "hwb(%d %d%% %d%% / %d%%)"
    return pattern:format(H, W, B, A * 100)
  else
    local pattern = "hwb(%d %d%% %d%%)"
    return pattern:format(H, W, B)
  end
end

return CssHwbOutput
