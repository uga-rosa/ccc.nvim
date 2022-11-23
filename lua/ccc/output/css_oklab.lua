local convert = require("ccc.utils.convert")

---@class CssOklabOutput: ColorOutput
local CssOklabOutput = {
  name = "CssOKLab",
}

---@param RGB RGB
---@param A? Alpha
---@return string
function CssOklabOutput.str(RGB, A)
  local L, a, b = unpack(convert.rgb2oklab(RGB))
  L = L * 100
  if A then
    local pattern = "oklab(%d%% %d %d / %d%%)"
    return pattern:format(L, a, b, A * 100)
  else
    local pattern = "oklab(%d%% %d %d)"
    return pattern:format(L, a, b)
  end
end

return CssOklabOutput
