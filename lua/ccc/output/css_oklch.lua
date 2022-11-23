local convert = require("ccc.utils.convert")

---@class CssOklchOutput: ColorOutput
local CssOklchOutput = {
  name = "CssOKLCH",
}

---@param RGB RGB
---@param A? Alpha
---@return string
function CssOklchOutput.str(RGB, A)
  local L, C, H = unpack(convert.rgb2oklch(RGB))
  L = L * 100
  if A then
    local pattern = "oklch(%d%% %d %d / %d%%)"
    return pattern:format(L, C, H, A * 100)
  else
    local pattern = "oklch(%d%% %d %d)"
    return pattern:format(L, C, H)
  end
end

return CssOklchOutput
